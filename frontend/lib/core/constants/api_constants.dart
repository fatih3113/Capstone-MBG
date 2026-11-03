// File ini menyimpan seluruh endpoint URL API backend dan konfigurasi dasar koneksi jaringan.

// ApiConstants: tempat terpusat untuk mendefinisikan rute endpoint agar pemanggilan API konsisten di seluruh aplikasi.
class ApiConstants {
  ApiConstants._();

  // ── Base URL ────────────────────────────────────────────────────────────────
  // Pakai USB + ADB reverse port forwarding:
  //   Jalankan sekali di terminal PC:
  //   > adb reverse tcp:3000 tcp:3000
  //   Setelah itu, 'localhost:3000' di device = backend di PC kamu.
  //
  // Kalau TANPA ADB (Wi-Fi biasa), ganti ke IP Wi-Fi PC:
  //   return 'http://192.168.0.113:$_port';
  static const String _port = '3000';

  // baseUrl: getter alamat server utama backend, disesuaikan untuk pengujian lokal.
  static String get baseUrl {
    // Dengan ADB reverse, semua platform pakai localhost
    return 'http://localhost:$_port';
  }

  static const String apiVersion = '/api/v1';
  static String get apiBase => baseUrl + apiVersion;

  // Batas waktu timeout permintaan jaringan (dalam milidetik).
  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms

  // Endpoint untuk autentikasi pengguna (login, daftar, reset password).
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Endpoint manajemen profil pengguna.
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile/update';
  static const String uploadProfilePhoto = '/users/profile/photo';

  // Endpoint data makanan dan pencarian.
  static const String foods = '/foods';
  static const String foodDetail = '/foods/{id}';
  static const String foodSearch = '/foods/search';
  static const String foodCategories = '/foods/categories';

  // Endpoint rekap dan rekomendasi gizi harian/mingguan.
  static const String nutrition = '/nutrition';
  static const String nutritionByFood = '/nutrition/food/{foodId}';
  static const String nutritionDaily = '/nutrition/daily';
  static const String nutritionWeekly = '/nutrition/weekly';
  static const String nutritionRecommendation = '/nutrition/recommendation';
  // Legacy aliases
  static const String dailyNutrition = '/nutrition/daily';
  static const String weeklyNutrition = '/nutrition/weekly';

  // Endpoint jadwal dan menu program MBG per sekolah.
  static const String mbgMenu = '/mbg-menu';
  static const String mbgMenuToday = '/mbg-menu/today';
  static const String mbgMenuByDate = '/mbg-menu/date/{date}';
  static const String mbgMenuBySchool = '/mbg-menu/school/{schoolId}';

  // Endpoint klasifikasi gambar makanan via machine learning di backend.
  static const String predictions = '/predictions';
  static const String predictImage = '/predictions/classify';

  // Endpoint riwayat pemindaian makanan pengguna.
  static const String scanHistory = '/scan-history';
  static const String scanHistoryDetail = '/scan-history/{id}';
  static const String saveScan = '/scan-history/save';

  // Endpoint daftar sekolah terdaftar.
  static const String schools = '/schools';

  // Endpoint statistik dan ringkasan data gizi.
  static const String stats = '/stats';
  static const String statsDaily = '/stats/daily';
  static const String statsWeekly = '/stats/weekly';
  static const String statsTopFoods = '/stats/top-foods';
  static const String statsSummary = '/stats/summary';

  // Endpoint unggah media/gambar ke penyimpanan cloud.
  static const String uploadImage = '/storage/upload';

  // Endpoint laporan dari siswa (request menu, rating rasa, saran makanan).
  static const String menuRequests = '/reports/menu-requests';
  static const String menuRequestsMy = '/reports/menu-requests/my';
  static const String menuRequestsGrouped = '/reports/menu-requests/grouped';
  static const String foodRatings = '/reports/food-ratings';
  static const String foodRatingsMy = '/reports/food-ratings/my';
  static const String foodRatingsRanking = '/reports/food-ratings/ranking';
  static const String foodFeedbacks = '/reports/food-feedbacks';
  static const String foodFeedbacksMy = '/reports/food-feedbacks/my';

  // Endpoint khusus dashboard admin untuk memantau laporan dan data MBG.
  static const String adminDashboard = '/admin/dashboard';
  static const String adminNutritionReports = '/admin/nutrition-reports';
  static const String adminMenuRequestsAll = '/reports/menu-requests';
  static const String adminMenuRequestStatus = '/reports/menu-requests/{id}/status';
  static const String adminFoodRatingsAll = '/reports/food-ratings';
  static const String adminFeedbacksAll = '/reports/food-feedbacks';
  static const String adminFeedbackSummary = '/reports/food-feedbacks/summary';

  // Endpoint informasi unit SPPG untuk registrasi pengguna.
  static const String sppg = '/sppg';
  static const String sppgRegions = '/sppg/regions';
}
