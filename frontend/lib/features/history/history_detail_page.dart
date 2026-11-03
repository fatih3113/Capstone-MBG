// Halaman Detail Riwayat Scan: menyajikan rincian lengkap hasil deteksi makanan, total nutrisi makro, evaluasi sensorik, dan data konsumsi sisa makanan.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/scan_history_model.dart';
import '../../data/models/evaluation_model.dart';
import '../../shared/widgets/nutrition_card.dart';

class HistoryDetailPage extends StatelessWidget {
  final ScanHistoryModel history;
  const HistoryDetailPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman dengan AppBar bertombol kembali dan area isi konten yang dapat digeser.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Scan'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      // SingleChildScrollView: memastikan seluruh rincian informasi makanan dan evaluasi tidak terpotong pada layar kecil.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container pratinjau foto/ilustrasi baki makanan MBG yang dipindai
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🍱', style: TextStyle(fontSize: 72))),
            ),
            const SizedBox(height: 16),

            // Baris waktu pemindaian dan badge status sukses
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                  color: AppColors.textHint, size: 16),
                const SizedBox(width: 6),
                Text(
                  AppFormatters.formatDateTime(history.scannedAt),
                  style: AppTextStyles.bodySmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Berhasil',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bagian daftar hidangan yang berhasil terdeteksi AI beserta nilai keyakinan (confidence)
            const Text('Makanan Teridentifikasi',
              style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            ...history.predictions.map((pred) => Container(
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
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 20))),
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
                    Text(
                      '${pred.calories!.toStringAsFixed(0)} kcal',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.calories),
                    ),
                ],
              ),
            )),
            const SizedBox(height: 20),

            // Bagian total 4 nutrisi makro yang disajikan dalam Grid 2x2 NutritionCard
            const Text('Total Gizi', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            // GridView.count: menampilkan 4 kartu nutrisi (Kalori, Protein, Karbohidrat, Lemak) secara rapi.
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                NutritionCard(label: 'Kalori',
                  value: history.totalCalories, unit: 'kcal',
                  color: AppColors.calories,
                  icon: Icons.local_fire_department_rounded),
                NutritionCard(label: 'Protein',
                  value: history.totalProtein, unit: 'g',
                  color: AppColors.protein,
                  icon: Icons.fitness_center_rounded),
                NutritionCard(label: 'Karbohidrat',
                  value: history.totalCarbs, unit: 'g',
                  color: AppColors.carbs,
                  icon: Icons.grain_rounded),
                NutritionCard(label: 'Lemak',
                  value: history.totalFat, unit: 'g',
                  color: AppColors.fat,
                  icon: Icons.water_drop_rounded),
              ],
            ),

            // Menampilkan bagian evaluasi rasa (sensorik) dan daya terima (konsumsi) jika tersedia
            if (history.sensoryData != null) ..._buildSensorySection(history.sensoryData!),
            if (history.consumptionData != null) ..._buildConsumptionSection(history.consumptionData!),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Merender kartu rincian evaluasi rasa, asin, manis, tekstur, dan aroma makanan.
  List<Widget> _buildSensorySection(SensoryData s) => [
    const SizedBox(height: 20),
    const Text('Data Sensorik', style: AppTextStyles.titleLarge),
    const SizedBox(height: 10),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _SensoryRow(emoji: '😋', label: 'Rasa', value: s.taste, score: s.tasteScore),
          const Divider(height: 16),
          _SensoryRow(emoji: '🧂', label: 'Tingkat Asin', value: s.saltLevel, showStars: false),
          const Divider(height: 16),
          _SensoryRow(emoji: '🍬', label: 'Tingkat Manis', value: s.sweetLevel, showStars: false),
          const Divider(height: 16),
          _SensoryRow(emoji: '🍽️', label: 'Tekstur', value: s.texture, score: s.textureScore),
          const Divider(height: 16),
          _SensoryRow(emoji: '👃', label: 'Aroma', value: s.aroma, score: s.aromaScore),
        ],
      ),
    ),
  ];

  // Merender kartu rincian porsi yang dimakan, jumlah sisa makanan, dan progress bar persentase habis.
  List<Widget> _buildConsumptionSection(ConsumptionData c) => [
    const SizedBox(height: 20),
    const Text('Data Konsumsi', style: AppTextStyles.titleLarge),
    const SizedBox(height: 10),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🥘', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Text('Porsi: ', style: AppTextStyles.bodySmall),
            Text(c.portionSize, style: AppTextStyles.titleSmall),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('🍱', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Text('Sisa: ', style: AppTextStyles.bodySmall),
            Text(c.leftoverAmount, style: AppTextStyles.titleSmall),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(
              c.isFinished ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: c.isFinished ? AppColors.success : AppColors.error,
              size: 18),
            const SizedBox(width: 8),
            Text(
              c.isFinished ? 'Makanan dihabiskan' : 'Makanan tidak dihabiskan',
              style: AppTextStyles.bodySmall.copyWith(
                color: c.isFinished ? AppColors.success : AppColors.error)),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dikonsumsi: ${c.consumptionPercentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall),
              Text('Sisa: ${c.leftoverPercentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 6),
          // ClipRRect + LinearProgressIndicator: menampilkan indikator batang warna hijau/kuning sesuai porsi makanan yang habis.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: c.consumptionPercentage / 100,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                c.consumptionPercentage >= 75 ? AppColors.success : AppColors.warning),
            ),
          ),
        ],
      ),
    ),
  ];
}

// Baris informasi satu parameter uji sensorik makanan (seperti rasa, tekstur, aroma) dilengkapi rating bintang.
class _SensoryRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final double? score;
  final bool showStars;

  const _SensoryRow({
    required this.emoji,
    required this.label,
    required this.value,
    this.score,
    this.showStars = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary)),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        // Menampilkan 5 ikon bintang kuning/abu-abu sesuai skor sensorik
        if (showStars && score != null)
          Row(
            children: List.generate(5, (i) => Icon(
              i < (score ?? 0).round()
                  ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < (score ?? 0).round()
                  ? AppColors.warning : AppColors.cardBorder,
              size: 14,
            )),
          ),
      ],
    );
  }
}
