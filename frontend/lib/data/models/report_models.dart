// ─── Menu Request Model ────────────────────────────────────────────────────
class MenuRequestModel {
  final String id;
  final String userId;
  final String menuName;
  final String? reason;
  final String status;
  final String? adminNote;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const MenuRequestModel({
    required this.id,
    required this.userId,
    required this.menuName,
    this.reason,
    required this.status,
    this.adminNote,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory MenuRequestModel.fromJson(Map<String, dynamic> json) {
    return MenuRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      menuName: json['menuName'] as String,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'received',
      adminNote: json['adminNote'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'received':
        return 'Diterima';
      case 'reviewing':
        return 'Sedang Ditinjau';
      case 'considered':
        return 'Dipertimbangkan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

// ─── Food Rating Model ─────────────────────────────────────────────────────
class FoodRatingModel {
  final String id;
  final String userId;
  final String? foodId;
  final String foodName;
  final int rating;
  final String? reason;
  final DateTime ratedAt;

  const FoodRatingModel({
    required this.id,
    required this.userId,
    this.foodId,
    required this.foodName,
    required this.rating,
    this.reason,
    required this.ratedAt,
  });

  factory FoodRatingModel.fromJson(Map<String, dynamic> json) {
    return FoodRatingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      foodId: json['foodId'] as String?,
      foodName: json['foodName'] as String,
      rating: json['rating'] as int,
      reason: json['reason'] as String?,
      ratedAt: DateTime.parse(json['ratedAt'] as String),
    );
  }
}

// ─── Food Rating Ranking Model ─────────────────────────────────────────────
class FoodRankingModel {
  final int rank;
  final String foodName;
  final int voteCount;
  final double avgRating;

  const FoodRankingModel({
    required this.rank,
    required this.foodName,
    required this.voteCount,
    required this.avgRating,
  });

  factory FoodRankingModel.fromJson(Map<String, dynamic> json) {
    return FoodRankingModel(
      rank: json['rank'] as int,
      foodName: json['foodName'] as String,
      voteCount: json['voteCount'] as int,
      avgRating: (json['avgRating'] as num).toDouble(),
    );
  }
}

// ─── Food Feedback Model ───────────────────────────────────────────────────
class FoodFeedbackModel {
  final String id;
  final String userId;
  final String? foodId;
  final String foodName;
  final int? tasteRating;
  final int? textureRating;
  final int? aromaRating;
  final int? portionRating;
  final int? satisfactionRating;
  final String? consumptionStatus; // 'habis' | 'sebagian' | 'hampir_tidak'
  final String? suggestion;
  final DateTime submittedAt;

  const FoodFeedbackModel({
    required this.id,
    required this.userId,
    this.foodId,
    required this.foodName,
    this.tasteRating,
    this.textureRating,
    this.aromaRating,
    this.portionRating,
    this.satisfactionRating,
    this.consumptionStatus,
    this.suggestion,
    required this.submittedAt,
  });

  factory FoodFeedbackModel.fromJson(Map<String, dynamic> json) {
    return FoodFeedbackModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      foodId: json['foodId'] as String?,
      foodName: json['foodName'] as String,
      tasteRating: json['tastRating'] as int?,
      textureRating: json['textureRating'] as int?,
      aromaRating: json['aromaRating'] as int?,
      portionRating: json['portionRating'] as int?,
      satisfactionRating: json['satisfactionRating'] as int?,
      consumptionStatus: json['consumptionStatus'] as String?,
      suggestion: json['suggestion'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  String get consumptionStatusLabel {
    switch (consumptionStatus) {
      case 'habis':
        return 'Habis Dimakan';
      case 'sebagian':
        return 'Sebagian Tersisa';
      case 'hampir_tidak':
        return 'Hampir Tidak Dimakan';
      default:
        return 'Tidak Diisi';
    }
  }
}
