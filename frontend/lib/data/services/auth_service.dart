import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../dummy/dummy_data.dart';

/// Authentication service.
/// Uses mock data when USE_MOCK = true.
/// Toggle to false and set real base URL for production.
class AuthService {
  static const bool _useMock = false; // Toggle for production

  // ─── LOGIN ────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    if (_useMock) return _mockLogin(email, password);

    try {
      final response = await DioClient.instance.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
      // Simpan token ke SharedPreferences agar request berikutnya terautentikasi
      if (apiResponse.success && apiResponse.data != null) {
        final token = apiResponse.data!['token'] as String?;
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.keyToken, token);
        }
      }
      return apiResponse;
    } on DioException catch (e) {
      // Ambil pesan error dari response backend jika ada
      final backendMessage = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      return ApiResponse.error(
        message: backendMessage ?? e.message ?? 'Login gagal. Periksa email dan password.',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  // ─── REGISTER ─────────────────────────────────────────────────────
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? schoolId,
    String? sppgId,
    String? className,
    String? gender,
    int? age,
    List<String>? allergies,
    String? allergyOther,
    bool? allergyFilled,
  }) async {
    if (_useMock) return _mockRegister(name, email);

    try {
      final response = await DioClient.instance.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'school_id': schoolId,
          'sppg_id': sppgId,
          'class': className,
          'gender': gender,
          'age': age,
          'allergies': allergies,
          'allergy_other': allergyOther,
          'allergy_filled': allergyFilled,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // Tampilkan pesan dari backend (mis. validasi alergi) jika ada
      return ApiResponse.error(
        message: _backendMessage(e) ?? e.message ?? 'Registrasi gagal.',
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ─── UPDATE ALERGI ────────────────────────────────────────────────
  /// Simpan data alergi pemilik akun ke server (PUT /users/profile/update).
  /// Respons berisi `allergies`, `allergy_other`, `allergy_filled`.
  Future<ApiResponse<Map<String, dynamic>>> updateAllergies({
    required List<String> allergies,
    String? allergyOther,
  }) async {
    final payload = {
      'allergies': allergies,
      'allergy_other': allergyOther,
      'allergy_filled': true,
    };
    if (_useMock) {
      return ApiResponse.success(
        data: payload,
        message: 'Profil berhasil diperbarui',
      );
    }

    try {
      final response = await DioClient.instance.put(
        ApiConstants.updateProfile,
        data: payload,
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _backendMessage(e) ??
            e.message ??
            'Gagal menyimpan data alergi. Coba lagi.',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  // ─── UPDATE PROFIL LENGKAP ────────────────────────────────────────
  /// Simpan profil (nama, umur, gender, kelas, sekolah, SPPG, alergi)
  /// ke server lewat PUT /users/profile/update.
  /// Data dikirim dengan key yang sama seperti saat register.
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String name,
    int? age,
    String? gender,
    String? className,
    String? schoolId,
    String? sppgId,
    List<String>? allergies,
    String? allergyOther,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'age': age,
      'gender': gender,
      'class': className,
      if (schoolId != null) 'school_id': schoolId,
      if (sppgId != null) 'sppg_id': sppgId,
      if (allergies != null) ...{
        'allergies': allergies,
        'allergy_other': allergyOther,
        'allergy_filled': true,
      },
    };
    if (_useMock) {
      return ApiResponse.success(
        data: payload,
        message: 'Profil berhasil diperbarui',
      );
    }

    try {
      final response = await DioClient.instance.put(
        ApiConstants.updateProfile,
        data: payload,
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{},
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _backendMessage(e) ??
            e.message ??
            'Gagal menyimpan profil. Coba lagi.',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  /// Ambil pesan error dari body respons backend (jika ada).
  String? _backendMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUser);
    if (!_useMock) {
      try {
        await DioClient.instance.post(ApiConstants.logout);
      } catch (_) {}
    }
  }

  // ─── GET CACHED USER ──────────────────────────────────────────────
  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.keyUser);
    if (json != null) {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
  }

  bool isLoggedIn(String? token) => token != null && token.isNotEmpty;

  // ─── MOCK IMPLEMENTATIONS ─────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> _mockLogin(
    String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Accept any email/password for demo
    if (email.isEmpty || password.isEmpty) {
      return ApiResponse.error(message: 'Email dan password tidak boleh kosong');
    }
    if (password.length < 6) {
      return ApiResponse.error(message: 'Password salah');
    }

    final user = DummyData.demoUser.copyWith(email: email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyToken, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));

    return ApiResponse.success(
      data: {'token': 'mock_token', 'user': user.toJson()},
      message: 'Login berhasil',
    );
  }

  Future<ApiResponse<UserModel>> _mockRegister(String name, String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final user = DummyData.demoUser.copyWith(name: name, email: email);
    return ApiResponse.success(data: user, message: 'Registrasi berhasil');
  }
}