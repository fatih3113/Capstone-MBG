class DailyNutritionModel {
  final String id;
  final String userId;
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final int totalScans;
  final double caloriesTarget;
  final double proteinTarget;
  final double carbsTarget;
  final double fatTarget;
  final double fiberTarget;

  const DailyNutritionModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.totalScans,
    this.caloriesTarget = 2000,
    this.proteinTarget = 60,
    this.carbsTarget = 300,
    this.fatTarget = 65,
    this.fiberTarget = 25,
  });

  factory DailyNutritionModel.fromJson(Map<String, dynamic> json) {
    // Support both camelCase (Prisma backend) and snake_case (legacy) field names
    return DailyNutritionModel(
      id: json['id']?.toString() ?? '',
      userId: (json['userId'] ?? json['user_id'])?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      totalCalories:
          ((json['totalCalories'] ?? json['total_calories']) as num?)
              ?.toDouble() ??
              0,
      totalProtein:
          ((json['totalProtein'] ?? json['total_protein']) as num?)
              ?.toDouble() ??
              0,
      totalCarbs:
          ((json['totalCarbs'] ?? json['total_carbs']) as num?)?.toDouble() ??
              0,
      totalFat:
          ((json['totalFat'] ?? json['total_fat']) as num?)?.toDouble() ?? 0,
      totalFiber:
          ((json['totalFiber'] ?? json['total_fiber']) as num?)?.toDouble() ??
              0,
      totalScans: (json['totalScans'] ?? json['total_scans']) as int? ?? 0,
      caloriesTarget:
          ((json['caloriesTarget'] ?? json['calories_target']) as num?)
              ?.toDouble() ??
              2000,
      proteinTarget:
          ((json['proteinTarget'] ?? json['protein_target']) as num?)
              ?.toDouble() ??
              60,
      carbsTarget:
          ((json['carbsTarget'] ?? json['carbs_target']) as num?)
              ?.toDouble() ??
              300,
      fatTarget:
          ((json['fatTarget'] ?? json['fat_target']) as num?)?.toDouble() ?? 65,
      fiberTarget:
          ((json['fiberTarget'] ?? json['fiber_target']) as num?)
              ?.toDouble() ??
              25,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'date': date.toIso8601String(),
    'total_calories': totalCalories,
    'total_protein': totalProtein,
    'total_carbs': totalCarbs,
    'total_fat': totalFat,
    'total_fiber': totalFiber,
    'total_scans': totalScans,
    'calories_target': caloriesTarget,
    'protein_target': proteinTarget,
    'carbs_target': carbsTarget,
    'fat_target': fatTarget,
    'fiber_target': fiberTarget,
  };

  double get caloriesPercent =>
      caloriesTarget > 0 ? (totalCalories / caloriesTarget).clamp(0, 2) : 0;
  double get proteinPercent =>
      proteinTarget > 0 ? (totalProtein / proteinTarget).clamp(0, 2) : 0;
  double get carbsPercent =>
      carbsTarget > 0 ? (totalCarbs / carbsTarget).clamp(0, 2) : 0;
  double get fatPercent =>
      fatTarget > 0 ? (totalFat / fatTarget).clamp(0, 2) : 0;
  double get fiberPercent =>
      fiberTarget > 0 ? (totalFiber / fiberTarget).clamp(0, 2) : 0;
}
