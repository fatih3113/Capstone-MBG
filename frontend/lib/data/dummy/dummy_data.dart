import '../models/food_model.dart';
import '../models/nutrition_model.dart';
import '../models/mbg_menu_model.dart';
import '../models/scan_history_model.dart';
import '../models/prediction_model.dart';
import '../models/user_model.dart';
import '../models/daily_nutrition_model.dart';

/// Centralized dummy data for offline/mock usage
/// Replace with actual API calls when backend is ready
class DummyData {
  DummyData._();

  // ─── FOODS ──────────────────────────────────────────────────────
  static final List<FoodModel> foods = [
    const FoodModel(id: 'f1', name: 'Nasi Putih', category: 'Karbohidrat',
      description: 'Nasi putih yang merupakan makanan pokok masyarakat Indonesia.'),
    const FoodModel(id: 'f2', name: 'Ayam Goreng', category: 'Protein Hewani',
      description: 'Ayam yang digoreng dengan bumbu tradisional.'),
    const FoodModel(id: 'f3', name: 'Telur Rebus', category: 'Protein Hewani',
      description: 'Telur ayam yang direbus hingga matang.'),
    const FoodModel(id: 'f4', name: 'Ikan Goreng', category: 'Protein Hewani',
      description: 'Ikan yang digoreng dengan bumbu sederhana.'),
    const FoodModel(id: 'f5', name: 'Tempe Goreng', category: 'Protein Nabati',
      description: 'Tempe kedelai yang digoreng.'),
    const FoodModel(id: 'f6', name: 'Tahu Goreng', category: 'Protein Nabati',
      description: 'Tahu yang digoreng dengan sedikit minyak.'),
    const FoodModel(id: 'f7', name: 'Sayur Bayam', category: 'Sayuran',
      description: 'Sayur bayam segar yang kaya zat besi.'),
    const FoodModel(id: 'f8', name: 'Sayur Wortel', category: 'Sayuran',
      description: 'Wortel yang mengandung beta-karoten tinggi.'),
    const FoodModel(id: 'f9', name: 'Pisang', category: 'Buah',
      description: 'Pisang ambon yang kaya kalium dan vitamin B6.'),
    const FoodModel(id: 'f10', name: 'Jeruk', category: 'Buah',
      description: 'Jeruk manis yang kaya vitamin C.'),
    const FoodModel(id: 'f11', name: 'Susu Putih', category: 'Minuman',
      description: 'Susu segar yang kaya kalsium.'),
    const FoodModel(id: 'f12', name: 'Mie Goreng', category: 'Karbohidrat',
      description: 'Mie yang digoreng dengan bumbu dan sayuran.'),
    const FoodModel(id: 'f13', name: 'Perkedel Kentang', category: 'Karbohidrat',
      description: 'Perkedel kentang goreng yang gurih.'),
    const FoodModel(id: 'f14', name: 'Tumis Kangkung', category: 'Sayuran',
      description: 'Kangkung yang ditumis dengan bawang putih.'),
    const FoodModel(id: 'f15', name: 'Semangka', category: 'Buah',
      description: 'Semangka segar yang mengandung banyak air.'),
  ];

  // ─── NUTRITION ───────────────────────────────────────────────────
  /// Per 100 gram
  static final List<NutritionModel> nutritionList = [
    const NutritionModel(id: 'n1', foodId: 'f1', foodName: 'Nasi Putih',
      calories: 130, protein: 2.7, carbs: 28.2, fat: 0.3, fiber: 0.4, sugar: 0, portionGram: 200),
    const NutritionModel(id: 'n2', foodId: 'f2', foodName: 'Ayam Goreng',
      calories: 260, protein: 27.0, carbs: 2.5, fat: 16.0, fiber: 0, sugar: 0, portionGram: 100),
    const NutritionModel(id: 'n3', foodId: 'f3', foodName: 'Telur Rebus',
      calories: 155, protein: 13.0, carbs: 1.1, fat: 11.0, fiber: 0, sugar: 0, portionGram: 55),
    const NutritionModel(id: 'n4', foodId: 'f4', foodName: 'Ikan Goreng',
      calories: 200, protein: 24.0, carbs: 0.5, fat: 11.5, fiber: 0, sugar: 0, portionGram: 100),
    const NutritionModel(id: 'n5', foodId: 'f5', foodName: 'Tempe Goreng',
      calories: 190, protein: 17.0, carbs: 9.0, fat: 9.5, fiber: 3.8, sugar: 0, portionGram: 75),
    const NutritionModel(id: 'n6', foodId: 'f6', foodName: 'Tahu Goreng',
      calories: 120, protein: 9.0, carbs: 3.0, fat: 8.0, fiber: 0.3, sugar: 0, portionGram: 75),
    const NutritionModel(id: 'n7', foodId: 'f7', foodName: 'Sayur Bayam',
      calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, sugar: 0.4, portionGram: 75),
    const NutritionModel(id: 'n8', foodId: 'f8', foodName: 'Sayur Wortel',
      calories: 41, protein: 0.9, carbs: 9.6, fat: 0.2, fiber: 2.8, sugar: 4.7, portionGram: 75),
    const NutritionModel(id: 'n9', foodId: 'f9', foodName: 'Pisang',
      calories: 89, protein: 1.1, carbs: 22.8, fat: 0.3, fiber: 2.6, sugar: 12.2, portionGram: 100),
    const NutritionModel(id: 'n10', foodId: 'f10', foodName: 'Jeruk',
      calories: 47, protein: 0.9, carbs: 11.8, fat: 0.1, fiber: 2.4, sugar: 9.4, portionGram: 100),
    const NutritionModel(id: 'n11', foodId: 'f11', foodName: 'Susu Putih',
      calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0, sugar: 5.1, portionGram: 200),
    const NutritionModel(id: 'n12', foodId: 'f12', foodName: 'Mie Goreng',
      calories: 220, protein: 5.5, carbs: 33.0, fat: 8.0, fiber: 1.0, sugar: 2.5, portionGram: 150),
    const NutritionModel(id: 'n13', foodId: 'f13', foodName: 'Perkedel Kentang',
      calories: 180, protein: 4.5, carbs: 20.0, fat: 9.0, fiber: 1.5, sugar: 1.0, portionGram: 75),
    const NutritionModel(id: 'n14', foodId: 'f14', foodName: 'Tumis Kangkung',
      calories: 35, protein: 2.5, carbs: 4.5, fat: 1.5, fiber: 2.5, sugar: 0.8, portionGram: 75),
    const NutritionModel(id: 'n15', foodId: 'f15', foodName: 'Semangka',
      calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2, fiber: 0.4, sugar: 6.2, portionGram: 200),
  ];

  // ─── MBG MENUS ───────────────────────────────────────────────────
  static List<MbgMenuModel> getMbgMenusForWeek() {
    final now = DateTime.now();
    // Find last Monday
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return [
      _buildMenu('m1', monday, 'Senin', ['f1', 'f2', 'f7', 'f9', 'f11']),
      _buildMenu('m2', monday.add(const Duration(days: 1)), 'Selasa', ['f1', 'f3', 'f8', 'f10', 'f11']),
      _buildMenu('m3', monday.add(const Duration(days: 2)), 'Rabu', ['f1', 'f4', 'f7', 'f15', 'f11']),
      _buildMenu('m4', monday.add(const Duration(days: 3)), 'Kamis', ['f1', 'f5', 'f6', 'f14', 'f9', 'f11']),
      _buildMenu('m5', monday.add(const Duration(days: 4)), 'Jumat', ['f12', 'f3', 'f8', 'f10', 'f11']),
    ];
  }

  static MbgMenuModel _buildMenu(
    String id, DateTime date, String dayName, List<String> foodIds) {
    final portions = {'f1': 200.0, 'f12': 150.0, 'f11': 200.0};
    return MbgMenuModel(
      id: id,
      schoolId: 'school1',
      schoolName: 'SDN 01 Contoh',
      date: date,
      dayName: dayName,
      items: foodIds.map((fid) {
        final food = foods.firstWhere((f) => f.id == fid);
        return MbgMenuItemModel(
          id: '${id}_$fid',
          menuId: id,
          food: food,
          portionGram: portions[fid] ?? 100.0,
        );
      }).toList(),
    );
  }

  // ─── SCAN HISTORY ─────────────────────────────────────────────────
  static List<ScanHistoryModel> getScanHistory(String userId) {
    final now = DateTime.now();
    return [
      ScanHistoryModel(
        id: 'sh1',
        userId: userId,
        scannedAt: now.subtract(const Duration(hours: 2)),
        totalCalories: 520,
        totalProtein: 25,
        totalCarbs: 70,
        totalFat: 15,
        totalFiber: 8,
        predictions: [
          const PredictionModel(id: 'p1', scanId: 'sh1', foodId: 'f1',
            foodName: 'Nasi Putih', confidence: 0.96, portionEstimateGram: 200,
            calories: 260, protein: 5.4, carbs: 56.4, fat: 0.6),
          const PredictionModel(id: 'p2', scanId: 'sh1', foodId: 'f2',
            foodName: 'Ayam Goreng', confidence: 0.91, portionEstimateGram: 100,
            calories: 260, protein: 27.0, carbs: 2.5, fat: 16.0),
          const PredictionModel(id: 'p3', scanId: 'sh1', foodId: 'f7',
            foodName: 'Sayur Bayam', confidence: 0.88, portionEstimateGram: 75,
            calories: 17.3, protein: 2.2, carbs: 2.7, fat: 0.3),
          const PredictionModel(id: 'p4', scanId: 'sh1', foodId: 'f9',
            foodName: 'Pisang', confidence: 0.94, portionEstimateGram: 100,
            calories: 89, protein: 1.1, carbs: 22.8, fat: 0.3),
        ],
      ),
      ScanHistoryModel(
        id: 'sh2',
        userId: userId,
        scannedAt: now.subtract(const Duration(days: 1, hours: 5)),
        totalCalories: 480,
        totalProtein: 22,
        totalCarbs: 65,
        totalFat: 14,
        totalFiber: 6,
        predictions: [
          const PredictionModel(id: 'p5', scanId: 'sh2', foodId: 'f1',
            foodName: 'Nasi Putih', confidence: 0.95, portionEstimateGram: 200,
            calories: 260, protein: 5.4, carbs: 56.4, fat: 0.6),
          const PredictionModel(id: 'p6', scanId: 'sh2', foodId: 'f3',
            foodName: 'Telur Rebus', confidence: 0.89, portionEstimateGram: 55,
            calories: 85, protein: 7.2, carbs: 0.6, fat: 6.1),
          const PredictionModel(id: 'p7', scanId: 'sh2', foodId: 'f8',
            foodName: 'Sayur Wortel', confidence: 0.82, portionEstimateGram: 75,
            calories: 30.8, protein: 0.7, carbs: 7.2, fat: 0.15),
        ],
      ),
      ScanHistoryModel(
        id: 'sh3',
        userId: userId,
        scannedAt: now.subtract(const Duration(days: 2, hours: 3)),
        totalCalories: 550,
        totalProtein: 28,
        totalCarbs: 75,
        totalFat: 18,
        totalFiber: 9,
        predictions: [
          const PredictionModel(id: 'p8', scanId: 'sh3', foodId: 'f1',
            foodName: 'Nasi Putih', confidence: 0.97, portionEstimateGram: 200,
            calories: 260, protein: 5.4, carbs: 56.4, fat: 0.6),
          const PredictionModel(id: 'p9', scanId: 'sh3', foodId: 'f4',
            foodName: 'Ikan Goreng', confidence: 0.85, portionEstimateGram: 100,
            calories: 200, protein: 24.0, carbs: 0.5, fat: 11.5),
          const PredictionModel(id: 'p10', scanId: 'sh3', foodId: 'f15',
            foodName: 'Semangka', confidence: 0.92, portionEstimateGram: 200,
            calories: 60, protein: 1.2, carbs: 15.2, fat: 0.4),
        ],
      ),
    ];
  }

  // ─── DAILY NUTRITION ──────────────────────────────────────────────
  static List<DailyNutritionModel> getDailyNutrition(String userId) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: i));
      final rand = 0.7 + (i % 3) * 0.15;
      return DailyNutritionModel(
        id: 'dn$i',
        userId: userId,
        date: date,
        totalCalories: 2000 * rand,
        totalProtein: 60 * rand,
        totalCarbs: 300 * rand,
        totalFat: 65 * rand,
        totalFiber: 25 * rand,
        totalScans: i == 0 ? 1 : (i < 3 ? 2 : 3),
        caloriesTarget: 2000,
        proteinTarget: 60,
        carbsTarget: 300,
        fatTarget: 65,
        fiberTarget: 25,
      );
    });
  }

  // ─── DEMO USER ────────────────────────────────────────────────────
  static final UserModel demoUser = UserModel(
    id: 'user1',
    name: 'Fatih Ramadan',
    email: 'fatih@example.com',
    schoolId: 'school1',
    schoolName: 'SDN 01 Contoh',
    className: '6A',
    gender: 'L',
    age: 12,
    schoolLevel: 'SD',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  // ─── HELPER METHODS ───────────────────────────────────────────────
  static NutritionModel? getNutritionByFoodId(String foodId) {
    try {
      return nutritionList.firstWhere((n) => n.foodId == foodId);
    } catch (_) {
      return null;
    }
  }

  static FoodModel? getFoodById(String foodId) {
    try {
      return foods.firstWhere((f) => f.id == foodId);
    } catch (_) {
      return null;
    }
  }

  static List<FoodModel> getFoodsByCategory(String category) {
    return foods.where((f) => f.category == category).toList();
  }
}
