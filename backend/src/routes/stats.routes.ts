import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { StatsController } from '../controllers/stats.controller';

const router = Router();
const ctrl = new StatsController();

// GET /api/v1/stats/daily — Statistik hari ini
router.get('/daily', authMiddleware, ctrl.getDailyStats);

// GET /api/v1/stats/weekly — Statistik 7 hari terakhir
router.get('/weekly', authMiddleware, ctrl.getWeeklyStats);

// GET /api/v1/stats/top-foods — Makanan paling sering dikonsumsi
router.get('/top-foods', authMiddleware, ctrl.getTopFoods);

// GET /api/v1/stats/summary — Ringkasan lengkap
router.get('/summary', authMiddleware, ctrl.getSummary);

export default router;
