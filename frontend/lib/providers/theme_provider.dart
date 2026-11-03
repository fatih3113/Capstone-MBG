// State management tema: mengontrol perpindahan mode tema terang dan gelap aplikasi serta menyimpannya ke memori lokal SharedPreferences.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

// ChangeNotifier: kelas state management yang memberitahu widget pendengar (listeners) setiap kali mode tema aplikasi berubah.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Membaca preferensi mode tema yang tersimpan di perangkat saat aplikasi pertama kali dinyalakan.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConstants.keyThemeMode) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Mengubah tema kebalikan dari tema saat ini (terang ke gelap atau sebaliknya).
  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyThemeMode, isDarkMode);
    notifyListeners();
  }

  // Menetapkan mode tema tertentu secara langsung (ThemeMode.light, dark, atau system).
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyThemeMode, mode == ThemeMode.dark);
    notifyListeners();
  }
}
