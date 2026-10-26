class NutritionModel {
  final String id;
  final String foodId;
  final String foodName;
  final double calories;    // kcal per 100g
  final double protein;     // g per 100g
  final double carbs;       // g per 100g
  final double fat;         // g per 100g
  final double fiber;       // g per 100g
  final double sugar;       // g per 100g
  final double sodium;      // mg per 100g
  final double calcium;     // mg per 100g
  final double iron;        // mg per 100g
  final double vitaminC;    // mg per 100g
  final double vitaminA;    // mcg per 100g
  final double portionGram; // default serving size in gram

  const NutritionModel({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.sugar = 0,
    this.sodium = 0,
    this.calcium = 0,
    this.iron = 0,
    this.vitaminC = 0,
    this.vitaminA = 0,
    this.portionGram = 100,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    // Backend (Prisma) mengirim camelCase (foodId, vitaminC, ...) dan nama
    // makanan ada di json['food']['name']. Format snake_case tetap didukung.
    double num0(dynamic v) => (v as num?)?.toDouble() ?? 0;
    final food = json['food'] as Map<String, dynamic>?;

    return NutritionModel(
      id: json['id']?.toString() ?? '',
      foodId: (json['food_id'] ?? json['foodId'] ?? food?['id'])?.toString() ?? '',
      foodName: (json['food_name'] ?? json['foodName'] ?? food?['name'])
              as String? ??
          '',
      calories: num0(json['calories']),
      protein: num0(json['protein']),
      carbs: num0(json['carbs']),
      fat: num0(json['fat']),
      fiber: num0(json['fiber']),
      sugar: num0(json['sugar']),
      sodium: num0(json['sodium']),
      calcium: num0(json['calcium']),
      iron: num0(json['iron']),
      vitaminC: num0(json['vitamin_c'] ?? json['vitaminC']),
      vitaminA: num0(json['vitamin_a'] ?? json['vitaminA']),
      portionGram: (json['portion_gram'] ?? json['portionGram']) != null
          ? num0(json['portion_gram'] ?? json['portionGram'])
          : 100,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'food_id': foodId,
    'food_name': foodName,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'sugar': sugar,
    'sodium': sodium,
    'calcium': calcium,
    'iron': iron,
    'vitamin_c': vitaminC,
    'vitamin_a': vitaminA,
    'portion_gram': portionGram,
  };

  /// Scale nutrition values by portion
  NutritionModel scaleByPortion(double gram) {
    final ratio = gram / 100;
    return NutritionModel(
      id: id,
      foodId: foodId,
      foodName: foodName,
      calories: calories * ratio,
      protein: protein * ratio,
      carbs: carbs * ratio,
      fat: fat * ratio,
      fiber: fiber * ratio,
      sugar: sugar * ratio,
      sodium: sodium * ratio,
      calcium: calcium * ratio,
      iron: iron * ratio,
      vitaminC: vitaminC * ratio,
      vitaminA: vitaminA * ratio,
      portionGram: gram,
    );
  }

  /// Add two nutrition models together
  NutritionModel operator +(NutritionModel other) {
    return NutritionModel(
      id: 'combined',
      foodId: 'combined',
      foodName: 'Total',
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      sodium: sodium + other.sodium,
      calcium: calcium + other.calcium,
      iron: iron + other.iron,
      vitaminC: vitaminC + other.vitaminC,
      vitaminA: vitaminA + other.vitaminA,
      portionGram: portionGram + other.portionGram,
    );
  }

  static NutritionModel zero() {
    return const NutritionModel(
      id: 'zero',
      foodId: 'zero',
      foodName: 'Total',
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
    );
  }
}