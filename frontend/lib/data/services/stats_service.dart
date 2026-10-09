import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/daily_nutrition_model.dart';
import '../dummy/dummy_data.dart';

/// Service untuk mengambil statistik gizi pengguna
/// Mendukung mode mock (offline) dan live API
class StatsService {
  /// Ubah ke [true] untuk mode offline/development
  static const bool _useMock = false;

  /// Ambil statistik gizi hari ini
  Future<ApiResponse<DailyNutritionModel?>> getDailyStats({
    DateTime? date,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final daily = DummyData.getDailyNutrition('user1');
      final today = daily.isNotEmpty ? daily.first : null;
      return ApiResponse.success(data: today);
    }
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      final response = await DioClient.instance.get(
        ApiConstants.statsDaily,
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data != null ? DailyNutritionModel.fromJson(data) : null,
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Ambil statistik gizi 7 hari terakhir (Data Warehouse)
  /// Backend mengembalikan: { daily: [...], summary: {...} }
  Future<ApiResponse<List<DailyNutritionModel>>> getWeeklyStats() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse.success(data: DummyData.getDailyNutrition('user1'));
    }
    try {
      final response = await DioClient.instance.get(ApiConstants.statsWeekly);
      return ApiResponse.fromJson(
        response.data,
        (data) {
          // Backend returns { daily: [...], summary: {...} }
          final List<dynamic> dailyList =
              (data is Map && data.containsKey('daily'))
                  ? data['daily'] as List<dynamic>
                  : data as List<dynamic>;
          return dailyList
              .map((e) => DailyNutritionModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Ambil ringkasan statistik user
  Future<ApiResponse<Map<String, dynamic>>> getSummary() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse.success(data: {
        'totalScans': 12,
        'weeklyAvgCalories': 1850,
        'daysLogged': 5,
      });
    }
    try {
      final response = await DioClient.instance.get(ApiConstants.statsSummary);
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Ambil makanan paling sering dikonsumsi (Data Warehouse)
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopFoods({
    int limit = 5,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse.success(data: [
        {'food': {'name': 'Nasi Putih', 'category': 'Karbohidrat'}, 'count': 8},
        {'food': {'name': 'Ayam Goreng', 'category': 'Protein Hewani'}, 'count': 6},
        {'food': {'name': 'Pisang', 'category': 'Buah'}, 'count': 5},
        {'food': {'name': 'Sayur Bayam', 'category': 'Sayuran'}, 'count': 4},
        {'food': {'name': 'Susu Putih', 'category': 'Minuman'}, 'count': 3},
      ]);
    }
    try {
      final response = await DioClient.instance.get(
        ApiConstants.statsTopFoods,
        queryParameters: {'limit': limit},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Ambil rekomendasi gizi berbasis rule (Pemrograman Sistem Cerdas)
  Future<ApiResponse<Map<String, dynamic>>> getNutritionRecommendation() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(data: {
        'target': {
          'caloriesTarget': 1850,
          'proteinTarget': 49,
          'carbsTarget': 265,
          'fatTarget': 62,
          'fiberTarget': 22,
        },
        'consumed': {
          'calories': 1250,
          'protein': 32,
          'carbs': 175,
          'fat': 40,
          'fiber': 14,
        },
        'remaining': {
          'calories': 600,
          'protein': 17,
          'carbs': 90,
          'fat': 22,
          'fiber': 8,
        },
        'status': 'kurang',
        'message': 'Asupan kalori hari ini masih kurang. Tambahkan makanan bergizi.',
        'percentage': 68,
      });
    }
    try {
      final response = await DioClient.instance.get(
        ApiConstants.nutritionRecommendation,
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
