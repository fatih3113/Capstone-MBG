"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const express_validator_1 = require("express-validator");
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const logger_1 = require("../utils/logger");
const allergy_1 = require("../utils/allergy");
const prisma = new client_1.PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'mbg_nutrition_secret_key_change_in_production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';
/** Cetak detail error validasi ke terminal (password disamarkan). */
const logValidationErrors = (label, errors) => {
    const detail = errors.map((e) => {
        const field = e.path ?? e.param;
        return { field, message: e.msg, value: field === 'password' ? '***' : e.value };
    });
    logger_1.logger.warn(`${label}: ${JSON.stringify(detail)}`);
};
class AuthController {
    constructor() {
        /**
         * POST /auth/register
         */
        this.register = async (req, res, next) => {
            try {
                // 422 #1: aturan di validators.ts (validateRegister)
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    logValidationErrors('[REGISTER] Validasi gagal', errors.array());
                    res.status(422).json(api_response_1.ApiResponse.validationError(errors.array()));
                    return;
                }
                const { name, email, password, school_id, sppg_id, class: className, gender, age } = req.body;
                // 422 #2: data alergi
                const allergy = (0, allergy_1.parseAllergyInput)(req.body);
                if (!allergy.ok) {
                    logger_1.logger.warn(`[REGISTER] Data alergi ditolak: ${allergy.message}`);
                    res.status(422).json(api_response_1.ApiResponse.error(allergy.message, 422));
                    return;
                }
                // Check if email already exists
                const existingUser = await prisma.user.findUnique({ where: { email } });
                if (existingUser) {
                    res.status(409).json(api_response_1.ApiResponse.error('Email sudah terdaftar', 409));
                    return;
                }
                // 422 #3: sppg_id (jika disertakan) harus ada & aktif di database
                if (sppg_id) {
                    const sppg = await prisma.sppg.findUnique({ where: { id: sppg_id } });
                    if (!sppg) {
                        logger_1.logger.warn(`[REGISTER] SPPG tidak ditemukan untuk sppg_id: ${sppg_id}`);
                        res.status(422).json(api_response_1.ApiResponse.error('SPPG tidak ditemukan', 422));
                        return;
                    }
                    if (!sppg.isActive) {
                        res.status(422).json(api_response_1.ApiResponse.error('SPPG yang dipilih sudah tidak aktif', 422));
                        return;
                    }
                }
                // 422 #4: school_id (jika disertakan) harus ada; jenjang diambil dari sekolah
                let schoolLevel;
                if (school_id) {
                    const school = await prisma.school.findUnique({ where: { id: school_id } });
                    if (!school) {
                        logger_1.logger.warn(`[REGISTER] Sekolah tidak ditemukan untuk school_id: ${school_id}`);
                        res.status(422).json(api_response_1.ApiResponse.error('Sekolah tidak ditemukan', 422));
                        return;
                    }
                    if (sppg_id && school.sppgId && school.sppgId !== sppg_id) {
                        res.status(422).json(api_response_1.ApiResponse.error('Sekolah tidak terdaftar pada SPPG yang dipilih', 422));
                        return;
                    }
                    schoolLevel = school.level; // SD | SMP | SMA | SMK → tampil di Profil (Jenjang)
                }
                // Hash password
                const passwordHash = await bcryptjs_1.default.hash(password, 12);
                // Create user
                const user = await prisma.user.create({
                    data: {
                        name,
                        email,
                        passwordHash,
                        schoolId: school_id || undefined,
                        schoolLevel,
                        sppgId: sppg_id || undefined,
                        class_: className,
                        gender: gender || undefined,
                        age: age !== undefined && age !== null && age !== '' ? parseInt(age) : null,
                        ...(0, allergy_1.allergyDbFields)(allergy),
                    },
                    select: {
                        id: true, name: true, email: true,
                        class_: true, gender: true, age: true,
                        schoolId: true, schoolLevel: true, createdAt: true,
                    },
                });
                logger_1.logger.info(`New user registered: ${email}`);
                res.status(201).json(api_response_1.ApiResponse.success(user, 'Registrasi berhasil'));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * POST /auth/login
         */
        this.login = async (req, res, next) => {
            try {
                const errors = (0, express_validator_1.validationResult)(req);
                if (!errors.isEmpty()) {
                    logValidationErrors('[LOGIN] Validasi gagal', errors.array());
                    res.status(422).json(api_response_1.ApiResponse.validationError(errors.array()));
                    return;
                }
                const { email, password } = req.body;
                // Find user
                const user = await prisma.user.findUnique({
                    where: { email },
                    include: {
                        school: { select: { name: true } },
                        sppg: { select: { nama: true, provinsi: true, kabupatenKota: true } },
                    },
                });
                if (!user) {
                    res.status(401).json(api_response_1.ApiResponse.error('Email atau password salah', 401));
                    return;
                }
                // Verify password
                const isPasswordValid = await bcryptjs_1.default.compare(password, user.passwordHash);
                if (!isPasswordValid) {
                    res.status(401).json(api_response_1.ApiResponse.error('Email atau password salah', 401));
                    return;
                }
                // Generate JWT token
                const token = jsonwebtoken_1.default.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
                const userData = {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    school_name: user.school?.name,
                    class: user.class_,
                    gender: user.gender,
                    age: user.age,
                    school_level: user.schoolLevel,
                    sppg_id: user.sppgId,
                    sppg_name: user.sppg?.nama ?? null,
                    provinsi: user.sppg?.provinsi ?? null,
                    kabupaten_kota: user.sppg?.kabupatenKota ?? null,
                    // Data alergi hanya untuk pemilik akun (login)
                    allergies: user.allergies,
                    allergy_other: user.allergyOther,
                    allergy_filled: user.allergyFilled,
                };
                logger_1.logger.info(`User logged in: ${email}`);
                res.json(api_response_1.ApiResponse.success({ token, user: userData }, 'Login berhasil'));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * POST /auth/logout
         */
        this.logout = async (_req, res) => {
            // JWT is stateless; client should delete the token
            // For production, implement token blacklisting with Redis
            res.json(api_response_1.ApiResponse.success(null, 'Logout berhasil'));
        };
        /**
         * POST /auth/forgot-password
         */
        this.forgotPassword = async (req, res, next) => {
            try {
                const { email } = req.body;
                const user = await prisma.user.findUnique({ where: { email } });
                // Always return success to prevent email enumeration
                if (user) {
                    // TODO: Send password reset email via mail service (e.g., Nodemailer + SendGrid)
                    logger_1.logger.info(`Password reset requested for: ${email}`);
                }
                res.json(api_response_1.ApiResponse.success(null, 'Jika email terdaftar, link reset password akan dikirim'));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * POST /auth/reset-password
         */
        this.resetPassword = async (req, res, next) => {
            try {
                const { token, new_password } = req.body;
                // TODO: Verify reset token and update password
                res.json(api_response_1.ApiResponse.success(null, 'Password berhasil diubah'));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.AuthController = AuthController;
//# sourceMappingURL=auth.controller.js.map