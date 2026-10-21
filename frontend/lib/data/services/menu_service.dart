import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/mbg_menu_model.dart';
import '../dummy/dummy_data.dart';

class MenuService {
  static const bool _useMock = false;

  Future<ApiResponse<List<MbgMenuModel>>> getWeeklyMenu({
    String? schoolId,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return ApiResponse.success(
        data: DummyData.getMbgMenusForWeek(),
        message: 'Berhasil mengambil menu MBG',
      );
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.mbgMenu,
        queryParameters: {'school_id': schoolId},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => MbgMenuModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse<MbgMenuModel>> getMenuByDate({
    required DateTime date,
    String? schoolId,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final menus = DummyData.getMbgMenusForWeek();
      final menu = menus.firstWhere(
        (m) => m.date.day == date.day && m.date.month == date.month,
        orElse: () => menus.first,
      );
      return ApiResponse.success(data: menu);
    }

    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await DioClient.instance.get(
        ApiConstants.mbgMenuByDate.replaceAll('{date}', dateStr),
        queryParameters: {'school_id': schoolId},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => MbgMenuModel.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
