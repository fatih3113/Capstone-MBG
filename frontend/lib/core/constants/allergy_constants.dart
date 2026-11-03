// File ini berisi daftar opsi dan konstanta alergi makanan yang digunakan pada form profil dan registrasi.

// AllergyOption: model sederhana untuk memegang pasangan nilai dan teks label opsi alergi.
class AllergyOption {
  final String value;
  final String label;
  const AllergyOption(this.value, this.label);
}

// AllergyConstants: kumpulan konstanta opsi alergi makanan yang didukung sistem MBG.
class AllergyConstants {
  AllergyConstants._();

  /// Nilai khusus: pengguna memilih "Lainnya" dan mengisi teks sendiri.
  static const String otherValue = 'lainnya';

  /// Batas panjang teks "Lainnya" (sama dengan backend & kolom database).
  static const int otherMaxLength = 100;

  // Daftar pilihan alergi yang ditampilkan sebagai opsi chip pada aplikasi.
  static const List<AllergyOption> options = [
    AllergyOption('kacang', 'Kacang'),
    AllergyOption('telur', 'Telur'),
    AllergyOption('susu', 'Susu'),
    AllergyOption('ikan', 'Ikan'),
    AllergyOption('udang', 'Udang'),
    AllergyOption('gandum', 'Gandum'),
    AllergyOption('kedelai', 'Kedelai'),
    AllergyOption(otherValue, 'Lainnya'),
  ];

  /// Label tampilan untuk sebuah nilai alergi.
  static String labelOf(String value) {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return value;
  }
}
