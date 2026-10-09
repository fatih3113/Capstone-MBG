import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Green
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryLighter = Color(0xFFE8F5E9);
  static const Color primaryDark = Color(0xFF1B5E20);

  // Secondary - Orange accent
  static const Color secondary = Color(0xFFFF6F00);
  static const Color secondaryLight = Color(0xFFFFB300);
  static const Color secondaryLighter = Color(0xFFFFF8E1);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F8E9);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Nutrition colors
  static const Color calories = Color(0xFFFF6B6B);
  static const Color protein = Color(0xFF4ECDC4);
  static const Color carbs = Color(0xFFFFD93D);
  static const Color fat = Color(0xFFFF8C42);
  static const Color fiber = Color(0xFF6BCB77);
  static const Color sugar = Color(0xFFFF6584);

  // Card
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Gradient
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
  ];
  static const List<Color> heroGradient = [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF388E3C),
  ];
  static const List<Color> cardGradient = [
    Color(0xFFE8F5E9),
    Color(0xFFF1F8E9),
  ];
}
