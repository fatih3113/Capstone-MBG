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
  // UUID diambil langsung dari tabel Food di PostgreSQL
  // Jika seed ulang, update ID ini sesuai output: npx ts-node src/database/seed.ts
  static const List<Map<String, String>> _foodClasses = [
    {'id': '74891118-6318-4fe2-a4fc-a03b406a6ad9', 'name': 'Nasi Putih'},
    {'id': 'e1714fae-c4f5-4d2c-84cf-f2430c86693f', 'name': 'Ayam Goreng'},
    {'id': '93ac6c1a-582a-4693-970b-dfbb1e191647', 'name': 'Telur Rebus'},
    {'id': 'b1224052-a069-4624-a69c-200616c637e6', 'name': 'Ikan Goreng'},
    {'id': '95879199-bae9-4750-a87a-9b284402e8ca', 'name': 'Tempe Goreng'},
    {'id': '78af0063-1b19-406f-b519-1e70d185ab26', 'name': 'Tahu Goreng'},
    {'id': '6fbd2918-acd9-4df0-a1ca-3a43237148f3', 'name': 'Sayur Bayam'},
    {'id': '914cb058-b968-49aa-b959-3264b53f46bf', 'name': 'Sayur Wortel'},
    {'id': '2a88909a-48e5-40e6-9b2e-03aad0837ec0', 'name': 'Pisang'},
    {'id': 'a36d1548-b04b-453e-9373-787f752b230f', 'name': 'Jeruk'},
    {'id': '85b47441-6491-4116-8418-5c7e41b9a283', 'name': 'Susu Putih'},
    {'id': 'bed28f47-5a69-4630-b5f9-c1a0e09bde72', 'name': 'Mie Goreng'},
    {'id': '982fda0b-5910-486a-95c7-67427a3e2ebf', 'name': 'Perkedel Kentang'},
    {'id': '23083b4f-26ed-4b34-8a59-b4dd94d1b1e9', 'name': 'Tumis Kangkung'},
    {'id': 'd8702ef2-cd88-4ac7-94b1-a47921892e45', 'name': 'Semangka'},
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
