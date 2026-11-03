// Komponen kartu ringkasan nutrisi: menampilkan angka capaian gizi (seperti kalori, protein, dll) beserta progress bar target harian dan versi chip ringkas.
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

// StatelessWidget: kartu penampil nilai nutrisi dan persentase ketercapaian dari target yang ditentukan.
class NutritionCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final double? target;
  final IconData? icon;

  const NutritionCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.target,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Menghitung persentase progres capaian terhadap target nutrisi (dibatasi 0.0 sampai 1.0).
    final percent = target != null && target! > 0
        ? (value / target!).clamp(0.0, 1.0)
        : null;

    // Container: wadah kartu dengan warna latar transparan beraksen dan sudut melengkung halus.
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      // Column: menyusun judul kartu, angka nutrisi, dan progress bar secara vertikal.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: menampilkan ikon bulat kecil di samping teks label nama nutrisi.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon ?? Icons.local_fire_department_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              )),
            ],
          ),
          const SizedBox(height: 10),
          // Text: menampilkan angka nilai nutrisi dalam format desimal yang rapi bersanding dengan satuannya.
          Text(
            '${AppFormatters.formatDecimal(value)} $unit',
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (percent != null) ...[
            const SizedBox(height: 8),
            // ClipRRect: melengkungkan kedua ujung batang LinearProgressIndicator.
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              // LinearProgressIndicator: garis visualisasi persentase capaian nutrisi terhadap target harian.
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppFormatters.formatPercent(percent * 100, decimals: 0)} dari target',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// Mini compact nutrition chip
// StatelessWidget: chip kapsul mini untuk menyajikan nilai gizi secara padat dan hemat tempat.
class NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const NutritionChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Container: kapsul kecil dengan border tipis bertema warna nutrisi bersangkutan.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      // Column: menyusun angka nilai di atas nama label nutrisi.
      child: Column(
        children: [
          Text(value, style: AppTextStyles.labelMedium.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
