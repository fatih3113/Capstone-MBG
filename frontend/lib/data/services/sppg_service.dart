/// Service untuk mengambil data SPPG dan wilayah dari endpoint publik backend
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../models/sppg_model.dart';

class SppgService {
  // ── REGIONS (wilayah bertingkat) ────────────────────────────────────────

  /// Ambil daftar provinsi yang memiliki SPPG aktif
  Future<ApiResponse<List<String>>> getProvinces() async {
    return _getRegions(level: 'provinsi');
  }

  /// Ambil daftar kabupaten/kota dalam provinsi yang memiliki SPPG aktif
  Future<ApiResponse<List<String>>> getKabupaten(String provinsi) async {
    return _getRegions(level: 'kabupaten', parent: provinsi);
  }

  /// Ambil daftar kecamatan dalam kabupaten/kota yang memiliki SPPG aktif
  Future<ApiResponse<List<String>>> getKecamatan(String kabupatenKota) async {
    return _getRegions(level: 'kecamatan', parent: kabupatenKota);
  }

  Future<ApiResponse<List<String>>> _getRegions({
    required String level,
    String? parent,
  }) async {
    try {
      final queryParams = <String, dynamic>{'level': level};
      if (parent != null) queryParams['parent'] = parent;

      final response = await DioClient.instance.get(
        ApiConstants.sppgRegions,
        queryParameters: queryParams,
      );
      final apiResp = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );
      if (!apiResp.success) {
        return ApiResponse.error(message: apiResp.message);
      }
      final regions = (apiResp.data ?? []).map((e) => e.toString()).toList();
      return ApiResponse.success(data: regions, message: apiResp.message);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      return ApiResponse.error(message: msg ?? 'Gagal memuat wilayah');
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan. Coba lagi.');
    }
  }

  // ── SPPG LIST ────────────────────────────────────────────────────────────

  /// Ambil daftar SPPG aktif berdasarkan filter wilayah
  Future<ApiResponse<List<SppgModel>>> getSppgList({
    String? provinsi,
    String? kabupatenKota,
    String? kecamatan,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (provinsi != null) queryParams['provinsi'] = provinsi;
      if (kabupatenKota != null) queryParams['kabupatenKota'] = kabupatenKota;
      if (kecamatan != null) queryParams['kecamatan'] = kecamatan;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await DioClient.instance.get(
        ApiConstants.sppg,
        queryParameters: queryParams,
      );
      final apiResp = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );
      if (!apiResp.success) {
        return ApiResponse.error(message: apiResp.message);
      }
      final sppgs = (apiResp.data ?? [])
          .map((e) => SppgModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(data: sppgs, message: apiResp.message);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      return ApiResponse.error(message: msg ?? 'Gagal memuat daftar SPPG');
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan. Coba lagi.');
    }
  }
}
