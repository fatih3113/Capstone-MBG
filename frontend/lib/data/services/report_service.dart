import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_response.dart';
import '../models/report_models.dart';

/// Service untuk semua fitur Report MBG:
/// - Permintaan Menu
/// - Rating Makanan Favorit
/// - Feedback Makanan & Status Konsumsi
class ReportService {
  // Toggle ke false untuk koneksi API nyata
  static const bool _useMock = true;

  // ═══════════════════════════════════════════════
  // MENU REQUESTS
  // ═══════════════════════════════════════════════

  Future<ApiResponse<MenuRequestModel>> submitMenuRequest({
    required String menuName,
    String? reason,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse.success(
        data: MenuRequestModel(
          id: 'mr_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'mock_user',
          menuName: menuName,
          reason: reason,
          status: 'received',
          adminNote: null,
          submittedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        message: 'Usulan menu berhasil dikirim',
      );
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.menuRequests,
        data: {'menuName': menuName, 'reason': reason},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => MenuRequestModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<List<MenuRequestModel>>> getMyMenuRequests() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(data: _mockMenuRequests());
    }

    try {
      final response = await DioClient.instance.get(ApiConstants.menuRequestsMy);
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List)
            .map((e) => MenuRequestModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════
  // FOOD RATINGS
  // ═══════════════════════════════════════════════

  Future<ApiResponse<FoodRatingModel>> submitFoodRating({
    required String foodName,
    required int rating,
    String? reason,
    String? foodId,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(
        data: FoodRatingModel(
          id: 'fr_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'mock_user',
          foodId: foodId,
          foodName: foodName,
          rating: rating,
          reason: reason,
          ratedAt: DateTime.now(),
        ),
        message: 'Rating berhasil disimpan',
      );
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.foodRatings,
        data: {
          'foodName': foodName,
          'rating': rating,
          'reason': reason,
          'foodId': foodId,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => FoodRatingModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<List<FoodRankingModel>>> getFoodRanking({
    String? startDate,
    String? endDate,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(data: _mockRanking());
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.foodRatingsRanking,
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List)
            .map((e) => FoodRankingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<List<FoodRatingModel>>> getMyFoodRatings() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(data: []);
    }

    try {
      final response = await DioClient.instance.get(ApiConstants.foodRatingsMy);
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List)
            .map((e) => FoodRatingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════
  // FOOD FEEDBACKS
  // ═══════════════════════════════════════════════

  Future<ApiResponse<FoodFeedbackModel>> submitFoodFeedback({
    required String foodName,
    String? foodId,
    int? tasteRating,
    int? textureRating,
    int? aromaRating,
    int? portionRating,
    int? satisfactionRating,
    String? consumptionStatus,
    String? suggestion,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse.success(
        data: FoodFeedbackModel(
          id: 'ff_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'mock_user',
          foodId: foodId,
          foodName: foodName,
          tasteRating: tasteRating,
          textureRating: textureRating,
          aromaRating: aromaRating,
          portionRating: portionRating,
          satisfactionRating: satisfactionRating,
          consumptionStatus: consumptionStatus,
          suggestion: suggestion,
          submittedAt: DateTime.now(),
        ),
        message: 'Feedback berhasil dikirim',
      );
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.foodFeedbacks,
        data: {
          'foodName': foodName,
          'foodId': foodId,
          'tasteRating': tasteRating,
          'textureRating': textureRating,
          'aromaRating': aromaRating,
          'portionRating': portionRating,
          'satisfactionRating': satisfactionRating,
          'consumptionStatus': consumptionStatus,
          'suggestion': suggestion,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => FoodFeedbackModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── Mock data ────────────────────────────────────────────────────────────

  static List<MenuRequestModel> _mockMenuRequests() {
    final now = DateTime.now();
    return [
      MenuRequestModel(
        id: 'mr_1',
        userId: 'u1',
        menuName: 'Soto Ayam',
        reason: 'Makanan bergizi dan disukai banyak siswa',
        status: 'reviewing',
        adminNote: null,
        submittedAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      MenuRequestModel(
        id: 'mr_2',
        userId: 'u1',
        menuName: 'Pecel Lele',
        reason: 'Lauk favorit siswa, murah dan bergizi',
        status: 'considered',
        adminNote: 'Akan dimasukkan dalam jadwal bulan depan',
        submittedAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<FoodRankingModel> _mockRanking() {
    return [
      const FoodRankingModel(
          rank: 1, foodName: 'Ayam Goreng', voteCount: 45, avgRating: 4.8),
      const FoodRankingModel(
          rank: 2, foodName: 'Nasi Putih', voteCount: 42, avgRating: 4.5),
      const FoodRankingModel(
          rank: 3, foodName: 'Telur Rebus', voteCount: 38, avgRating: 4.3),
      const FoodRankingModel(
          rank: 4, foodName: 'Tempe Goreng', voteCount: 35, avgRating: 4.2),
      const FoodRankingModel(
          rank: 5, foodName: 'Pisang', voteCount: 30, avgRating: 4.0),
    ];
  }
}
