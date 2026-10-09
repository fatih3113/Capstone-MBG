import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'ml_service.dart';

/// Mock ML Service for development and testing.
///
/// Simulates TensorFlow Lite inference with randomized but realistic predictions.
/// Replace this class with [MLServiceTFLite] when the .tflite model is available.
///
/// HOW TO REPLACE:
/// 1. Add `tflite_flutter: ^0.10.4` to pubspec.yaml
/// 2. Place `food_classifier.tflite` + `food_labels.txt` in assets/models/
/// 3. Create MLServiceTFLite that implements MLService
/// 4. In providers, inject MLServiceTFLite instead of MLServiceMock
///
/// [MATA KULIAH: Machine Learning + Pengolahan Citra Digital]
class MLServiceMock implements MLService {
  bool _isLoaded = false;
  final Random _random = Random();

  /// Food classes that the model can identify
  /// These match the MBG food categories
  static const List<Map<String, String>> _foodClasses = [
    {'id': 'f1', 'name': 'Nasi Putih'},
    {'id': 'f2', 'name': 'Ayam Goreng'},
    {'id': 'f3', 'name': 'Telur Rebus'},
    {'id': 'f4', 'name': 'Ikan Goreng'},
    {'id': 'f5', 'name': 'Tempe Goreng'},
    {'id': 'f6', 'name': 'Tahu Goreng'},
    {'id': 'f7', 'name': 'Sayur Bayam'},
    {'id': 'f8', 'name': 'Sayur Wortel'},
    {'id': 'f9', 'name': 'Pisang'},
    {'id': 'f10', 'name': 'Jeruk'},
    {'id': 'f11', 'name': 'Susu Putih'},
    {'id': 'f12', 'name': 'Mie Goreng'},
    {'id': 'f13', 'name': 'Perkedel Kentang'},
    {'id': 'f14', 'name': 'Tumis Kangkung'},
    {'id': 'f15', 'name': 'Semangka'},
  ];

  @override
  bool get isModelLoaded => _isLoaded;

  @override
  Future<void> loadModel() async {
    // Simulate model loading time
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoaded = true;
    // ignore: avoid_print
    print('[MLServiceMock] Model loaded successfully (mock)');
  }

  @override
  Future<void> dispose() async {
    _isLoaded = false;
  }

  @override
  Future<List<List<List<List<double>>>>> preprocessImage(
    Uint8List imageBytes,
  ) async {
    // Mock preprocessing - return dummy tensor
    // In real TFLite: resize to 224x224, normalize [0,1]
    const size = 224;
    return List.generate(
      1,
      (_) => List.generate(
        size,
        (_) => List.generate(
          size,
          (_) => List.generate(3, (_) => _random.nextDouble()),
        ),
      ),
    );
  }

  @override
  Future<List<MLPrediction>> classifyImage(File imageFile) async {
    if (!_isLoaded) await loadModel();

    // Simulate inference time (80-300ms for realistic feel)
    final inferenceMs = 80 + _random.nextInt(220);
    await Future.delayed(Duration(milliseconds: inferenceMs));

    // Generate realistic mock predictions
    // In a real plate, we'd expect 3-5 food items
    final numFoods = 2 + _random.nextInt(3); // 2-4 foods detected
    final shuffled = List<Map<String, String>>.from(_foodClasses)..shuffle(_random);
    final detected = shuffled.take(numFoods).toList();

    // Generate confidence scores that sum < 1 each (multi-label classification)
    final predictions = <MLPrediction>[];
    for (int i = 0; i < detected.length; i++) {
      // Higher confidence for first detected food, decreasing for others
      final baseConfidence = 0.95 - (i * 0.05);
      final noise = (_random.nextDouble() - 0.5) * 0.08;
      final confidence = (baseConfidence + noise).clamp(0.55, 0.99);

      predictions.add(MLPrediction(
        foodId: detected[i]['id']!,
        foodName: detected[i]['name']!,
        confidence: confidence,
        classIndex: _foodClasses.indexWhere((f) => f['id'] == detected[i]['id']),
      ));
    }

    // Sort by confidence descending
    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
    return predictions;
  }

  @override
  List<MLPrediction> getPredictions(
    List<double> outputTensor,
    List<String> labels, {
    int topK = 5,
  }) {
    // Map output tensor to predictions
    final indexed = outputTensor.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return indexed.take(topK).map((entry) {
      return MLPrediction(
        foodId: 'f${entry.key + 1}',
        foodName: entry.key < labels.length ? labels[entry.key] : 'Unknown',
        confidence: entry.value,
        classIndex: entry.key,
      );
    }).toList();
  }
}
