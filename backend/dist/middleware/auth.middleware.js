"use strict";
// Middleware Autentikasi JWT: memverifikasi token bearer pada setiap request terproteksi dan menyematkan data identitas user (userId & email) ke objek request.
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
// Kunci rahasia untuk memvalidasi keaslian tanda tangan token JWT (diambil dari variabel environment .env).
const JWT_SECRET = process.env.JWT_SECRET || 'mbg_nutrition_secret_key_change_in_production';
// authMiddleware: fungsi penjaga pintu yang memeriksa apakah klien menyertakan header token yang sah sebelum mengizinkan akses ke rute API.
const authMiddleware = (req, res, next) => {
    // Mengambil nilai header 'Authorization' yang dikirim oleh aplikasi Flutter atau web klien.
    const authHeader = req.headers.authorization;
    // Menolak request jika header Authorization tidak ada atau tidak berawalan format 'Bearer '.
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({
            success: false,
            message: 'Token autentikasi diperlukan',
        });
        return;
    }
    // Memisahkan kata 'Bearer' dan mengambil token JWT-nya saja.
    const token = authHeader.split(' ')[1];
    try {
        // Memverifikasi tanda tangan digital token dan masa berlakunya secara kriptografis menggunakan secret key.
        const decoded = jsonwebtoken_1.default.verify(token, JWT_SECRET);
        // Menyimpan id dan email user ke objek req agar controller di urutan berikutnya tahu siapa yang membuat request.
        req.userId = decoded.userId;
        req.userEmail = decoded.email;
        next();
    }
    catch (error) {
        // Menangani kondisi saat token kedaluwarsa atau isi token tidak sah/rusak.
        if (error instanceof jsonwebtoken_1.default.TokenExpiredError) {
            res.status(401).json({
                success: false,
                message: 'Token telah kadaluarsa. Silakan login kembali.',
            });
        }
        else {
            res.status(401).json({
                success: false,
                message: 'Token tidak valid.',
            });
        }
    }
};
exports.authMiddleware = authMiddleware;
//# sourceMappingURL=auth.middleware.js.map