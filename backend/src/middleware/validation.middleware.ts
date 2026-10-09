import { Request, Response, NextFunction } from 'express';
import { body } from 'express-validator';

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
    .optional()
    .isIn(['L', 'P'])
    .withMessage('Jenis kelamin harus L atau P'),
  body('age')
    .optional()
    .isInt({ min: 5, max: 100 })
    .withMessage('Umur harus antara 5-100 tahun'),
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
