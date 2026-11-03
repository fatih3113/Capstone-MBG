// File ini mendefinisikan konstanta umum aplikasi seperti nama aplikasi, durasi animasi, ukuran gambar, dan kunci penyimpanan lokal.

// AppConstants: tempat berkumpulnya konfigurasi statis aplikasi agar mudah diubah dari satu tempat.
class AppConstants {
  AppConstants._();

  // Informasi identitas aplikasi.
  static const String appName = 'MBG Nutrition';
  static const String appTagline = 'Identifikasi Gizi Menu MBG';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Durasi transisi splash screen dan animasi antarmuka (dalam milidetik).
  static const int splashDuration = 3;
  static const int animationFast = 200;
  static const int animationMedium = 350;
  static const int animationSlow = 500;

  // Batas jumlah item data per halaman (paginasi).
  static const int defaultPageSize = 20;

  // Konfigurasi resolusi dan kompresi gambar sebelum diunggah atau diproses ML.
  static const int imageMaxWidth = 640;
  static const int imageMaxHeight = 640;
  static const int imageQuality = 85;
  static const double imageNormalizeValue = 255.0;

  // Konfigurasi inferensi model TensorFlow Lite on-device.
  static const int mlInputSize = 224;
  static const double mlConfidenceThreshold = 0.5;
  static const int mlTopK = 5;
  static const String mlModelPath = 'assets/models/food_classifier.tflite';
  static const String mlLabelsPath = 'assets/models/food_labels.txt';

  // Kunci untuk menyimpan token dan status login di SharedPreferences.
  static const String keyToken = 'auth_token';
  static const String keyUser = 'current_user';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboarding = 'onboarding_done';

  // Target standar kebutuhan gizi harian default (untuk estimasi umum).
  static const double defaultCaloriesTarget = 2000;
  static const double defaultProteinTarget = 50;
  static const double defaultCarbsTarget = 300;
  static const double defaultFatTarget = 65;
  static const double defaultFiberTarget = 25;

  // Tingkat jenjang sekolah dan hari operasional distribusi MBG.
  static const List<String> schoolLevels = ['SD', 'SMP', 'SMA', 'SMK'];

  static const List<String> dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'
  ];

  // Kategori kelompok bahan makanan untuk pengelompokan menu gizi.
  static const List<String> foodCategories = [
    'Karbohidrat', 'Protein Hewani', 'Protein Nabati',
    'Sayuran', 'Buah', 'Minuman', 'Lainnya'
  ];
}
