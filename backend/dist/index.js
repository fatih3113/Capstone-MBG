"use strict";
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
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
const API_PREFIX = '/api/v1';
const isProduction = process.env.NODE_ENV === 'production';
// ─── CORS ─────────────────────────────────────────────────────────────
// Daftar origin tambahan dari .env, contoh:
// ALLOWED_ORIGINS=https://app-anda.com,https://dashboard-anda.com
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
// Flutter Web memakai port acak saat development, jadi semua localhost diizinkan
// (hanya di luar production).
const localhostRegex = /^http:\/\/(localhost|127\.0\.0\.1):\d+$/;
const corsOptions = {
    origin: (origin, callback) => {
        // Request tanpa origin (Postman, curl, aplikasi mobile) → izinkan
        if (!origin)
            return callback(null, true);
        if (allowedOrigins.includes(origin))
            return callback(null, true);
        if (!isProduction && localhostRegex.test(origin))
            return callback(null, true);
        logger_1.logger.warn(`CORS ditolak untuk origin: ${origin}`);
        return callback(null, false); // tidak melempar error → respons tetap rapi
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
};
// ─── SECURITY MIDDLEWARE ──────────────────────────────────────────────
// CORS dipasang paling awal agar preflight (OPTIONS) selalu terjawab
app.use((0, cors_1.default)(corsOptions));
app.options('*', (0, cors_1.default)(corsOptions));
app.use((0, helmet_1.default)({
    // Agar gambar di /uploads bisa dimuat dari origin lain (Flutter/dashboard)
    crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
// Rate limiting
const limiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 menit
    max: isProduction ? 100 : 1000, // lebih longgar saat development
    message: { success: false, message: 'Terlalu banyak permintaan, coba lagi nanti.' },
    skip: (req) => req.method === 'OPTIONS', // preflight tidak dihitung
});
app.use(limiter);
// ─── GENERAL MIDDLEWARE ───────────────────────────────────────────────
app.use((0, morgan_1.default)('combined'));
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true }));
// Static files (uploaded images)
app.use('/uploads', express_1.default.static('uploads'));
// ─── HEALTH CHECK ─────────────────────────────────────────────────────
app.get('/health', (_, res) => {
    res.json({
        success: true,
        message: 'MBG Nutrition API is running',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
    });
});
// ─── API ROUTES ───────────────────────────────────────────────────────
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
app.use(`${API_PREFIX}/notifications`, notification_routes_1.default); // ← BARU
// ─── 404 HANDLER ─────────────────────────────────────────────────────
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: `Endpoint tidak ditemukan: ${req.method} ${req.originalUrl}`,
    });
});
// ─── ERROR HANDLER ────────────────────────────────────────────────────
app.use(error_middleware_1.errorHandler);
// ─── START SERVER ─────────────────────────────────────────────────────
app.listen(PORT, () => {
    logger_1.logger.info(`🚀 MBG Nutrition API running on port ${PORT}`);
    logger_1.logger.info(`📖 API docs: http://localhost:${PORT}/health`);
});
exports.default = app;
//# sourceMappingURL=index.js.map