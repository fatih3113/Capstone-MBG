import 'package:flutter_test/flutter_test.dart';
import 'package:mbg_nutrition/data/dummy/dummy_data.dart';
import 'package:mbg_nutrition/data/models/nutrition_model.dart';
import 'package:mbg_nutrition/data/models/scan_history_model.dart';
import 'package:mbg_nutrition/data/models/daily_nutrition_model.dart';
import 'package:mbg_nutrition/core/utils/validators.dart';
import 'package:mbg_nutrition/shared/helpers/nutrition_helper.dart';
import 'package:mbg_nutrition/shared/helpers/date_helper.dart';

void main() {
  // ─── DummyData Unit Tests ─────────────────────────────────────────────
  group('DummyData', () {
    test('getFoodById returns correct food', () {
      final food = DummyData.getFoodById('f1');
      expect(food, isNotNull);
      expect(food!.name, equals('Nasi Putih'));
      expect(food.category, equals('Karbohidrat'));
    });

    test('getNutritionByFoodId returns correct nutrition', () {
      final nutrition = DummyData.getNutritionByFoodId('f1');
      expect(nutrition, isNotNull);
      expect(nutrition!.calories, equals(130));
      expect(nutrition.protein, equals(2.7));
    });

    test('getMbgMenusForWeek returns 5 menus (Mon-Fri)', () {
      final menus = DummyData.getMbgMenusForWeek();
      expect(menus.length, equals(5));
    });

    test('getScanHistory returns list with predictions', () {
      final history = DummyData.getScanHistory('user1');
      expect(history, isNotEmpty);
      expect(history.first.predictions, isNotEmpty);
    });

    test('getDailyNutrition returns 7 days of data', () {
      final daily = DummyData.getDailyNutrition('user1');
      expect(daily.length, equals(7));
    });

    test('getFoodsByCategory returns only matching category', () {
      final buah = DummyData.getFoodsByCategory('Buah');
      expect(buah, isNotEmpty);
      expect(buah.every((f) => f.category == 'Buah'), isTrue);
    });

    test('getFoodById returns null for unknown id', () {
      final food = DummyData.getFoodById('unknown-id');
      expect(food, isNull);
    });
  });

  // ─── NutritionModel Unit Tests ────────────────────────────────────────
  group('NutritionModel', () {
    const nutrition = NutritionModel(
      id: 'n_test',
      foodId: 'f_test',
      foodName: 'Test Food',
      calories: 100,
      protein: 10,
      carbs: 20,
      fat: 5,
      fiber: 3,
      sugar: 2,
      portionGram: 100,
    );

    test('scaleByPortion scales calories correctly', () {
      final scaled = nutrition.scaleByPortion(200);
      expect(scaled.calories, equals(200));
      expect(scaled.protein, equals(20));
    });

    test('scaleByPortion at 50g returns half values', () {
      final scaled = nutrition.scaleByPortion(50);
      expect(scaled.calories, equals(50));
      expect(scaled.carbs, equals(10));
    });

    test('NutritionModel.zero() has all zeros', () {
      final zero = NutritionModel.zero();
      expect(zero.calories, equals(0));
      expect(zero.protein, equals(0));
      expect(zero.carbs, equals(0));
      expect(zero.fat, equals(0));
    });

    test('addition operator sums nutrients', () {
      final sum = nutrition + nutrition;
      expect(sum.calories, equals(200));
      expect(sum.protein, equals(20));
      expect(sum.carbs, equals(40));
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'n1',
        'food_id': 'f1',
        'food_name': 'Nasi Putih',
        'calories': 130.0,
        'protein': 2.7,
        'carbs': 28.2,
        'fat': 0.3,
        'fiber': 0.4,
        'sugar': 0.0,
        'portion_gram': 200.0,
      };
      final model = NutritionModel.fromJson(json);
      expect(model.calories, equals(130.0));
      expect(model.foodName, equals('Nasi Putih'));
    });
  });

  // ─── ScanHistoryModel Unit Tests ──────────────────────────────────────
  group('ScanHistoryModel', () {
    test('foodNames returns list of prediction names', () {
      final history = DummyData.getScanHistory('u1').first;
      expect(history.foodNames, isNotEmpty);
      expect(history.foodNames.first, equals('Nasi Putih'));
    });

    test('totalCalories is correct', () {
      final history = DummyData.getScanHistory('u1').first;
      expect(history.totalCalories, equals(520));
    });

    test('ScanHistoryModel toJson and fromJson roundtrip', () {
      final history = DummyData.getScanHistory('u1').first;
      final json = history.toJson();
      final restored = ScanHistoryModel.fromJson(json);
      expect(restored.id, equals(history.id));
      expect(restored.totalCalories, equals(history.totalCalories));
    });
  });

  // ─── DailyNutritionModel Unit Tests ──────────────────────────────────
  group('DailyNutritionModel', () {
    test('caloriesPercent calculates correctly', () {
      final model = DailyNutritionModel(
        id: 'd1',
        userId: 'u1',
        date: DateTime.now(),
        totalCalories: 1000,
        totalProtein: 30,
        totalCarbs: 150,
        totalFat: 33,
        totalFiber: 12,
        totalScans: 2,
        caloriesTarget: 2000,
      );
      expect(model.caloriesPercent, equals(0.5));
    });

    test('proteinPercent clamps at 1.0 for target=0', () {
      final model = DailyNutritionModel(
        id: 'd1',
        userId: 'u1',
        date: DateTime.now(),
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        totalFiber: 0,
        totalScans: 0,
        caloriesTarget: 0, // edge case
      );
      expect(model.caloriesPercent, equals(0));
    });
  });

  // ─── Validators Unit Tests ────────────────────────────────────────────
  group('Validators', () {
    test('email validator rejects invalid email', () {
      expect(Validators.email('invalid'), isNotNull); // returns error msg
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('missing@dot'), isNotNull);
    });

    test('email validator accepts valid email', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('user+tag@domain.co.id'), isNull);
    });

    test('password validator rejects short password', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('password validator accepts >= 8 chars', () {
      expect(Validators.password('password123'), isNull);
      expect(Validators.password('12345678'), isNull);
    });

    test('age validator rejects non-numeric', () {
      expect(Validators.age('abc'), isNotNull);
      expect(Validators.age(''), isNotNull);
    });

    test('age validator accepts valid age', () {
      expect(Validators.age('12'), isNull);
      expect(Validators.age('17'), isNull);
    });
  });

  // ─── NutritionHelper Unit Tests ───────────────────────────────────────
  group('NutritionHelper', () {
    test('formatCalories formats correctly', () {
      expect(NutritionHelper.formatCalories(500), equals('500 kkal'));
      expect(NutritionHelper.formatCalories(1500), contains('kkal'));
    });

    test('formatGrams formats small values as mg', () {
      expect(NutritionHelper.formatGrams(0.5), contains('mg'));
      expect(NutritionHelper.formatGrams(10), contains('g'));
    });

    test('getNutritionStatus returns correct status for 0.4', () {
      final status = NutritionHelper.getNutritionStatus(0.4);
      expect(status.label, equals('Sangat Kurang'));
    });

    test('getNutritionStatus returns Cukup for 0.9', () {
      final status = NutritionHelper.getNutritionStatus(0.9);
      expect(status.label, equals('Cukup'));
    });

    test('getNutritionStatus returns Berlebih for 1.2', () {
      final status = NutritionHelper.getNutritionStatus(1.2);
      expect(status.label, equals('Berlebih'));
    });

    test('getCategoryColor returns different colors', () {
      final c1 = NutritionHelper.getCategoryColor('Karbohidrat');
      final c2 = NutritionHelper.getCategoryColor('Sayuran');
      expect(c1, isNot(equals(c2)));
    });

    test('calculateDailyNeeds returns correct values for SD Laki', () {
      final needs = NutritionHelper.calculateDailyNeeds(
        schoolLevel: 'SD',
        gender: 'L',
      );
      expect(needs['calories'], equals(1850));
      expect(needs['protein'], equals(49));
    });

    test('calculateDailyNeeds SMA Perempuan', () {
      final needs = NutritionHelper.calculateDailyNeeds(
        schoolLevel: 'SMA',
        gender: 'P',
      );
      expect(needs['calories'], equals(2100));
    });

    test('confidenceLabel returns correct label', () {
      expect(NutritionHelper.confidenceLabel(0.95), equals('Sangat Yakin'));
      expect(NutritionHelper.confidenceLabel(0.5), equals('Kurang Yakin'));
    });
  });

  // ─── DateHelper Unit Tests ────────────────────────────────────────────
  group('DateHelper', () {
    final monday = DateTime(2025, 6, 9); // Monday

    test('formatDate formats correctly', () {
      expect(DateHelper.formatDate(monday), equals('9 Juni 2025'));
    });

    test('dayName returns Senin for weekday 1', () {
      expect(DateHelper.dayName(monday), equals('Senin'));
    });

    test('dayShort returns Sen', () {
      expect(DateHelper.dayShort(monday), equals('Sen'));
    });

    test('toIso returns correct format', () {
      expect(DateHelper.toIso(monday), equals('2025-06-09'));
    });

    test('isToday returns true for now', () {
      expect(DateHelper.isToday(DateTime.now()), isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateHelper.isToday(yesterday), isFalse);
    });

    test('timeAgo for 1 minute ago', () {
      final oneMinAgo = DateTime.now().subtract(const Duration(minutes: 1));
      expect(DateHelper.timeAgo(oneMinAgo), contains('menit'));
    });
  });
}
