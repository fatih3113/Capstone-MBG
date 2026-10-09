import 'package:flutter/foundation.dart';
import '../data/models/daily_nutrition_model.dart';
import '../data/services/stats_service.dart';

enum NutritionLoadState { idle, loading, loaded, error }

class NutritionProvider extends ChangeNotifier {
  final StatsService _statsService;

  NutritionProvider(this._statsService);

  // ─── State ──────────────────────────────────────────────────────────
  NutritionLoadState _state = NutritionLoadState.idle;
  String? _error;

  DailyNutritionModel? _todayNutrition;
  List<DailyNutritionModel> _weeklyNutrition = [];
  List<Map<String, dynamic>> _topFoods = [];
  Map<String, dynamic>? _recommendation;
  Map<String, dynamic>? _summary;

  // ─── Getters ─────────────────────────────────────────────────────────
  NutritionLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == NutritionLoadState.loading;

  DailyNutritionModel? get todayNutrition => _todayNutrition;
  List<DailyNutritionModel> get weeklyNutrition => _weeklyNutrition;
  List<Map<String, dynamic>> get topFoods => _topFoods;
  Map<String, dynamic>? get recommendation => _recommendation;
  Map<String, dynamic>? get summary => _summary;

  // Convenience getters untuk UI
  double get todayCalories => _todayNutrition?.totalCalories ?? 0;
  double get todayProtein => _todayNutrition?.totalProtein ?? 0;
  double get todayCarbs => _todayNutrition?.totalCarbs ?? 0;
  double get todayFat => _todayNutrition?.totalFat ?? 0;
  double get todayFiber => _todayNutrition?.totalFiber ?? 0;
  double get caloriesTarget => _todayNutrition?.caloriesTarget ?? 2000;
  double get proteinTarget => _todayNutrition?.proteinTarget ?? 60;

  double get caloriesPercentage =>
      caloriesTarget > 0 ? (todayCalories / caloriesTarget).clamp(0.0, 1.0) : 0;
  double get proteinPercentage =>
      proteinTarget > 0 ? (todayProtein / proteinTarget).clamp(0.0, 1.0) : 0;

  // ─── Actions ─────────────────────────────────────────────────────────

  /// Muat semua data statistik sekaligus
  Future<void> loadAll() async {
    _state = NutritionLoadState.loading;
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadToday(),
      _loadWeekly(),
      _loadTopFoods(),
      _loadRecommendation(),
      _loadSummary(),
    ]);

    _state = NutritionLoadState.loaded;
    notifyListeners();
  }

  /// Refresh data hari ini saja (setelah scan baru)
  Future<void> refreshToday() async {
    await _loadToday();
    await _loadRecommendation();
    notifyListeners();
  }

  Future<void> _loadToday() async {
    final res = await _statsService.getDailyStats();
    if (res.success) _todayNutrition = res.data;
  }

  Future<void> _loadWeekly() async {
    final res = await _statsService.getWeeklyStats();
    if (res.success && res.data != null) {
      _weeklyNutrition = res.data!;
    }
  }

  Future<void> _loadTopFoods() async {
    final res = await _statsService.getTopFoods();
    if (res.success && res.data != null) {
      _topFoods = res.data!;
    }
  }

  Future<void> _loadRecommendation() async {
    final res = await _statsService.getNutritionRecommendation();
    if (res.success) _recommendation = res.data;
  }

  Future<void> _loadSummary() async {
    final res = await _statsService.getSummary();
    if (res.success) _summary = res.data;
  }

  void reset() {
    _state = NutritionLoadState.idle;
    _error = null;
    _todayNutrition = null;
    _weeklyNutrition = [];
    _topFoods = [];
    _recommendation = null;
    _summary = null;
    notifyListeners();
  }
}
