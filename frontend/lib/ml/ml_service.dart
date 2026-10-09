import 'dart:io';
import 'dart:typed_data';

/// Abstract interface for the Machine Learning classification service.
/// 
/// This abstraction allows swapping between:
/// - [MLServiceMock] for development/testing (current)
/// - TensorFlow Lite implementation for production
///
/// [MATA KULIAH: Machine Learning + Pemrograman Sistem Cerdas]
abstract class MLService {
  /// Load the ML model into memory.
  /// Must be called before any inference.
  Future<void> loadModel();

  /// Release model resources.
  Future<void> dispose();

  /// Returns true if model is loaded and ready.
  bool get isModelLoaded;

  /// Preprocess image bytes for model input.
  /// Returns normalized float array [1, inputSize, inputSize, 3]
  Future<List<List<List<List<double>>>>> preprocessImage(Uint8List imageBytes);

  /// Run inference on preprocessed input.
  /// Returns list of [MLPrediction] sorted by confidence descending.
  Future<List<MLPrediction>> classifyImage(File imageFile);

  /// Get top-K predictions from raw output tensor.
  List<MLPrediction> getPredictions(List<double> outputTensor, List<String> labels, {int topK = 5});
}

/// Single ML prediction result
class MLPrediction {
  final String foodId;
  final String foodName;
  final double confidence; // 0.0 - 1.0
  final int classIndex;

  const MLPrediction({
    required this.foodId,
    required this.foodName,
    required this.confidence,
    required this.classIndex,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';
  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;

  @override
  String toString() => 'MLPrediction(food: $foodName, confidence: $confidencePercent)';
}

/// Output from a complete classification session
class MLClassificationResult {
  final List<MLPrediction> predictions;
  final Duration inferenceTime;
  final bool success;
  final String? error;

  const MLClassificationResult({
    required this.predictions,
    required this.inferenceTime,
    this.success = true,
    this.error,
  });

  factory MLClassificationResult.error(String error) {
    return MLClassificationResult(
      predictions: [],
      inferenceTime: Duration.zero,
      success: false,
      error: error,
    );
  }

  bool get hasPredictions => predictions.isNotEmpty;
  MLPrediction? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;
}
