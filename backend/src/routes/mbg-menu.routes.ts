import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { MbgMenuController } from '../controllers/mbg-menu.controller';

const router = Router();
const ctrl = new MbgMenuController();

// GET /api/v1/mbg-menu — Menu mingguan
router.get('/', authMiddleware, ctrl.getWeeklyMenu);

// GET /api/v1/mbg-menu/today — Menu hari ini
router.get('/today', authMiddleware, ctrl.getTodayMenu);

// GET /api/v1/mbg-menu/date/:date — Menu berdasarkan tanggal
router.get('/date/:date', ctrl.getMenuByDate);

export default router;
