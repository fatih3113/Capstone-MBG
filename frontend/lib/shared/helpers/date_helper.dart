/// Helper untuk format tanggal dan waktu dalam Bahasa Indonesia
library;

class DateHelper {
  DateHelper._();

  static const _dayNames = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  static const _monthNames = [
    '',
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  /// Format: "Senin, 9 Juni 2025"
  static String formatFull(DateTime date) {
    return '${_dayNames[date.weekday]}, ${date.day} ${_monthNames[date.month]} ${date.year}';
  }

  /// Format: "9 Juni 2025"
  static String formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month]} ${date.year}';
  }

  /// Format: "Senin, 9 Jun"
  static String formatShort(DateTime date) {
    return '${_dayNames[date.weekday]}, ${date.day} ${_monthNames[date.month].substring(0, 3)}';
  }

  /// Format: "14:30"
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format: "2 jam yang lalu" / "kemarin" / "3 hari lalu"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return 'kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return formatDate(date);
    }
  }

  /// Nama hari singkat untuk chart: "Sen", "Sel", dst
  static String dayShort(DateTime date) {
    const shorts = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return shorts[date.weekday];
  }

  /// Apakah tanggal hari ini?
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Format: "Senin" — nama hari lengkap
  static String dayName(DateTime date) => _dayNames[date.weekday];

  /// Format ISO: "2025-06-09"
  static String toIso(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
