// State management menu makanan MBG: mengelola daftar hidangan bergizi mingguan, seleksi hari aktif (Senin - Jumat), dan deteksi otomatis menu hari ini.
import 'package:flutter/foundation.dart';
import '../data/models/mbg_menu_model.dart';
import '../data/services/menu_service.dart';

// ChangeNotifier: kelas pengelola state jadwal menu makanan harian yang memberi tahu widget saat data menu berubah.
class MenuProvider extends ChangeNotifier {
  final MenuService _menuService;
  MenuProvider(this._menuService);

  List<MbgMenuModel> _weeklyMenus = [];
  MbgMenuModel? _selectedMenu;
  bool _isLoading = false;
  String? _error;
  int _selectedDayIndex = 0;

  List<MbgMenuModel> get weeklyMenus => _weeklyMenus;
  MbgMenuModel? get selectedMenu => _selectedMenu;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedDayIndex => _selectedDayIndex;

  // Menentukan menu makanan yang berlaku untuk hari ini berdasarkan nomor hari (Senin=1 hingga Jumat=5).
  MbgMenuModel? get todayMenu {
    if (_weeklyMenus.isEmpty) return null;
    final today = DateTime.now().weekday; // 1=Mon, 5=Fri
    if (today >= 1 && today <= 5) {
      return _weeklyMenus.length >= today ? _weeklyMenus[today - 1] : null;
    }
    return _weeklyMenus.isNotEmpty ? _weeklyMenus.first : null;
  }

  // Mengambil daftar menu makanan 5 hari sekolah dari server untuk sekolah yang terdaftar.
  Future<void> loadWeeklyMenu({String? schoolId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _menuService.getWeeklyMenu(schoolId: schoolId);
    if (response.success && response.data != null) {
      _weeklyMenus = response.data!;
      if (_weeklyMenus.isNotEmpty) {
        _selectedMenu = _weeklyMenus[_selectedDayIndex];
      }
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Memilih hari tertentu (misal: Selasa atau Rabu) pada tab pemilih hari di halaman menu.
  void selectDay(int index) {
    _selectedDayIndex = index;
    if (index < _weeklyMenus.length) {
      _selectedMenu = _weeklyMenus[index];
    }
    notifyListeners();
  }
}
