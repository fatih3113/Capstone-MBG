"use strict";
// Middleware Validasi Input: memastikan format data yang dikirim oleh pengguna pada payload request (login, register, update profil, simpan scan) sesuai aturan sebelum diproses controller.
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateSaveScan = exports.validateUpdateProfile = exports.validateRegister = exports.validateLogin = void 0;
const express_validator_1 = require("express-validator");
// Daftar nilai alergi makanan yang diizinkan dan diakui oleh sistem.
const VALID_ALLERGIES = ['kacang', 'telur', 'susu', 'ikan', 'udang', 'gandum', 'kedelai', 'lainnya'];
// Opsi "boleh kosong": nilai null, undefined, atau string kosong "" dianggap sah jika field opsional.
const EMPTY_OK = { nullable: true, checkFalsy: true };
// Aturan validasi data alergi makanan: array jenis alergi, teks catatan lainnya, dan status pengisian.
const allergyValidators = [
    (0, express_validator_1.body)('allergies')
        .optional({ nullable: true })
        .isArray()
        .withMessage('allergies harus berupa array'),
    (0, express_validator_1.body)('allergies.*')
        .optional({ nullable: true })
        .trim()
        .toLowerCase() // "Kacang" dari Flutter tetap diterima
        .isIn(VALID_ALLERGIES)
        .withMessage(`Nilai alergi tidak valid. Pilihan yang diizinkan: ${VALID_ALLERGIES.join(', ')}`),
    (0, express_validator_1.body)('allergyOther')
        .optional({ nullable: true })
        .isString()
        .trim()
        .isLength({ max: 100 })
        .withMessage('Keterangan alergi lainnya maksimal 100 karakter'),
    (0, express_validator_1.body)('allergyFilled')
        .optional({ nullable: true })
        .isBoolean()
        .withMessage('allergyFilled harus bernilai boolean'),
];
// Validasi formulir login: memastikan format email benar dan password tidak kosong.
exports.validateLogin = [
    (0, express_validator_1.body)('email')
        .isEmail()
        .withMessage('Format email tidak valid')
        .normalizeEmail(),
    (0, express_validator_1.body)('password')
        .notEmpty()
        .withMessage('Password tidak boleh kosong'),
];
// Validasi formulir registrasi: nama, format email, panjang minimal password, gender, umur, SPPG, dan data alergi.
exports.validateRegister = [
    (0, express_validator_1.body)('name')
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Nama harus antara 2-100 karakter'),
    (0, express_validator_1.body)('email')
        .isEmail()
        .withMessage('Format email tidak valid')
        .normalizeEmail(),
    (0, express_validator_1.body)('password')
        .isLength({ min: 8 })
        .withMessage('Password minimal 8 karakter'),
    (0, express_validator_1.body)('gender')
        .optional(EMPTY_OK)
        .isIn(['L', 'P'])
        .withMessage('Jenis kelamin harus L atau P'),
    // min 0: peserta posyandu bisa balita (siswa sekolah tetap divalidasi min 5 di aplikasi)
    (0, express_validator_1.body)('age')
        .optional(EMPTY_OK)
        .isInt({ min: 0, max: 100 })
        .withMessage('Umur harus antara 0-100 tahun'),
    // Keberadaan SPPG dicek ke database di controller
    (0, express_validator_1.body)('sppg_id')
        .optional(EMPTY_OK)
        .isString()
        .trim()
        .notEmpty()
        .withMessage('Format sppg_id tidak valid'),
    // Keberadaan sekolah dicek ke database di controller ("Sekolah tidak ditemukan")
    (0, express_validator_1.body)('school_id')
        .optional(EMPTY_OK)
        .isString()
        .trim()
        .notEmpty()
        .withMessage('Format school_id tidak valid'),
    ...allergyValidators,
];
// Validasi pembaruan profil pengguna: memeriksa format data alergi jika dikirim.
exports.validateUpdateProfile = [
    ...allergyValidators,
];
// Validasi penyimpanan hasil scan: memeriksa total kalori, protein, dan array hasil deteksi makanan beserta confidence score.
exports.validateSaveScan = [
    (0, express_validator_1.body)('total_calories').isFloat({ min: 0 }).withMessage('Total kalori tidak valid'),
    (0, express_validator_1.body)('total_protein').isFloat({ min: 0 }).withMessage('Total protein tidak valid'),
    (0, express_validator_1.body)('predictions').isArray({ min: 1 }).withMessage('Prediksi tidak boleh kosong'),
    (0, express_validator_1.body)('predictions.*.food_id').notEmpty().withMessage('Food ID diperlukan'),
    (0, express_validator_1.body)('predictions.*.confidence')
        .isFloat({ min: 0, max: 1 })
        .withMessage('Confidence harus antara 0-1'),
];
//# sourceMappingURL=validation.middleware.js.map