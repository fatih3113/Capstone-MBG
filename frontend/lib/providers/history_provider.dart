import 'package:flutter/foundation.dart';
import '../data/models/scan_history_model.dart';
import '../data/models/daily_nutrition_model.dart';
import '../data/services/history_service.dart';
import '../data/services/stats_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService;
  final StatsService _statsService;

  HistoryProvider(this._historyService, {StatsService? statsService})
      : _statsService = statsService ?? StatsService();

  List<ScanHistoryModel> _history = [];
  List<DailyNutritionModel> _dailyNutrition = [];
  ScanHistoryModel? _selectedHistory;
  bool _isLoading = false;
  String? _error;

  List<ScanHistoryModel> get history => _history;
  List<DailyNutritionModel> get dailyNutrition => _dailyNutrition;
  ScanHistoryModel? get selectedHistory => _selectedHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stats computed from history
  int get totalScans => _history.length;
  double get totalCalories =>
      _history.fold(0, (sum, h) => sum + h.totalCalories);
  double get totalProtein =>
      _history.fold(0, (sum, h) => sum + h.totalProtein);
  double get avgCaloriesPerScan =>
      _history.isEmpty ? 0 : totalCalories / totalScans;

  /// Top 3 most frequent foods
  List<MapEntry<String, int>> get topFoods {
    final foodCount = <String, int>{};
    for (final h in _history) {
      for (final p in h.predictions) {
        foodCount[p.foodName] = (foodCount[p.foodName] ?? 0) + 1;
      }
    }
    final sorted = foodCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Load scan history + weekly nutrition data concurrently
    final results = await Future.wait([
      _historyService.getScanHistory(userId: userId),
      _statsService.getWeeklyStats(),
    ]);

    final historyResponse = results[0] as dynamic;
    final weeklyResponse = results[1] as dynamic;

    if (historyResponse.success && historyResponse.data != null) {
      _history = historyResponse.data as List<ScanHistoryModel>;
    } else {
      _error = historyResponse.message as String?;
    }

    if (weeklyResponse.success && weeklyResponse.data != null) {
      _dailyNutrition = weeklyResponse.data as List<DailyNutritionModel>;
    }
    // If weekly fetch fails, keep existing data (don't overwrite with empty)

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistoryDetail(String scanId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _historyService.getScanDetail(scanId);
    if (response.success) {
      _selectedHistory = response.data;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
