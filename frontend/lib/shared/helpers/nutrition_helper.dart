/// Helper functions untuk format angka gizi, teks, dan warna
library;

import 'package:flutter/material.dart';

class NutritionHelper {
  NutritionHelper._();

  // ─── Format angka ─────────────────────────────────────────────────────
  static String formatCalories(double cal) {
    if (cal >= 1000) {
      return '${(cal / 1000).toStringAsFixed(1)} kkal';
    }
    return '${cal.toStringAsFixed(0)} kkal';
  }

  static String formatGrams(double grams) {
    if (grams < 1) return '${(grams * 1000).toStringAsFixed(0)} mg';
    return '${grams.toStringAsFixed(1)} g';
  }

  static String formatPercentage(double fraction) {
    return '${(fraction * 100).toStringAsFixed(0)}%';
  }

  // ─── Status gizi ──────────────────────────────────────────────────────
  /// Kembalikan label & warna berdasarkan persentase pencapaian target
  static ({String label, Color color, IconData icon}) getNutritionStatus(
    double percentage,
  ) {
    if (percentage < 0.5) {
      return (
        label: 'Sangat Kurang',
        color: const Color(0xFFEF4444),
        icon: Icons.warning_rounded,
      );
    } else if (percentage < 0.75) {
      return (
        label: 'Kurang',
        color: const Color(0xFFF97316),
        icon: Icons.info_outline_rounded,
      );
    } else if (percentage <= 1.1) {
      return (
        label: 'Cukup',
        color: const Color(0xFF22C55E),
        icon: Icons.check_circle_rounded,
      );
    } else {
      return (
        label: 'Berlebih',
        color: const Color(0xFFEAB308),
        icon: Icons.warning_amber_rounded,
      );
    }
  }

  // ─── Warna kategori makanan ───────────────────────────────────────────
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Karbohidrat':
        return const Color(0xFFF59E0B);
      case 'Protein Hewani':
        return const Color(0xFFEF4444);
      case 'Protein Nabati':
        return const Color(0xFF8B5CF6);
      case 'Sayuran':
        return const Color(0xFF22C55E);
      case 'Buah':
        return const Color(0xFF3B82F6);
      case 'Minuman':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Karbohidrat':
        return Icons.rice_bowl_rounded;
      case 'Protein Hewani':
        return Icons.set_meal_rounded;
      case 'Protein Nabati':
        return Icons.eco_rounded;
      case 'Sayuran':
        return Icons.grass_rounded;
      case 'Buah':
        return Icons.apple_rounded;
      case 'Minuman':
        return Icons.local_drink_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  // ─── Rekomendasi AKG berdasarkan profil ──────────────────────────────
  /// Hitung kebutuhan kalori harian berdasarkan usia, jenis kelamin, jenjang
  static Map<String, double> calculateDailyNeeds({
    required String schoolLevel,
    required String gender,
  }) {
    final isLaki = gender == 'L';

    switch (schoolLevel) {
      case 'SD':
        return {
          'calories': isLaki ? 1850 : 1750,
          'protein': isLaki ? 49 : 45,
          'carbs': isLaki ? 265 : 250,
          'fat': isLaki ? 62 : 58,
          'fiber': 22,
        };
      case 'SMP':
        return {
          'calories': isLaki ? 2200 : 2000,
          'protein': isLaki ? 60 : 55,
          'carbs': isLaki ? 315 : 285,
          'fat': isLaki ? 73 : 67,
          'fiber': 26,
        };
      default: // SMA/SMK
        return {
          'calories': isLaki ? 2650 : 2100,
          'protein': isLaki ? 75 : 59,
          'carbs': isLaki ? 375 : 300,
          'fat': isLaki ? 88 : 70,
          'fiber': 30,
        };
    }
  }

  // ─── Confidence level ML ──────────────────────────────────────────────
  static String confidenceLabel(double confidence) {
    if (confidence >= 0.9) return 'Sangat Yakin';
    if (confidence >= 0.75) return 'Yakin';
    if (confidence >= 0.6) return 'Cukup Yakin';
    return 'Kurang Yakin';
  }

  static Color confidenceColor(double confidence) {
    if (confidence >= 0.9) return const Color(0xFF22C55E);
    if (confidence >= 0.75) return const Color(0xFF3B82F6);
    if (confidence >= 0.6) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }
}
