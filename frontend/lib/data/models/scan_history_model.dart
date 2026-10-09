import 'prediction_model.dart';
import 'evaluation_model.dart';

class ScanHistoryModel {
  final String id;
  final String userId;
  final String? imageUrl;
  final String? localImagePath;
  final DateTime scannedAt;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final List<PredictionModel> predictions;
  final String status; // 'success' | 'failed' | 'processing'
  final SensoryData? sensoryData;
  final ConsumptionData? consumptionData;

  const ScanHistoryModel({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.localImagePath,
    required this.scannedAt,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.predictions,
    this.status = 'success',
    this.sensoryData,
    this.consumptionData,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      imageUrl: json['image_url'] as String?,
      localImagePath: json['local_image_path'] as String?,
      scannedAt: json['scanned_at'] != null
          ? DateTime.parse(json['scanned_at'] as String)
          : DateTime.now(),
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['total_carbs'] as num?)?.toDouble() ?? 0,
      totalFat: (json['total_fat'] as num?)?.toDouble() ?? 0,
      totalFiber: (json['total_fiber'] as num?)?.toDouble() ?? 0,
      predictions: (json['predictions'] as List<dynamic>?)
              ?.map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String? ?? 'success',
      sensoryData: json['sensory_data'] != null
          ? SensoryData.fromJson(json['sensory_data'] as Map<String, dynamic>)
          : null,
      consumptionData: json['consumption_data'] != null
          ? ConsumptionData.fromJson(json['consumption_data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'image_url': imageUrl,
    'local_image_path': localImagePath,
    'scanned_at': scannedAt.toIso8601String(),
    'total_calories': totalCalories,
    'total_protein': totalProtein,
    'total_carbs': totalCarbs,
    'total_fat': totalFat,
    'total_fiber': totalFiber,
    'predictions': predictions.map((e) => e.toJson()).toList(),
    'status': status,
    if (sensoryData != null) 'sensory_data': sensoryData!.toJson(),
    if (consumptionData != null) 'consumption_data': consumptionData!.toJson(),
  };

  String get displayImagePath => localImagePath ?? imageUrl ?? '';
  List<String> get foodNames => predictions.map((p) => p.foodName).toList();
}
