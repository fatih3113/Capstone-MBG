import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/scan_provider.dart';
import '../../data/models/prediction_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/nutrition_card.dart';
import '../../core/constants/nutrition_constants.dart';

class PredictionResultPage extends StatelessWidget {
  const PredictionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Identifikasi & Data Gizi'),
        leading: IconButton(
          onPressed: () {
            scan.reset();
            context.go('/scan');
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Lihat Riwayat',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image header
            if (scan.selectedImage != null)
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: Image.file(
                      scan.selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${scan.predictions.length} Makanan Teridentifikasi',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Step indicator badge
                  Positioned(
                    bottom: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('Lanjut Evaluasi',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detected foods
                  const Text('Makanan Teridentifikasi',
                    style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 14),
                  ...scan.predictions.map((pred) =>
                    _PredictionCard(prediction: pred)),
                  const SizedBox(height: 20),

                  // Total nutrition
                  _buildTotalNutrition(scan),
                  const SizedBox(height: 20),

                  // Intelligent recommendation
                  _buildSmartRecommendation(scan),
                  const SizedBox(height: 24),

                  // Alur selanjutnya - info banner
                  _buildNextStepBanner(),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Scan Lagi',
                          isOutlined: true,
                          onPressed: () {
                            scan.reset();
                            context.go('/scan');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'Evaluasi Makanan →',
                          onPressed: () => context.push('/scan/evaluate'),
                          icon: const Icon(Icons.star_rate_rounded,
                            color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalNutrition(ScanProvider scan) {
    final total = scan.totalNutrition;
    const targets = NutritionConstants.dailyTargetSMP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Total Kandungan Gizi', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        const Text('Perkiraan untuk satu porsi makan',
          style: AppTextStyles.bodySmall),
        const SizedBox(height: 14),
        // FIX: pakai tinggi tetap (mainAxisExtent) supaya kartu tidak overflow,
        // dan padding zero supaya tidak ada jarak kosong di atas grid.
        GridView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 140,
          ),
          children: [
            NutritionCard(
              label: 'Kalori',
              value: total.calories,
              unit: 'kcal',
              color: AppColors.calories,
              target: targets['calories']! * 0.35,
              icon: Icons.local_fire_department_rounded,
            ),
            NutritionCard(
              label: 'Protein',
              value: total.protein,
              unit: 'g',
              color: AppColors.protein,
              target: targets['protein']! * 0.35,
              icon: Icons.fitness_center_rounded,
            ),
            NutritionCard(
              label: 'Karbohidrat',
              value: total.carbs,
              unit: 'g',
              color: AppColors.carbs,
              target: targets['carbs']! * 0.35,
              icon: Icons.grain_rounded,
            ),
            NutritionCard(
              label: 'Lemak',
              value: total.fat,
              unit: 'g',
              color: AppColors.fat,
              target: targets['fat']! * 0.35,
              icon: Icons.water_drop_rounded,
            ),
            NutritionCard(
              label: 'Serat',
              value: total.fiber,
              unit: 'g',
              color: AppColors.fiber,
              target: targets['fiber']! * 0.35,
              icon: Icons.eco_rounded,
            ),
            NutritionCard(
              label: 'Gula',
              value: total.sugar,
              unit: 'g',
              color: AppColors.sugar,
              icon: Icons.cake_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartRecommendation(ScanProvider scan) {
    // Intelligent System: rule-based recommendations
    final recommendations = <String>[];
    final total = scan.totalNutrition;
    const targets = NutritionConstants.dailyTargetSMP;

    final proteinRatio = total.protein / (targets['protein']! * 0.35);
    final fiberRatio = total.fiber / (targets['fiber']! * 0.35);
    final calorieRatio = total.calories / (targets['calories']! * 0.35);

    if (proteinRatio < 0.7) {
      recommendations.add(NutritionConstants.recommendations['protein_low']!);
    } else {
      recommendations.add(NutritionConstants.recommendations['protein_normal']!);
    }
    if (fiberRatio < 0.5) {
      recommendations.add(NutritionConstants.recommendations['fiber_low']!);
    }
    if (calorieRatio > 1.2) {
      recommendations.add(NutritionConstants.recommendations['calories_excess']!);
    } else if (calorieRatio < 0.6) {
      recommendations.add(NutritionConstants.recommendations['calories_low']!);
    } else {
      recommendations.add(NutritionConstants.recommendations['calories_normal']!);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryLighter,
            AppColors.secondaryLighter,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Analisis Cerdas', style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 6,
                  color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(rec, style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary, height: 1.5)),
                ),
              ],
            ),
          )),
          const SizedBox(height: 4),
          Text(
            '⚠️ Informasi ini bukan diagnosis medis.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.navigate_next_rounded,
              color: AppColors.info, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Langkah Selanjutnya',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.info)),
                const SizedBox(height: 2),
                Text(
                  'Isi data sensorik (rasa, tekstur, aroma) dan data konsumsi '
                  '(porsi, sisa) untuk mendapatkan analisis gizi yang lebih akurat.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictionModel prediction;
  const _PredictionCard({required this.prediction});

  Color get _confidenceColor {
    if (prediction.isHighConfidence) return AppColors.success;
    if (prediction.isMediumConfidence) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🍽️',
              style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prediction.foodName, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _confidenceColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _confidenceColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'Keyakinan: ${prediction.confidencePercent}',
                        style: AppTextStyles.caption.copyWith(
                          color: _confidenceColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (prediction.calories != null)
                Text(
                  '${prediction.calories!.toStringAsFixed(0)} kcal',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.calories),
                ),
              if (prediction.protein != null)
                Text(
                  '${prediction.protein!.toStringAsFixed(1)}g protein',
                  style: AppTextStyles.caption,
                ),
            ],
          ),
        ],
      ),
    );
  }
}