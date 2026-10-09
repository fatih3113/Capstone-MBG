/// Model untuk data sensorik makanan (indikator penerimaan makanan)
class SensoryData {
  final String taste;      // Enak, Biasa, Tidak Enak
  final String saltLevel;  // Terlalu Asin, Pas, Kurang Asin
  final String sweetLevel; // Terlalu Manis, Pas, Kurang Manis
  final String texture;    // Lembut, Pas, Keras
  final String aroma;      // Sedap, Biasa, Tidak Sedap

  const SensoryData({
    required this.taste,
    required this.saltLevel,
    required this.sweetLevel,
    required this.texture,
    required this.aroma,
  });

  /// Skor rasa: 1-5 berdasarkan pilihan
  double get tasteScore {
    switch (taste) {
      case 'Sangat Enak': return 5.0;
      case 'Enak': return 4.0;
      case 'Biasa': return 3.0;
      case 'Kurang Enak': return 2.0;
      case 'Tidak Enak': return 1.0;
      default: return 3.0;
    }
  }

  /// Skor tekstur: 1-5 berdasarkan pilihan
  double get textureScore {
    switch (texture) {
      case 'Sangat Baik': return 5.0;
      case 'Baik': return 4.0;
      case 'Pas': return 3.0;
      case 'Kurang Baik': return 2.0;
      case 'Tidak Baik': return 1.0;
      default: return 3.0;
    }
  }

  /// Skor aroma: 1-5 berdasarkan pilihan
  double get aromaScore {
    switch (aroma) {
      case 'Sangat Sedap': return 5.0;
      case 'Sedap': return 4.0;
      case 'Biasa': return 3.0;
      case 'Kurang Sedap': return 2.0;
      case 'Tidak Sedap': return 1.0;
      default: return 3.0;
    }
  }

  /// Skor keseluruhan sensorik (rata-rata)
  double get overallScore => (tasteScore + textureScore + aromaScore) / 3;

  factory SensoryData.fromJson(Map<String, dynamic> json) {
    return SensoryData(
      taste: json['taste'] as String? ?? 'Biasa',
      saltLevel: json['salt_level'] as String? ?? 'Pas',
      sweetLevel: json['sweet_level'] as String? ?? 'Pas',
      texture: json['texture'] as String? ?? 'Pas',
      aroma: json['aroma'] as String? ?? 'Biasa',
    );
  }

  Map<String, dynamic> toJson() => {
    'taste': taste,
    'salt_level': saltLevel,
    'sweet_level': sweetLevel,
    'texture': texture,
    'aroma': aroma,
  };
}

/// Model untuk data konsumsi (indikator seberapa banyak dimakan)
class ConsumptionData {
  final String portionSize;    // Penuh, 3/4, 1/2, 1/4, Sedikit
  final String leftoverAmount; // Tidak ada, Sedikit, Setengah, Banyak, Semua
  final bool isFinished;       // Apakah dihabiskan

  const ConsumptionData({
    required this.portionSize,
    required this.leftoverAmount,
    required this.isFinished,
  });

  /// Persentase makanan yang dikonsumsi (0-100)
  double get consumptionPercentage {
    switch (portionSize) {
      case 'Penuh (100%)': return 100.0;
      case '3/4 Porsi (75%)': return 75.0;
      case '1/2 Porsi (50%)': return 50.0;
      case '1/4 Porsi (25%)': return 25.0;
      case 'Sedikit (<25%)': return 10.0;
      default: return isFinished ? 100.0 : 50.0;
    }
  }

  /// Persentase sisa makanan (0-100)
  double get leftoverPercentage => 100.0 - consumptionPercentage;

  /// Skor porsi: 1-5 berdasarkan konsumsi
  double get portionScore {
    final pct = consumptionPercentage;
    if (pct >= 90) return 5.0;
    if (pct >= 75) return 4.0;
    if (pct >= 50) return 3.0;
    if (pct >= 25) return 2.0;
    return 1.0;
  }

  factory ConsumptionData.fromJson(Map<String, dynamic> json) {
    return ConsumptionData(
      portionSize: json['portion_size'] as String? ?? 'Penuh (100%)',
      leftoverAmount: json['leftover_amount'] as String? ?? 'Tidak ada',
      isFinished: json['is_finished'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'portion_size': portionSize,
    'leftover_amount': leftoverAmount,
    'is_finished': isFinished,
  };
}

/// Hasil analisis gizi lengkap setelah menggabungkan semua data
class NutritionAnalysisResult {
  // Estimasi gizi (disesuaikan porsi)
  final double estimatedCalories;
  final double estimatedProtein;
  final double estimatedCarbs;
  final double estimatedFat;
  final double estimatedFiber;

  // Skor sensorik
  final double tasteScore;      // 1-5
  final double textureScore;    // 1-5
  final double aromaScore;      // 1-5

  // Data konsumsi
  final double portionScore;           // 1-5
  final double consumptionPercentage;  // 0-100
  final double leftoverPercentage;     // 0-100

  // Indikator sensorik tambahan
  final String saltLevel;
  final String sweetLevel;

  const NutritionAnalysisResult({
    required this.estimatedCalories,
    required this.estimatedProtein,
    required this.estimatedCarbs,
    required this.estimatedFat,
    required this.estimatedFiber,
    required this.tasteScore,
    required this.textureScore,
    required this.aromaScore,
    required this.portionScore,
    required this.consumptionPercentage,
    required this.leftoverPercentage,
    required this.saltLevel,
    required this.sweetLevel,
  });

  /// Buat hasil analisis dari data yang terkumpul
  factory NutritionAnalysisResult.compute({
    required double baseCalories,
    required double baseProtein,
    required double baseCarbs,
    required double baseFat,
    required double baseFiber,
    required SensoryData sensory,
    required ConsumptionData consumption,
  }) {
    final ratio = consumption.consumptionPercentage / 100.0;
    return NutritionAnalysisResult(
      estimatedCalories: baseCalories * ratio,
      estimatedProtein: baseProtein * ratio,
      estimatedCarbs: baseCarbs * ratio,
      estimatedFat: baseFat * ratio,
      estimatedFiber: baseFiber * ratio,
      tasteScore: sensory.tasteScore,
      textureScore: sensory.textureScore,
      aromaScore: sensory.aromaScore,
      portionScore: consumption.portionScore,
      consumptionPercentage: consumption.consumptionPercentage,
      leftoverPercentage: consumption.leftoverPercentage,
      saltLevel: sensory.saltLevel,
      sweetLevel: sensory.sweetLevel,
    );
  }

  Map<String, dynamic> toJson() => {
    'estimated_calories': estimatedCalories,
    'estimated_protein': estimatedProtein,
    'estimated_carbs': estimatedCarbs,
    'estimated_fat': estimatedFat,
    'estimated_fiber': estimatedFiber,
    'taste_score': tasteScore,
    'texture_score': textureScore,
    'aroma_score': aromaScore,
    'portion_score': portionScore,
    'consumption_percentage': consumptionPercentage,
    'leftover_percentage': leftoverPercentage,
    'salt_level': saltLevel,
    'sweet_level': sweetLevel,
  };
}
