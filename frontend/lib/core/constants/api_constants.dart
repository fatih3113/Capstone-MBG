class ApiConstants {
  ApiConstants._();

  // Base URL - replace with actual backend URL
  static const String baseUrl = 'https://api.mbg-nutrition.example.com';
  static const String apiVersion = '/api/v1';
  static const String apiBase = baseUrl + apiVersion;

  // Timeout
  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile/update';
  static const String uploadProfilePhoto = '/users/profile/photo';

  // Food endpoints
  static const String foods = '/foods';
  static const String foodDetail = '/foods/{id}';
  static const String foodSearch = '/foods/search';
  static const String foodCategories = '/foods/categories';

  // Nutrition endpoints
  static const String nutrition = '/nutrition';
  static const String nutritionByFood = '/nutrition/food/{foodId}';
  static const String nutritionDaily = '/nutrition/daily';
  static const String nutritionWeekly = '/nutrition/weekly';
  static const String nutritionRecommendation = '/nutrition/recommendation';
  // Legacy aliases
  static const String dailyNutrition = '/nutrition/daily';
  static const String weeklyNutrition = '/nutrition/weekly';

  // MBG Menu endpoints
  static const String mbgMenu = '/mbg-menu';
  static const String mbgMenuToday = '/mbg-menu/today';
  static const String mbgMenuByDate = '/mbg-menu/date/{date}';
  static const String mbgMenuBySchool = '/mbg-menu/school/{schoolId}';

  // Prediction endpoints
  static const String predictions = '/predictions';
  static const String predictImage = '/predictions/classify';

  // Scan History endpoints
  static const String scanHistory = '/scan-history';
  static const String scanHistoryDetail = '/scan-history/{id}';
  static const String saveScan = '/scan-history/save';

  // School endpoints
  static const String schools = '/schools';

  // Statistics endpoints
  static const String stats = '/stats';
  static const String statsDaily = '/stats/daily';
  static const String statsWeekly = '/stats/weekly';
  static const String statsTopFoods = '/stats/top-foods';
  static const String statsSummary = '/stats/summary';

  // Cloud Storage
  static const String uploadImage = '/storage/upload';
}
