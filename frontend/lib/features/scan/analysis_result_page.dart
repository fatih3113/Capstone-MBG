import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/evaluation_model.dart';
import '../../providers/scan_provider.dart';
import '../../shared/widgets/custom_button.dart';

class AnalysisResultPage extends StatefulWidget {
  const AnalysisResultPage({super.key});

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(
      parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final result = scan.analysisResult;
    final sensory = scan.sensoryData;
    final consumption = scan.consumptionData;

    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hasil Analisis Gizi'),
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
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header sukses
              _buildSuccessBanner(scan),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Makanan teridentifikasi
                    _buildIdentifiedFoods(scan),
                    const SizedBox(height: 20),

                    // Estimasi kandungan gizi
                    _buildNutritionSection(result),
                    const SizedBox(height: 20),

                    // Skor sensorik
                    if (sensory != null) ...[
                      _buildSensorySection(sensory, result),
                      const SizedBox(height: 20),
                    ],

                    // Data konsumsi
                    if (consumption != null) ...[
                      _buildConsumptionSection(consumption, result),
                      const SizedBox(height: 20),
                    ],

                    // Rekomendasi cerdas
                    _buildSmartRecommendation(scan, result),
                    const SizedBox(height: 24),

                    // Tombol aksi
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
                            label: 'Lihat Statistik',
                            onPressed: () => context.push('/stats'),
                            icon: const Icon(Icons.bar_chart_rounded,
                              color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner(ScanProvider scan) {
    return Stack(
      children: [
        if (scan.selectedImage != null)
          SizedBox(
            width: double.infinity, height: 200,
            child: Image.file(scan.selectedImage!, fit: BoxFit.cover),
          ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics_rounded,
                      color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text('Analisis Lengkap',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (scan.isSaved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.save_rounded,
                        color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text('Tersimpan',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdentifiedFoods(ScanProvider scan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Makanan Teridentifikasi',
          style: AppTextStyles.headlineSmall),
        const SizedBox(height: 10),
        ...scan.predictions.map((pred) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('🍽️',
                  style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pred.foodName, style: AppTextStyles.titleSmall),
                    Text('Keyakinan: ${pred.confidencePercent}',
                      style: AppTextStyles.caption.copyWith(
                        color: pred.isHighConfidence
                            ? AppColors.success : AppColors.warning)),
                  ],
                ),
              ),
              if (pred.calories != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${pred.calories!.toStringAsFixed(0)} kcal',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.calories)),
                    Text('${pred.protein?.toStringAsFixed(1) ?? '-'}g protein',
                      style: AppTextStyles.caption),
                  ],
                ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildNutritionSection(NutritionAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.local_fire_department_rounded,
              color: AppColors.calories, size: 20),
            SizedBox(width: 8),
            const Text('Estimasi Kandungan Gizi',
              style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Dihitung berdasarkan jenis makanan dan porsi yang dikonsumsi',
          style: AppTextStyles.bodySmall),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _NutritionEstimateCard(
              emoji: '🔥',
              label: 'Kalori',
              value: '${result.estimatedCalories.toStringAsFixed(0)} kcal',
              color: AppColors.calories,
            ),
            _NutritionEstimateCard(
              emoji: '💪',
              label: 'Protein',
              value: '${result.estimatedProtein.toStringAsFixed(1)} g',
              color: AppColors.protein,
            ),
            _NutritionEstimateCard(
              emoji: '🌾',
              label: 'Karbohidrat',
              value: '${result.estimatedCarbs.toStringAsFixed(1)} g',
              color: AppColors.carbs,
            ),
            _NutritionEstimateCard(
              emoji: '🧈',
              label: 'Lemak',
              value: '${result.estimatedFat.toStringAsFixed(1)} g',
              color: AppColors.fat,
            ),
            _NutritionEstimateCard(
              emoji: '🥦',
              label: 'Serat',
              value: '${result.estimatedFiber.toStringAsFixed(1)} g',
              color: AppColors.fiber,
            ),
            _NutritionEstimateCard(
              emoji: '📊',
              label: 'Terserap',
              value: '${result.consumptionPercentage.toStringAsFixed(0)}%',
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorySection(
      SensoryData sensory, NutritionAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star_rate_rounded,
              color: AppColors.warning, size: 20),
            SizedBox(width: 8),
            const Text('Skor Sensorik', style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 4),
        Text('Indikator penerimaan makanan (bukan kandungan gizi)',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              _SensoryScoreRow(
                emoji: '😋',
                label: 'Rasa',
                sublabel: sensory.taste,
                score: result.tasteScore,
                color: AppColors.warning,
              ),
              const Divider(height: 20),
              _SensoryScoreRow(
                emoji: '🍽️',
                label: 'Tekstur',
                sublabel: sensory.texture,
                score: result.textureScore,
                color: AppColors.protein,
              ),
              const Divider(height: 20),
              _SensoryScoreRow(
                emoji: '👃',
                label: 'Aroma',
                sublabel: sensory.aroma,
                score: result.aromaScore,
                color: AppColors.fiber,
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🧂 Tingkat Asin: ${sensory.saltLevel}',
                          style: AppTextStyles.bodySmall),
                        const SizedBox(height: 4),
                        Text('🍬 Tingkat Manis: ${sensory.sweetLevel}',
                          style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Skor Rata-rata',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary)),
                      Text('${result.tasteScore.toStringAsFixed(1)}/5.0',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.warning)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionSection(
      ConsumptionData consumption, NutritionAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.restaurant_rounded,
              color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            const Text('Data Konsumsi', style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ConsumptionStatCard(
                      emoji: '🥘',
                      label: 'Porsi',
                      value: consumption.portionSize,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ConsumptionStatCard(
                      emoji: '🍱',
                      label: 'Sisa',
                      value: consumption.leftoverAmount,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Progress bar konsumsi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Persentase Dikonsumsi',
                        style: AppTextStyles.bodySmall),
                      Text(
                        '${result.consumptionPercentage.toStringAsFixed(0)}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: result.consumptionPercentage / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getConsumptionColor(result.consumptionPercentage)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Persentase Sisa',
                        style: AppTextStyles.bodySmall),
                      Text(
                        '${result.leftoverPercentage.toStringAsFixed(0)}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: result.leftoverPercentage / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.warning),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        consumption.isFinished
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: consumption.isFinished
                            ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        consumption.isFinished
                            ? 'Makanan dihabiskan ✓'
                            : 'Makanan tidak dihabiskan',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: consumption.isFinished
                              ? AppColors.success : AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getConsumptionColor(double pct) {
    if (pct >= 75) return AppColors.success;
    if (pct >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildSmartRecommendation(
      ScanProvider scan, NutritionAnalysisResult result) {
    final recs = <String>[];

    // Rekomendasi berdasarkan sensorik
    if (result.tasteScore < 3) {
      recs.add('Kualitas rasa dinilai kurang. Feedback ini dapat diteruskan ke pengelola dapur MBG.');
    }
    if (result.textureScore < 3) {
      recs.add('Tekstur makanan perlu diperbaiki. Proses memasak dan penyajian perlu diperhatikan.');
    }
    if (result.aromaScore < 3) {
      recs.add('Aroma makanan kurang menarik. Hal ini dapat memengaruhi selera makan.');
    }

    // Rekomendasi berdasarkan konsumsi
    if (result.consumptionPercentage < 50) {
      recs.add('Hanya ${result.consumptionPercentage.toStringAsFixed(0)}% makanan dikonsumsi. Perlu investigasi penyebab sisa makanan yang tinggi.');
    } else if (result.consumptionPercentage >= 90) {
      recs.add('Makanan dihabiskan dengan baik (${result.consumptionPercentage.toStringAsFixed(0)}%). Program MBG berjalan efektif!');
    }

    // Rekomendasi berdasarkan gizi
    if (result.estimatedCalories < 400) {
      recs.add('Estimasi kalori yang diserap masih rendah. Pertimbangkan menambah porsi atau variasi menu.');
    }
    if (result.estimatedProtein < 10) {
      recs.add('Asupan protein estimasi masih rendah. Lauk protein hewani/nabati perlu ditingkatkan.');
    }

    if (recs.isEmpty) {
      recs.add('Konsumsi menu MBG hari ini berjalan dengan baik. Pertahankan kebiasaan makan sehat!');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLighter, AppColors.secondaryLighter],
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
          ...recs.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 6, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(rec,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary, height: 1.5)),
                ),
              ],
            ),
          )),
          const SizedBox(height: 4),
          Text(
            '⚠️ Informasi ini bukan diagnosis medis. Data sensorik adalah indikator penerimaan makanan, '
            'bukan pengganti data kandungan gizi.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _NutritionEstimateCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _NutritionEstimateCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
          Text('Estimasi', style: AppTextStyles.caption.copyWith(
            color: AppColors.textHint, fontSize: 10)),
        ],
      ),
    );
  }
}

class _SensoryScoreRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final double score;
  final Color color;

  const _SensoryScoreRow({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyMedium),
              Text(sublabel, style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    i < score.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < score.round() ? color : AppColors.cardBorder,
                    size: 14,
                  ),
                )),
              ),
            ],
          ),
        ),
        Text('${score.toStringAsFixed(1)}/5',
          style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

class _ConsumptionStatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _ConsumptionStatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
            style: AppTextStyles.titleSmall.copyWith(color: color),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
