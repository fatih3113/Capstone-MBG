import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  String? _token;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  String get userName => _user?.name ?? 'Pengguna';

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final cachedUser = await _authService.getCachedUser();
    if (cachedUser != null) {
      _user = cachedUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.login(email: email, password: password);

    if (response.success && response.data != null) {
      _token = response.data!['token'] as String?;
      final userData = response.data!['user'] as Map<String, dynamic>?;
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        await _authService.cacheUser(_user!);
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? age,
    String? sppgId,
    List<String>? allergies,
    String? allergyOther,
    bool? allergyFilled,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.register(
      name: name,
      email: email,
      password: password,
      gender: gender,
      age: age,
      sppgId: sppgId,
      allergies: allergies,
      allergyOther: allergyOther,
      allergyFilled: allergyFilled,
    );

    if (response.success) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Simpan alergi ke server, lalu perbarui data & cache lokal.
  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  /// (Sengaja tidak mengubah [status] agar layar lain tidak ikut berkedip.)
  Future<String?> updateAllergies({
    required List<String> allergies,
    String? allergyOther,
  }) async {
    final current = _user;
    if (current == null) {
      return 'Sesi tidak ditemukan. Silakan login kembali.';
    }

    final response = await _authService.updateAllergies(
      allergies: allergies,
      allergyOther: allergyOther,
    );
    if (!response.success) return response.message;

    // Pakai nilai yang dikonfirmasi server; jika tidak ada, pakai yang dikirim
    final data = response.data ?? const <String, dynamic>{};
    final savedAllergies = (data['allergies'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        allergies;
    final savedOther = data.containsKey('allergy_other')
        ? data['allergy_other'] as String?
        : allergyOther;

    updateUser(current.withAllergy(
      allergies: savedAllergies,
      allergyOther: savedOther,
    ));
    return null;
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    _authService.cacheUser(updatedUser);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}