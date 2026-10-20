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
import { errorHandler } from './middleware/error.middleware';
import { logger } from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const API_PREFIX = '/api/v1';

// ─── SECURITY MIDDLEWARE ──────────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: { success: false, message: 'Terlalu banyak permintaan, coba lagi nanti.' },
});
app.use(limiter);

// ─── GENERAL MIDDLEWARE ───────────────────────────────────────────────
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Static files (uploaded images)
app.use('/uploads', express.static('uploads'));

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

// ─── 404 HANDLER ─────────────────────────────────────────────────────
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint tidak ditemukan: ${req.method} ${req.originalUrl}`,
  });
});

// ─── ERROR HANDLER ────────────────────────────────────────────────────
app.use(errorHandler);

// ─── START SERVER ─────────────────────────────────────────────────────
app.listen(PORT, () => {
  logger.info(`🚀 MBG Nutrition API running on port ${PORT}`);
  logger.info(`📖 API docs: http://localhost:${PORT}/health`);
});

export default app;
