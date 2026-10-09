import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

import '../../data/models/food_model.dart';
import '../../data/dummy/dummy_data.dart';
import '../../shared/widgets/nutrition_card.dart';
import '../../shared/widgets/custom_button.dart';

class FoodDetailPage extends StatelessWidget {
  final FoodModel food;
  const FoodDetailPage({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final nutrition = DummyData.getNutritionByFoodId(food.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.heroGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(_getFoodEmoji(food.category),
                      style: const TextStyle(fontSize: 80)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name,
                              style: AppTextStyles.headlineLarge),
                            const SizedBox(height: 6),
                            _CategoryBadge(label: food.category),
                          ],
                        ),
                      ),
                      if (nutrition != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.calories.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                nutrition.calories.toStringAsFixed(0),
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.calories),
                              ),
                              const Text('kcal/100g',
                                style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                    ],
                  ),

                  if (food.description != null) ...[
                    const SizedBox(height: 16),
                    const Text('Deskripsi', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Text(food.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary)),
                  ],

                  if (nutrition != null) ...[
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Kandungan Gizi',
                          style: AppTextStyles.titleLarge),
                        Text('per 100g',
                          style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        NutritionCard(
                          label: 'Kalori',
                          value: nutrition.calories,
                          unit: 'kcal',
                          color: AppColors.calories,
                          icon: Icons.local_fire_department_rounded,
                        ),
                        NutritionCard(
                          label: 'Protein',
                          value: nutrition.protein,
                          unit: 'g',
                          color: AppColors.protein,
                          icon: Icons.fitness_center_rounded,
                        ),
                        NutritionCard(
                          label: 'Karbohidrat',
                          value: nutrition.carbs,
                          unit: 'g',
                          color: AppColors.carbs,
                          icon: Icons.grain_rounded,
                        ),
                        NutritionCard(
                          label: 'Lemak',
                          value: nutrition.fat,
                          unit: 'g',
                          color: AppColors.fat,
                          icon: Icons.water_drop_rounded,
                        ),
                        NutritionCard(
                          label: 'Serat',
                          value: nutrition.fiber,
                          unit: 'g',
                          color: AppColors.fiber,
                          icon: Icons.eco_rounded,
                        ),
                        NutritionCard(
                          label: 'Gula',
                          value: nutrition.sugar,
                          unit: 'g',
                          color: AppColors.sugar,
                          icon: Icons.cake_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Portion estimate
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant_rounded,
                            color: AppColors.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Porsi MBG Standar',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.primary)),
                              Text(
                                '${nutrition.portionGram.toStringAsFixed(0)}g = '
                                '${(nutrition.calories * nutrition.portionGram / 100).toStringAsFixed(0)} kcal',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Scan Makanan Ini',
                    onPressed: () => context.go('/scan'),
                    icon: const Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFoodEmoji(String category) {
    switch (category) {
      case 'Karbohidrat': return '🍚';
      case 'Protein Hewani': return '🍗';
      case 'Protein Nabati': return '🫘';
      case 'Sayuran': return '🥦';
      case 'Buah': return '🍎';
      case 'Minuman': return '🥛';
      default: return '🍽️';
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
    );
  }
}
