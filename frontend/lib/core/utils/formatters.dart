/// Formatters utility - Indonesian locale date/number formatting
library;
import 'package:intl/intl.dart';

class AppFormatters {
  // ─── Number Formatters ─────────────────────────────────────────────
  static String formatDecimal(double value, {int decimals = 1}) {
    final format = NumberFormat('#,##0.${'0' * decimals}', 'id_ID');
    return format.format(value);
  }

  static String formatPercent(double value, {int decimals = 1}) {
    return '${formatDecimal(value, decimals: decimals)}%';
  }

  static String formatKcal(double value) {
    return '${value.toStringAsFixed(0)} kcal';
  }

  static String formatGrams(double value) {
    return '${formatDecimal(value)}g';
  }

  // ─── Date Formatters ───────────────────────────────────────────────
  static String formatDate(DateTime date) {
    return DateFormat('d MMMM y', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('d MMM y, HH:mm', 'id_ID').format(dt);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('HH:mm', 'id_ID').format(dt);
  }

  static String formatDayMonth(DateTime dt) {
    return DateFormat('d/M', 'id_ID').format(dt);
  }

  static String formatDayName(DateTime dt) {
    return DateFormat('EEEE', 'id_ID').format(dt);
  }

  static String formatRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return formatDate(dt);
  }

  static String formatShortDate(DateTime dt) {
    return DateFormat('dd MMM', 'id_ID').format(dt);
  }
}
