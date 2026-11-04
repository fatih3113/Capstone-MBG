"use strict";
// Entry point utama server backend Express: mengatur konfigurasi CORS, keamanan HTTP (Helmet & Rate Limiting), penyajian file statis, seluruh rute API, dan penanganan error terpusat.
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const dotenv_1 = __importDefault(require("dotenv"));
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const user_routes_1 = __importDefault(require("./routes/user.routes"));
const food_routes_1 = __importDefault(require("./routes/food.routes"));
const nutrition_routes_1 = __importDefault(require("./routes/nutrition.routes"));
const mbg_menu_routes_1 = __importDefault(require("./routes/mbg-menu.routes"));
const prediction_routes_1 = __importDefault(require("./routes/prediction.routes"));
const scan_history_routes_1 = __importDefault(require("./routes/scan-history.routes"));
const school_routes_1 = __importDefault(require("./routes/school.routes"));
const stats_routes_1 = __importDefault(require("./routes/stats.routes"));
const report_routes_1 = __importDefault(require("./routes/report.routes"));
const admin_routes_1 = __importDefault(require("./routes/admin.routes"));
const sppg_routes_1 = __importDefault(require("./routes/sppg.routes"));
const notification_routes_1 = __importDefault(require("./routes/notification.routes")); // ← BARU
const error_middleware_1 = require("./middleware/error.middleware");
const logger_1 = require("./utils/logger");
// Memuat variabel konfigurasi dari file .env ke dalam environment Node.js.
dotenv_1.default.config();
// Inisialisasi aplikasi Express dan definisi konstanta server.
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
const API_PREFIX = '/api/v1';
const isProduction = process.env.NODE_ENV === 'production';
// ─── CORS ─────────────────────────────────────────────────────────────
// Konfigurasi CORS: mengizinkan akses dari aplikasi mobile, web dashboard, dan pengujian lokal.
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
// Regex untuk mendeteksi alamat localhost saat pengembangan web Flutter.
const localhostRegex = /^http:\/\/(localhost|127\.0\.0\.1):\d+$/;
const corsOptions = {
    origin: (origin, callback) => {
        // Request tanpa origin (seperti Postman, curl, dan aplikasi mobile Flutter native) otomatis diizinkan.
        if (!origin)
            return callback(null, true);
        if (allowedOrigins.includes(origin))
            return callback(null, true);
        if (!isProduction && localhostRegex.test(origin))
            return callback(null, true);
        logger_1.logger.warn(`CORS ditolak untuk origin: ${origin}`);
        return callback(null, false); // Menolak request tak dikenal secara rapi tanpa crash.
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
};
// ─── SECURITY MIDDLEWARE ──────────────────────────────────────────────
// CORS dipasang paling awal agar preflight (OPTIONS) selalu terjawab dengan cepat.
app.use((0, cors_1.default)(corsOptions));
app.options('*', (0, cors_1.default)(corsOptions));
// Helmet: mengamankan HTTP header aplikasi dari kerentanan umum di web.
app.use((0, helmet_1.default)({
    // crossOriginResourcePolicy diatur cross-origin agar gambar statis di /uploads dapat dimuat oleh aplikasi mobile.
    crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
// Rate limiting: membatasi frekuensi request per IP untuk mencegah serangan brute-force atau spam request.
const limiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // Jendela waktu 15 menit.
    max: isProduction ? 100 : 1000, // Maksimal jumlah request per jendela waktu.
    message: { success: false, message: 'Terlalu banyak permintaan, coba lagi nanti.' },
    skip: (req) => req.method === 'OPTIONS', // Request preflight tidak dihitung ke limit.
});
app.use(limiter);
// ─── GENERAL MIDDLEWARE ───────────────────────────────────────────────
// Morgan: mencatat log setiap request HTTP yang masuk ke terminal.
app.use((0, morgan_1.default)('combined'));
// Parser body request: membaca payload berformat JSON dan URL-encoded hingga batas 10MB.
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true }));
// Menyajikan folder uploads sebagai file statis publik (untuk foto profil dan foto scan makanan).
app.use('/uploads', express_1.default.static('uploads'));
// ─── HEALTH CHECK ─────────────────────────────────────────────────────
// Endpoint pengecekan status hidup server untuk monitoring atau load balancer.
app.get('/health', (_, res) => {
    res.json({
        success: true,
        message: 'MBG Nutrition API is running',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
    });
});
// ─── API ROUTES ───────────────────────────────────────────────────────
// Pendaftaran seluruh modul rute API dengan prefix standar /api/v1.
app.use(`${API_PREFIX}/auth`, auth_routes_1.default);
app.use(`${API_PREFIX}/users`, user_routes_1.default);
app.use(`${API_PREFIX}/foods`, food_routes_1.default);
app.use(`${API_PREFIX}/nutrition`, nutrition_routes_1.default);
app.use(`${API_PREFIX}/mbg-menu`, mbg_menu_routes_1.default);
app.use(`${API_PREFIX}/predictions`, prediction_routes_1.default);
app.use(`${API_PREFIX}/scan-history`, scan_history_routes_1.default);
app.use(`${API_PREFIX}/schools`, school_routes_1.default);
app.use(`${API_PREFIX}/stats`, stats_routes_1.default);
app.use(`${API_PREFIX}/reports`, report_routes_1.default);
app.use(`${API_PREFIX}/admin`, admin_routes_1.default);
app.use(`${API_PREFIX}/sppg`, sppg_routes_1.default);
app.use(`${API_PREFIX}/notifications`, notification_routes_1.default);
// ─── 404 HANDLER ─────────────────────────────────────────────────────
// Menangkap request yang rutenya tidak terdaftar dan memberikan respon error JSON 404.
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: `Endpoint tidak ditemukan: ${req.method} ${req.originalUrl}`,
    });
});
// ─── ERROR HANDLER ────────────────────────────────────────────────────
// Middleware penanganan error global terpusat agar server tidak crash jika terjadi exception.
app.use(error_middleware_1.errorHandler);
// ─── START SERVER ─────────────────────────────────────────────────────
// Menjalankan server HTTP pada port yang ditentukan dan mencatat log saat siap menerima request.
app.listen(PORT, () => {
    logger_1.logger.info(`🚀 MBG Nutrition API running on port ${PORT}`);
    logger_1.logger.info(`📖 API docs: http://localhost:${PORT}/health`);
});
exports.default = app;
//# sourceMappingURL=index.js.map