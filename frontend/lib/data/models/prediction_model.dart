class PredictionModel {
  final String id;
  final String scanId;
  final String foodId;
  final String foodName;
  final String? foodCategory;
  final double confidence; // 0.0 - 1.0
  final double portionEstimateGram;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const PredictionModel({
    required this.id,
    required this.scanId,
    required this.foodId,
    required this.foodName,
    this.foodCategory,
    required this.confidence,
    this.portionEstimateGram = 100,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      id: json['id']?.toString() ?? '',
      scanId: json['scan_id']?.toString() ?? '',
      foodId: json['food_id']?.toString() ?? '',
      foodName: json['food_name'] as String? ?? '',
      foodCategory: json['food_category'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      portionEstimateGram:
          (json['portion_estimate_gram'] as num?)?.toDouble() ?? 100,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'scan_id': scanId,
    'food_id': foodId,
    'food_name': foodName,
    'food_category': foodCategory,
    'confidence': confidence,
    'portion_estimate_gram': portionEstimateGram,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(0)}%';

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;
}
