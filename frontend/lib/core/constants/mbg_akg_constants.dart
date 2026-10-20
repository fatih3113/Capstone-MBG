/// AKG MBG (Angka Kecukupan Gizi) - Referensi untuk satu kali makan MBG
///
/// Sumber: Tabel AKG MBG yang diberikan oleh tim Foodler (internal reference).
/// ⚠️  PERHATIAN: Nilai ini harus diverifikasi terhadap sumber resmi
///     (Permenkes AKG atau regulasi MBG terbaru) sebelum digunakan
///     sebagai rekomendasi gizi resmi.
///
/// Struktur tiap sasaran: { energiMin, energiMax, proteinMin, proteinMax,
///                          lemakMin, lemakMax, karbohidratMin, karbohidratMax }
/// Satuan: energi = kkal, protein/lemak/karbohidrat = gram
class MbgAkgConstants {
  MbgAkgConstants._();

  /// Kelompok sasaran utama MBG (sekolah)
  static const List<MbgSasaran> sasaranUtama = [
    MbgSasaran(
      id: 'tk_paud',
      label: 'TK/PAUD',
      energiMin: 125, energiMax: 175,
      proteinMin: 5,  proteinMax: 8,
      lemakMin: 3,    lemakMax: 6,
      karbohidratMin: 18, karbohidratMax: 27,
    ),
    MbgSasaran(
      id: 'sd_1_3',
      label: 'MI/SD Kelas 1–3',
      energiMin: 150, energiMax: 225,
      proteinMin: 6,  proteinMax: 10,
      lemakMin: 4,    lemakMax: 7,
      karbohidratMin: 22, karbohidratMax: 34,
    ),
    MbgSasaran(
      id: 'sd_4_6',
      label: 'MI/SD Kelas 4–6',
      energiMin: 175, energiMax: 263,
      proteinMin: 8,  proteinMax: 12,
      lemakMin: 5,    lemakMax: 9,
      karbohidratMin: 26, karbohidratMax: 39,
    ),
    MbgSasaran(
      id: 'smp_mts',
      label: 'SMP/MTs',
      energiMin: 200, energiMax: 300,
      proteinMin: 10, proteinMax: 15,
      lemakMin: 6,    lemakMax: 11,
      karbohidratMin: 30, karbohidratMax: 45,
    ),
    MbgSasaran(
      id: 'sma_smk',
      label: 'MA/SMA/SMK',
      energiMin: 225, energiMax: 338,
      proteinMin: 11, proteinMax: 17,
      lemakMin: 6,    lemakMax: 12,
      karbohidratMin: 33, karbohidratMax: 50,
    ),
  ];

  /// Kelompok sasaran tambahan
  static const List<MbgSasaran> sasaranTambahan = [
    MbgSasaran(
      id: 'balita',
      label: 'Balita (1–5 tahun)',
      energiMin: 100, energiMax: 150,
      proteinMin: 4,  proteinMax: 7,
      lemakMin: 3,    lemakMax: 5,
      karbohidratMin: 15, karbohidratMax: 22,
    ),
    MbgSasaran(
      id: 'ibu_hamil',
      label: 'Ibu Hamil',
      energiMin: 250, energiMax: 375,
      proteinMin: 14, proteinMax: 20,
      lemakMin: 7,    lemakMax: 13,
      karbohidratMin: 37, karbohidratMax: 56,
    ),
    MbgSasaran(
      id: 'ibu_menyusui',
      label: 'Ibu Menyusui',
      energiMin: 275, energiMax: 413,
      proteinMin: 15, proteinMax: 22,
      lemakMin: 8,    lemakMax: 14,
      karbohidratMin: 41, karbohidratMax: 62,
    ),
  ];

  /// Cari sasaran berdasarkan ID
  static MbgSasaran? findById(String id) {
    final allSasaran = [...sasaranUtama, ...sasaranTambahan];
    try {
      return allSasaran.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static const String disclaimer =
      '⚠️ Data AKG MBG ini merupakan referensi estimasi. '
      'Verifikasi terhadap sumber resmi (Permenkes/regulasi MBG) diperlukan '
      'sebelum digunakan sebagai rekomendasi gizi resmi.';

  static const String dataSource =
      'Referensi: Tabel AKG MBG internal Foodler. '
      'Didasarkan pada AKG Indonesia (Permenkes No. 28/2019) '
      'dengan estimasi proporsi 1 kali makan MBG.';
}

/// Model data sasaran AKG MBG untuk satu kali makan
class MbgSasaran {
  final String id;
  final String label;

  // Rentang energi (kkal)
  final double energiMin;
  final double energiMax;

  // Rentang protein (gram)
  final double proteinMin;
  final double proteinMax;

  // Rentang lemak (gram)
  final double lemakMin;
  final double lemakMax;

  // Rentang karbohidrat (gram)
  final double karbohidratMin;
  final double karbohidratMax;

  const MbgSasaran({
    required this.id,
    required this.label,
    required this.energiMin,
    required this.energiMax,
    required this.proteinMin,
    required this.proteinMax,
    required this.lemakMin,
    required this.lemakMax,
    required this.karbohidratMin,
    required this.karbohidratMax,
  });

  /// Status perbandingan gizi vs target
  /// Returns: 'below' | 'within' | 'above'
  String compareEnergy(double value) => _compare(value, energiMin, energiMax);
  String compareProtein(double value) => _compare(value, proteinMin, proteinMax);
  String compareLemak(double value) => _compare(value, lemakMin, lemakMax);
  String compareKarbohidrat(double value) =>
      _compare(value, karbohidratMin, karbohidratMax);

  String _compare(double value, double min, double max) {
    if (value < min) return 'below';
    if (value > max) return 'above';
    return 'within';
  }
}

/// Label untuk status perbandingan AKG
extension AkgStatusLabel on String {
  String get akgStatusLabel {
    switch (this) {
      case 'below':
        return 'Di Bawah Rentang';
      case 'within':
        return 'Dalam Rentang';
      case 'above':
        return 'Di Atas Rentang';
      default:
        return '-';
    }
  }

  /// Warna berdasarkan status (gunakan AppColors di widget)
  bool get isWithin => this == 'within';
  bool get isBelow => this == 'below';
  bool get isAbove => this == 'above';
}
