// Middleware Validasi Input: memastikan format data yang dikirim oleh pengguna pada payload request (login, register, update profil, simpan scan) sesuai aturan sebelum diproses controller.

import { body } from 'express-validator';

// Daftar nilai alergi makanan yang diizinkan dan diakui oleh sistem.
const VALID_ALLERGIES = ['kacang', 'telur', 'susu', 'ikan', 'udang', 'gandum', 'kedelai', 'lainnya'];

// Opsi "boleh kosong": nilai null, undefined, atau string kosong "" dianggap sah jika field opsional.
const EMPTY_OK = { nullable: true, checkFalsy: true } as const;

// Aturan validasi data alergi makanan: array jenis alergi, teks catatan lainnya, dan status pengisian.
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

// Validasi formulir login: memastikan format email benar dan password tidak kosong.
export const validateLogin = [
  body('email')
    .isEmail()
    .withMessage('Format email tidak valid')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password tidak boleh kosong'),
];

// Validasi formulir registrasi: nama, format email, panjang minimal password, gender, umur, SPPG, dan data alergi.
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
  // Keberadaan SPPG dicek ke database di controller
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

// Validasi pembaruan profil pengguna: memeriksa format data alergi jika dikirim.
export const validateUpdateProfile = [
  ...allergyValidators,
];

// Validasi penyimpanan hasil scan: memeriksa total kalori, protein, dan array hasil deteksi makanan beserta confidence score.
export const validateSaveScan = [
  body('total_calories').isFloat({ min: 0 }).withMessage('Total kalori tidak valid'),
  body('total_protein').isFloat({ min: 0 }).withMessage('Total protein tidak valid'),
  body('predictions').isArray({ min: 1 }).withMessage('Prediksi tidak boleh kosong'),
  body('predictions.*.food_id').notEmpty().withMessage('Food ID diperlukan'),
  body('predictions.*.confidence')
    .isFloat({ min: 0, max: 1 })
    .withMessage('Confidence harus antara 0-1'),
];