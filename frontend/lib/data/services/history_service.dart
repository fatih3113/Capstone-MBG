import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/scan_history_model.dart';
import '../models/prediction_model.dart';
import '../models/evaluation_model.dart';
import '../dummy/dummy_data.dart';

/// Ekstrak pesan error dari backend Dio response
String _backendError(Object e, [String fallback = 'Terjadi kesalahan. Coba lagi.']) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) return data['message']?.toString() ?? fallback;
  }
  return fallback;
}

/// Service for scan history operations
class HistoryService {
  /// Ubah ke [true] untuk mode offline/development
  static const bool _useMock = false;

  Future<ApiResponse<List<ScanHistoryModel>>> getScanHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResponse.success(
        data: DummyData.getScanHistory(userId),
        message: 'Berhasil mengambil riwayat scan',
      );
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.scanHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      // Backend returns paginated: { success, data: [...], total, current_page, ... }
      final body = response.data as Map<String, dynamic>;
      final rawList = body['data'] as List<dynamic>? ?? [];
      final history = rawList
          .map((e) => ScanHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(
        data: history,
        message: body['message'] as String? ?? 'Berhasil',
      );
    } catch (e) {
      return ApiResponse.error(message: _backendError(e, 'Gagal mengambil riwayat scan.'));
    }
  }

  Future<ApiResponse<ScanHistoryModel>> saveScan({
    required String userId,
    required File imageFile,
    required List<PredictionModel> predictions,
    required double totalCalories,
    required double totalProtein,
    required double totalCarbs,
    required double totalFat,
    required double totalFiber,
    SensoryData? sensoryData,
    ConsumptionData? consumptionData,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 700));
      final history = ScanHistoryModel(
        id: 'sh_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        localImagePath: imageFile.path,
        scannedAt: DateTime.now(),
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        totalFiber: totalFiber,
        predictions: predictions,
        status: 'success',
      );
      return ApiResponse.success(data: history, message: 'Scan berhasil disimpan');
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.saveScan,
        data: {
          'user_id': userId,
          'image_url': '', // upload first, then provide URL
          'total_calories': totalCalories,
          'total_protein': totalProtein,
          'total_carbs': totalCarbs,
          'total_fat': totalFat,
          'total_fiber': totalFiber,
          'predictions': predictions.map((p) => p.toJson()).toList(),
          if (sensoryData != null) 'sensory_data': sensoryData.toJson(),
          if (consumptionData != null) 'consumption_data': consumptionData.toJson(),
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => ScanHistoryModel.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(message: _backendError(e, 'Gagal menyimpan hasil scan.'));
    }
  }

  Future<ApiResponse<ScanHistoryModel>> getScanDetail(String scanId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final history = DummyData.getScanHistory('user1')
          .firstWhere((h) => h.id == scanId, orElse: () => DummyData.getScanHistory('user1').first);
      return ApiResponse.success(data: history);
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.scanHistoryDetail.replaceAll('{id}', scanId),
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => ScanHistoryModel.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(message: _backendError(e, 'Gagal mengambil detail scan.'));
    }
  }
}
