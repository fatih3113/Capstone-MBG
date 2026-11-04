// Entry point utama server backend Express: mengatur konfigurasi CORS, keamanan HTTP (Helmet & Rate Limiting), penyajian file statis, seluruh rute API, dan penanganan error terpusat.

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import foodRoutes from './routes/food.routes';
import nutritionRoutes from './routes/nutrition.routes';
import mbgMenuRoutes from './routes/mbg-menu.routes';
import predictionRoutes from './routes/prediction.routes';
import scanHistoryRoutes from './routes/scan-history.routes';
import schoolRoutes from './routes/school.routes';
import statsRoutes from './routes/stats.routes';
import reportRoutes from './routes/report.routes';
import adminRoutes from './routes/admin.routes';
import sppgRoutes from './routes/sppg.routes';
import notificationRoutes from './routes/notification.routes'; // ← BARU
import { errorHandler } from './middleware/error.middleware';
import { logger } from './utils/logger';

// Memuat variabel konfigurasi dari file .env ke dalam environment Node.js.
dotenv.config();

// Inisialisasi aplikasi Express dan definisi konstanta server.
const app = express();
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

const corsOptions: cors.CorsOptions = {
  origin: (origin, callback) => {
    // Request tanpa origin (seperti Postman, curl, dan aplikasi mobile Flutter native) otomatis diizinkan.
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) return callback(null, true);
    if (!isProduction && localhostRegex.test(origin)) return callback(null, true);

    logger.warn(`CORS ditolak untuk origin: ${origin}`);
    return callback(null, false); // Menolak request tak dikenal secara rapi tanpa crash.
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
};

// ─── SECURITY MIDDLEWARE ──────────────────────────────────────────────
// CORS dipasang paling awal agar preflight (OPTIONS) selalu terjawab dengan cepat.
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

// Helmet: mengamankan HTTP header aplikasi dari kerentanan umum di web.
app.use(
  helmet({
    // crossOriginResourcePolicy diatur cross-origin agar gambar statis di /uploads dapat dimuat oleh aplikasi mobile.
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

// Rate limiting: membatasi frekuensi request per IP untuk mencegah serangan brute-force atau spam request.
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // Jendela waktu 15 menit.
  max: isProduction ? 100 : 1000, // Maksimal jumlah request per jendela waktu.
  message: { success: false, message: 'Terlalu banyak permintaan, coba lagi nanti.' },
  skip: (req) => req.method === 'OPTIONS', // Request preflight tidak dihitung ke limit.
});
app.use(limiter);

// ─── GENERAL MIDDLEWARE ───────────────────────────────────────────────
// Morgan: mencatat log setiap request HTTP yang masuk ke terminal.
app.use(morgan('combined'));
// Parser body request: membaca payload berformat JSON dan URL-encoded hingga batas 10MB.
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Menyajikan folder uploads sebagai file statis publik (untuk foto profil dan foto scan makanan).
app.use('/uploads', express.static('uploads'));

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
app.use(`${API_PREFIX}/auth`, authRoutes);
app.use(`${API_PREFIX}/users`, userRoutes);
app.use(`${API_PREFIX}/foods`, foodRoutes);
app.use(`${API_PREFIX}/nutrition`, nutritionRoutes);
app.use(`${API_PREFIX}/mbg-menu`, mbgMenuRoutes);
app.use(`${API_PREFIX}/predictions`, predictionRoutes);
app.use(`${API_PREFIX}/scan-history`, scanHistoryRoutes);
app.use(`${API_PREFIX}/schools`, schoolRoutes);
app.use(`${API_PREFIX}/stats`, statsRoutes);
app.use(`${API_PREFIX}/reports`, reportRoutes);
app.use(`${API_PREFIX}/admin`, adminRoutes);
app.use(`${API_PREFIX}/sppg`, sppgRoutes);
app.use(`${API_PREFIX}/notifications`, notificationRoutes);

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
app.use(errorHandler);

// ─── START SERVER ─────────────────────────────────────────────────────
// Menjalankan server HTTP pada port yang ditentukan dan mencatat log saat siap menerima request.
app.listen(PORT, () => {
  logger.info(`🚀 MBG Nutrition API running on port ${PORT}`);
  logger.info(`📖 API docs: http://localhost:${PORT}/health`);
});

export default app;