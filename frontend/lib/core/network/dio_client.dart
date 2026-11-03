// File ini mengatur konfigurasi klien HTTP Dio, interceptor token autentikasi, logging, dan penerjemahan pesan error.

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

// DioClient: kelas singleton penyedia instance Dio terkonfigurasi untuk seluruh panggilan HTTP ke backend.
class DioClient {
  static Dio? _dio;

  // Mengambil instance Dio atau membuat instance baru jika belum ada.
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  // Konfigurasi dasar Dio: baseUrl, batas timeout, dan interceptor.
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBase,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }

  // Mereset instance Dio (misalnya saat logout atau ganti konfigurasi server).
  static void reset() {
    _dio = null;
  }
}

/// Automatically attaches Bearer token to requests
// _AuthInterceptor: menyisipkan Bearer token otomatis di header Authorization dari SharedPreferences.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Hanya hapus sesi jika 401 bukan dari endpoint login (login salah password ≠ sesi expired)
      final path = err.requestOptions.path;
      final isLoginEndpoint = path.contains('/auth/login') || path.contains('/auth/register');
      if (!isLoginEndpoint) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.keyToken);
        await prefs.remove(AppConstants.keyUser);
      }
    }
    handler.next(err);
  }
}

/// Logging for debug mode
// _LoggingInterceptor: mencetak jejak request, respons, dan error HTTP ke konsol untuk keperluan debugging.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] Response ${response.statusCode}: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] Error ${err.response?.statusCode}: ${err.message}');
    handler.next(err);
  }
}

/// Translates DioException into readable error messages
// _ErrorInterceptor: menerjemahkan status kode dan kendala jaringan menjadi pesan error berbahasa Indonesia yang ramah pengguna.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final customError = _mapError(err);
    handler.next(customError);
  }

  DioException _mapError(DioException err) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Koneksi timeout. Periksa jaringan internet Anda.';
        break;
      case DioExceptionType.connectionError:
        message = 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(err.response?.statusCode);
        break;
      default:
        message = 'Terjadi kesalahan. Silakan coba lagi.';
    }
    return err.copyWith(message: message);
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid.';
      case 401:
        return 'Sesi Anda telah berakhir. Silakan login kembali.';
      case 403:
        return 'Anda tidak memiliki akses ke fitur ini.';
      case 404:
        return 'Data tidak ditemukan.';
      case 422:
        return 'Data yang dikirim tidak valid.';
      case 500:
        return 'Terjadi kesalahan pada server. Coba beberapa saat lagi.';
      default:
        return 'Terjadi kesalahan. Kode: $statusCode';
    }
  }
}
