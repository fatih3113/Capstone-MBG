import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/prediction_model.dart';
import '../data/models/nutrition_model.dart';
import '../data/models/evaluation_model.dart';
import '../data/services/food_service.dart';
import '../data/services/history_service.dart';
import '../ml/ml_service.dart';
import '../ml/ml_service_mock.dart';
import '../ml/image_processing_service.dart';

enum ScanStatus {
  idle,
  imagePicked,
  preprocessing,
  classifying,
  fetchingNutrition,
  waitingEvaluation, // NEW: menunggu user isi data sensorik & konsumsi
  analyzing,         // NEW: menghitung analisis akhir
  done,
  error,
}

class ScanProvider extends ChangeNotifier {
  final FoodService _foodService;
  final HistoryService _historyService;
  final MLService _mlService;
  final ImageProcessingService _imageProcessingService;

  ScanProvider({
    FoodService? foodService,
    HistoryService? historyService,
    MLService? mlService,
    ImageProcessingService? imageProcessingService,
  })  : _foodService = foodService ?? FoodService(),
        _historyService = historyService ?? HistoryService(),
        _mlService = mlService ?? MLServiceMock(),
        _imageProcessingService = imageProcessingService ?? ImageProcessingService();

  ScanStatus _status = ScanStatus.idle;
  File? _selectedImage;
  List<MLPrediction> _mlPredictions = [];
  List<PredictionModel> _predictions = [];
  List<NutritionModel> _nutritionResults = [];
  NutritionModel _totalNutrition = NutritionModel.zero();
  String? _errorMessage;
  String _statusMessage = '';
  bool _isSaved = false;

  // ─── Data Evaluasi ─────────────────────────────────────────────────────────
  SensoryData? _sensoryData;
  ConsumptionData? _consumptionData;
  NutritionAnalysisResult? _analysisResult;

  // ─── Getters ───────────────────────────────────────────────────────────────
  ScanStatus get status => _status;
  File? get selectedImage => _selectedImage;
  List<MLPrediction> get mlPredictions => _mlPredictions;
  List<PredictionModel> get predictions => _predictions;
  List<NutritionModel> get nutritionResults => _nutritionResults;
  NutritionModel get totalNutrition => _totalNutrition;
  String? get errorMessage => _errorMessage;
  String get statusMessage => _statusMessage;
  bool get isSaved => _isSaved;
  SensoryData? get sensoryData => _sensoryData;
  ConsumptionData? get consumptionData => _consumptionData;
  NutritionAnalysisResult? get analysisResult => _analysisResult;

  bool get isProcessing => [
    ScanStatus.preprocessing,
    ScanStatus.classifying,
    ScanStatus.fetchingNutrition,
    ScanStatus.analyzing,
  ].contains(_status);

  bool get isIdentificationDone => _status == ScanStatus.waitingEvaluation || _status == ScanStatus.done;
  bool get isDone => _status == ScanStatus.done;
  bool get isWaitingEvaluation => _status == ScanStatus.waitingEvaluation;

  // ─── Step 1-3: Foto & Identifikasi & Ambil Data Gizi ─────────────────────
  void setImage(File image) {
    _selectedImage = image;
    _status = ScanStatus.imagePicked;
    _mlPredictions = [];
    _predictions = [];
    _nutritionResults = [];
    _totalNutrition = NutritionModel.zero();
    _sensoryData = null;
    _consumptionData = null;
    _analysisResult = null;
    _isSaved = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Jalankan identifikasi makanan + ambil data gizi (Step 1-3)
  Future<void> analyzeImage(String userId) async {
    if (_selectedImage == null) return;

    try {
      // Step 1: Preprocessing gambar
      _setStatus(ScanStatus.preprocessing, 'Memproses gambar...');
      await _imageProcessingService.preprocessForML(_selectedImage!);

      // Step 2: Klasifikasi ML - Identifikasi Menu
      _setStatus(ScanStatus.classifying, 'Mengidentifikasi makanan...');
      if (!_mlService.isModelLoaded) await _mlService.loadModel();
      _mlPredictions = await _mlService.classifyImage(_selectedImage!);

      // Step 3: Ambil Data Kandungan Gizi dari database
      _setStatus(ScanStatus.fetchingNutrition, 'Mengambil data kandungan gizi...');
      final foodIds = _mlPredictions.map((p) => p.foodId).toList();
      final nutritionResponse = await _foodService.getNutritionByFoodIds(foodIds);

      if (nutritionResponse.success && nutritionResponse.data != null) {
        _nutritionResults = nutritionResponse.data!;

        // Build prediction models dengan data gizi
        _predictions = _mlPredictions.map((mlPred) {
          final nutrition = _nutritionResults.firstWhere(
            (n) => n.foodId == mlPred.foodId,
            orElse: () => NutritionModel.zero(),
          );
          final scaled = nutrition.scaleByPortion(100); // Default 100g
          return PredictionModel(
            id: 'pred_${mlPred.foodId}',
            scanId: '',
            foodId: mlPred.foodId,
            foodName: mlPred.foodName,
            confidence: mlPred.confidence,
            portionEstimateGram: 100,
            calories: scaled.calories,
            protein: scaled.protein,
            carbs: scaled.carbs,
            fat: scaled.fat,
          );
        }).toList();

        // Hitung total gizi (sebelum penyesuaian porsi konsumsi)
        _totalNutrition = _nutritionResults.fold(
          NutritionModel.zero(),
          (sum, n) => sum + n.scaleByPortion(100),
        );
      }

      // Step 4: Menunggu user mengisi data evaluasi (Sensorik + Konsumsi)
      _setStatus(ScanStatus.waitingEvaluation, 'Identifikasi selesai! Isi data evaluasi untuk analisis lengkap.');
      notifyListeners();
    } catch (e) {
      _status = ScanStatus.error;
      _errorMessage = 'Gagal menganalisis gambar: ${e.toString()}';
      notifyListeners();
    }
  }

  // ─── Step 4-5: Data Sensorik & Konsumsi ───────────────────────────────────

  void setSensoryData(SensoryData data) {
    _sensoryData = data;
    notifyListeners();
  }

  void setConsumptionData(ConsumptionData data) {
    _consumptionData = data;
    notifyListeners();
  }

  // ─── Step 6: Analisis Gizi Lengkap ────────────────────────────────────────

  /// Gabungkan semua data dan hasilkan analisis akhir (Step 6)
  Future<void> runFullAnalysis(String userId) async {
    if (_sensoryData == null || _consumptionData == null) return;

    try {
      _setStatus(ScanStatus.analyzing, 'Menghitung analisis gizi...');

      // Hitung hasil analisis berdasarkan semua data
      _analysisResult = NutritionAnalysisResult.compute(
        baseCalories: _totalNutrition.calories,
        baseProtein: _totalNutrition.protein,
        baseCarbs: _totalNutrition.carbs,
        baseFat: _totalNutrition.fat,
        baseFiber: _totalNutrition.fiber,
        sensory: _sensoryData!,
        consumption: _consumptionData!,
      );

      // Simpan ke riwayat
      await _saveToHistory(userId);

      _status = ScanStatus.done;
      _statusMessage = 'Analisis gizi selesai!';
      notifyListeners();
    } catch (e) {
      _status = ScanStatus.error;
      _errorMessage = 'Gagal menghitung analisis: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _saveToHistory(String userId) async {
    if (_selectedImage == null || _analysisResult == null) return;
    await _historyService.saveScan(
      userId: userId,
      imageFile: _selectedImage!,
      predictions: _predictions,
      totalCalories: _analysisResult!.estimatedCalories,
      totalProtein: _analysisResult!.estimatedProtein,
      totalCarbs: _analysisResult!.estimatedCarbs,
      totalFat: _analysisResult!.estimatedFat,
      totalFiber: _analysisResult!.estimatedFiber,
      sensoryData: _sensoryData,
      consumptionData: _consumptionData,
    );
    _isSaved = true;
  }

  void reset() {
    _status = ScanStatus.idle;
    _selectedImage = null;
    _mlPredictions = [];
    _predictions = [];
    _nutritionResults = [];
    _totalNutrition = NutritionModel.zero();
    _sensoryData = null;
    _consumptionData = null;
    _analysisResult = null;
    _errorMessage = null;
    _statusMessage = '';
    _isSaved = false;
    notifyListeners();
  }

  void _setStatus(ScanStatus status, String message) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
  }
}
