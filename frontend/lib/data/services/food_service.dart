import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/food_model.dart';
import '../models/nutrition_model.dart';
import '../dummy/dummy_data.dart';

class FoodService {
  static const bool _useMock = false;

  Future<ApiResponse<List<FoodModel>>> getAllFoods() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse.success(data: DummyData.foods);
    }
    try {
      final response = await DioClient.instance.get(ApiConstants.foods);
      return ApiResponse.fromJson(response.data,
        (data) => (data as List).map((e) => FoodModel.fromJson(e)).toList());
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<NutritionModel>> getNutritionByFoodId(String foodId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      final nutrition = DummyData.getNutritionByFoodId(foodId);
      if (nutrition != null) {
        return ApiResponse.success(data: nutrition);
      }
      return ApiResponse.error(message: 'Data gizi tidak ditemukan');
    }
    try {
      final response = await DioClient.instance.get(
        ApiConstants.nutritionByFood.replaceAll('{foodId}', foodId));
      return ApiResponse.fromJson(response.data,
        (data) => NutritionModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<List<NutritionModel>>> getNutritionByFoodIds(
    List<String> foodIds) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final result = foodIds
          .map((id) => DummyData.getNutritionByFoodId(id))
          .where((n) => n != null)
          .cast<NutritionModel>()
          .toList();
      return ApiResponse.success(data: result);
    }
    try {
      final response = await DioClient.instance.get(
        ApiConstants.nutrition,
        queryParameters: {'food_ids': foodIds.join(',')},
      );
      return ApiResponse.fromJson(response.data,
        (data) => (data as List).map((e) => NutritionModel.fromJson(e)).toList());
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<List<FoodModel>>> searchFoods(String query) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final results = DummyData.foods
          .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return ApiResponse.success(data: results);
    }
    try {
      final response = await DioClient.instance.get(
        ApiConstants.foodSearch,
        queryParameters: {'q': query},
      );
      return ApiResponse.fromJson(response.data,
        (data) => (data as List).map((e) => FoodModel.fromJson(e)).toList());
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
