/// Pilihan alergi makanan. Nilai (`value`) HARUS sama dengan backend
/// (backend/src/utils/allergy.ts → ALLOWED_ALLERGIES).
class AllergyOption {
  final String value;
  final String label;
  const AllergyOption(this.value, this.label);
}

class AllergyConstants {
  AllergyConstants._();

  /// Nilai khusus: pengguna memilih "Lainnya" dan mengisi teks sendiri.
  static const String otherValue = 'lainnya';

  /// Batas panjang teks "Lainnya" (sama dengan backend & kolom database).
  static const int otherMaxLength = 100;

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