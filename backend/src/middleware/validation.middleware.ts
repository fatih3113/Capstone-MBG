import { body } from 'express-validator';

// Nilai alergi yang diizinkan
const VALID_ALLERGIES = ['kacang', 'telur', 'susu', 'ikan', 'udang', 'gandum', 'kedelai', 'lainnya'];

// Opsi "boleh kosong": undefined, null, "" dianggap tidak diisi.
// (Kompatibel dengan express-validator v6 dan v7)
const EMPTY_OK = { nullable: true, checkFalsy: true } as const;

// Validasi field alergi (dipakai di register & update profil)
const allergyValidators = [
  body('allergies')
    .optional({ nullable: true })
    .isArray()
    .withMessage('allergies harus berupa array'),
  body('allergies.*')
    .optional({ nullable: true })
    .trim()
    .toLowerCase() // "Kacang" dari Flutter tetap diterima
    .isIn(VALID_ALLERGIES)
    .withMessage(`Nilai alergi tidak valid. Pilihan yang diizinkan: ${VALID_ALLERGIES.join(', ')}`),
  body('allergyOther')
    .optional({ nullable: true })
    .isString()
    .trim()
    .isLength({ max: 100 })
    .withMessage('Keterangan alergi lainnya maksimal 100 karakter'),
  body('allergyFilled')
    .optional({ nullable: true })
    .isBoolean()
    .withMessage('allergyFilled harus bernilai boolean'),
];

export const validateLogin = [
  body('email')
    .isEmail()
    .withMessage('Format email tidak valid')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password tidak boleh kosong'),
];

export const validateRegister = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Nama harus antara 2-100 karakter'),
  body('email')
    .isEmail()
    .withMessage('Format email tidak valid')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password minimal 8 karakter'),
  body('gender')
    .optional(EMPTY_OK)
    .isIn(['L', 'P'])
    .withMessage('Jenis kelamin harus L atau P'),
  // min 0: peserta posyandu bisa balita (siswa sekolah tetap divalidasi min 5 di aplikasi)
  body('age')
    .optional(EMPTY_OK)
    .isInt({ min: 0, max: 100 })
    .withMessage('Umur harus antara 0-100 tahun'),
  // Sebelumnya isUUID(). Dibuat longgar: keberadaan SPPG tetap dicek ke database
  // di controller ("SPPG tidak ditemukan"), jadi format ID tidak perlu dikunci di sini.
  body('sppg_id')
    .optional(EMPTY_OK)
    .isString()
    .trim()
    .notEmpty()
    .withMessage('Format sppg_id tidak valid'),
  // Keberadaan sekolah dicek ke database di controller ("Sekolah tidak ditemukan")
  body('school_id')
    .optional(EMPTY_OK)
    .isString()
    .trim()
    .notEmpty()
    .withMessage('Format school_id tidak valid'),
  ...allergyValidators,
];

export const validateUpdateProfile = [
  ...allergyValidators,
];

export const validateSaveScan = [
  body('total_calories').isFloat({ min: 0 }).withMessage('Total kalori tidak valid'),
  body('total_protein').isFloat({ min: 0 }).withMessage('Total protein tidak valid'),
  body('predictions').isArray({ min: 1 }).withMessage('Prediksi tidak boleh kosong'),
  body('predictions.*.food_id').notEmpty().withMessage('Food ID diperlukan'),
  body('predictions.*.confidence')
    .isFloat({ min: 0, max: 1 })
    .withMessage('Confidence harus antara 0-1'),
];