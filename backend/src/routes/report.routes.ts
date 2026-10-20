import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { adminMiddleware } from '../middleware/admin.middleware';
import { MenuRequestController } from '../controllers/menu-request.controller';
import { FoodRatingController } from '../controllers/food-rating.controller';
import { FoodFeedbackController } from '../controllers/food-feedback.controller';

const router = Router();
const menuReq = new MenuRequestController();
const foodRating = new FoodRatingController();
const foodFeedback = new FoodFeedbackController();

// ─── Semua route perlu autentikasi ────────────────────────────────────────
router.use(authMiddleware);

// ═══════════════════════════════════════════════
// MENU REQUESTS — Permintaan Menu Siswa
// ═══════════════════════════════════════════════

// Siswa: kirim usulan
router.post('/menu-requests', menuReq.create);

// Siswa: riwayat usulan sendiri
router.get('/menu-requests/my', menuReq.listMine);

// Ranking & ringkasan (publik untuk siswa)
router.get('/menu-requests/grouped', menuReq.groupedSummary);

// Admin: semua usulan
router.get('/menu-requests', adminMiddleware, menuReq.listAll);

// Admin: ekspor CSV
router.get('/menu-requests/export', adminMiddleware, menuReq.exportCsv);

// Admin: ubah status usulan
router.patch('/menu-requests/:id/status', adminMiddleware, menuReq.updateStatus);

// ═══════════════════════════════════════════════
// FOOD RATINGS — Rating Makanan Favorit
// ═══════════════════════════════════════════════

// Siswa: kirim rating
router.post('/food-ratings', foodRating.create);

// Siswa: riwayat rating sendiri
router.get('/food-ratings/my', foodRating.listMine);

// Ranking (siswa & admin bisa akses)
router.get('/food-ratings/ranking', foodRating.ranking);

// Admin: semua data rating
router.get('/food-ratings', adminMiddleware, foodRating.listAll);

// Admin: ekspor CSV
router.get('/food-ratings/export', adminMiddleware, foodRating.exportCsv);

// ═══════════════════════════════════════════════
// FOOD FEEDBACKS — Feedback & Status Konsumsi
// ═══════════════════════════════════════════════

// Siswa: kirim feedback
router.post('/food-feedbacks', foodFeedback.create);

// Siswa: riwayat feedback sendiri
router.get('/food-feedbacks/my', foodFeedback.listMine);

// Admin: ringkasan feedback
router.get('/food-feedbacks/summary', adminMiddleware, foodFeedback.summary);

// Admin: semua data feedback
router.get('/food-feedbacks', adminMiddleware, foodFeedback.listAll);

// Admin: ekspor CSV
router.get('/food-feedbacks/export', adminMiddleware, foodFeedback.exportCsv);

export default router;
