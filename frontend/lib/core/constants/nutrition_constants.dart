// File ini menyimpan target harian zat gizi per jenjang pendidikan serta teks rekomendasi evaluasi gizi.

// NutritionConstants: konstanta nilai gizi harian dan pesan rekomendasi pola makan.
class NutritionConstants {
  NutritionConstants._();

  // Target kebutuhan gizi harian untuk jenjang SD.
  static const Map<String, double> dailyTargetSD = {
    'calories': 1600,
    'protein': 40,
    'carbs': 250,
    'fat': 50,
    'fiber': 20,
    'sugar': 50,
  };

  // Target kebutuhan gizi harian untuk jenjang SMP.
  static const Map<String, double> dailyTargetSMP = {
    'calories': 2000,
    'protein': 60,
    'carbs': 300,
    'fat': 65,
    'fiber': 25,
    'sugar': 60,
  };

  // Target kebutuhan gizi harian untuk jenjang SMA/SMK.
  static const Map<String, double> dailyTargetSMA = {
    'calories': 2200,
    'protein': 65,
    'carbs': 330,
    'fat': 70,
    'fiber': 28,
    'sugar': 65,
  };

  // MBG portion contribution (1 meal = ~35% of daily needs)
  static const double mbgPortionRatio = 0.35;

  // Batas persentase untuk menentukan status asupan rendah, normal, atau tinggi.
  static const double statusLow = 0.25;    // < 25% = rendah
  static const double statusNormal = 0.75; // 25-75% = normal
  static const double statusHigh = 1.0;    // > 75% = tinggi

  // Label teks untuk menampilkan ringkasan status gizi di kartu evaluasi.
  static const String statusLowLabel = 'Rendah';
  static const String statusNormalLabel = 'Normal';
  static const String statusHighLabel = 'Tinggi';
  static const String statusExcessLabel = 'Berlebih';

  // Pesan saran/rekomendasi berbasis status pencapaian nutrisi yang ditampilkan kepada siswa.
  static const Map<String, String> recommendations = {
    'protein_low': 'Asupan protein hari ini masih rendah. Konsumsi lebih banyak lauk pauk seperti ayam, telur, atau tahu tempe.',
    'protein_normal': 'Asupan protein hari ini sudah dalam rentang yang baik. Pertahankan!',
    'carbs_low': 'Asupan karbohidrat masih kurang. Pastikan mengonsumsi nasi atau makanan pokok lainnya.',
    'carbs_excess': 'Asupan karbohidrat berlebih. Kurangi konsumsi nasi atau makanan tinggi gula.',
    'fat_excess': 'Asupan lemak melebihi target. Kurangi makanan yang digoreng.',
    'fiber_low': 'Asupan serat masih rendah. Konsumsi lebih banyak sayuran dan buah-buahan.',
    'calories_normal': 'Asupan energi hari ini berada dalam rentang yang sesuai.',
    'calories_low': 'Asupan energi masih kurang. Pastikan tidak melewatkan makan.',
    'calories_excess': 'Asupan energi berlebih. Pertimbangkan untuk mengurangi porsi makan.',
    'vegetables_low': 'Pertimbangkan menambah konsumsi sayuran untuk memenuhi kebutuhan serat dan vitamin.',
    'fruits_low': 'Konsumsi buah-buahan lebih sering untuk mendapatkan vitamin dan antioksidan alami.',
  };
}
