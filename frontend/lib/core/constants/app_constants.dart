class AppConstants {
  AppConstants._();

  static const String appName = 'MBG Nutrition';
  static const String appTagline = 'Identifikasi Gizi Menu MBG';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Duration
  static const int splashDuration = 3;
  static const int animationFast = 200;
  static const int animationMedium = 350;
  static const int animationSlow = 500;

  // Pagination
  static const int defaultPageSize = 20;

  // Image
  static const int imageMaxWidth = 640;
  static const int imageMaxHeight = 640;
  static const int imageQuality = 85;
  static const double imageNormalizeValue = 255.0;

  // ML
  static const int mlInputSize = 224;
  static const double mlConfidenceThreshold = 0.5;
  static const int mlTopK = 5;
  static const String mlModelPath = 'assets/models/food_classifier.tflite';
  static const String mlLabelsPath = 'assets/models/food_labels.txt';

  // Local storage keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'current_user';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboarding = 'onboarding_done';

  // Nutrition daily targets (default for general adult)
  static const double defaultCaloriesTarget = 2000;
  static const double defaultProteinTarget = 50;
  static const double defaultCarbsTarget = 300;
  static const double defaultFatTarget = 65;
  static const double defaultFiberTarget = 25;

  // School levels
  static const List<String> schoolLevels = ['SD', 'SMP', 'SMA', 'SMK'];

  // Days
  static const List<String> dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'
  ];

  // Food categories
  static const List<String> foodCategories = [
    'Karbohidrat', 'Protein Hewani', 'Protein Nabati',
    'Sayuran', 'Buah', 'Minuman', 'Lainnya'
  ];
}
