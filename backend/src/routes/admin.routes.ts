import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { adminMiddleware } from '../middleware/admin.middleware';
import { AdminDashboardController } from '../controllers/admin-dashboard.controller';

const router = Router();
const dashboard = new AdminDashboardController();

// Semua route admin memerlukan autentikasi + role admin
router.use(authMiddleware, adminMiddleware);

// GET /admin/dashboard — Ringkasan dashboard
router.get('/dashboard', dashboard.overview);

// GET /admin/nutrition-reports — Laporan hasil scan gizi
router.get('/nutrition-reports', dashboard.nutritionReports);

// GET /admin/nutrition-reports/export — Ekspor CSV
router.get('/nutrition-reports/export', dashboard.exportNutritionCsv);

export default router;
