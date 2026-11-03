"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const admin_middleware_1 = require("../middleware/admin.middleware");
const menu_request_controller_1 = require("../controllers/menu-request.controller");
const food_rating_controller_1 = require("../controllers/food-rating.controller");
const food_feedback_controller_1 = require("../controllers/food-feedback.controller");
const router = (0, express_1.Router)();
const menuReq = new menu_request_controller_1.MenuRequestController();
const foodRating = new food_rating_controller_1.FoodRatingController();
const foodFeedback = new food_feedback_controller_1.FoodFeedbackController();
// ─── Semua route perlu autentikasi ────────────────────────────────────────
router.use(auth_middleware_1.authMiddleware);
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
router.get('/menu-requests', admin_middleware_1.adminMiddleware, menuReq.listAll);
// Admin: ekspor CSV
router.get('/menu-requests/export', admin_middleware_1.adminMiddleware, menuReq.exportCsv);
// Admin: ubah status usulan
router.patch('/menu-requests/:id/status', admin_middleware_1.adminMiddleware, menuReq.updateStatus);
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
router.get('/food-ratings', admin_middleware_1.adminMiddleware, foodRating.listAll);
// Admin: ekspor CSV
router.get('/food-ratings/export', admin_middleware_1.adminMiddleware, foodRating.exportCsv);
// ═══════════════════════════════════════════════
// FOOD FEEDBACKS — Feedback & Status Konsumsi
// ═══════════════════════════════════════════════
// Siswa: kirim feedback
router.post('/food-feedbacks', foodFeedback.create);
// Siswa: riwayat feedback sendiri
router.get('/food-feedbacks/my', foodFeedback.listMine);
// Admin: ringkasan feedback
router.get('/food-feedbacks/summary', admin_middleware_1.adminMiddleware, foodFeedback.summary);
// Admin: semua data feedback
router.get('/food-feedbacks', admin_middleware_1.adminMiddleware, foodFeedback.listAll);
// Admin: ekspor CSV
router.get('/food-feedbacks/export', admin_middleware_1.adminMiddleware, foodFeedback.exportCsv);
exports.default = router;
//# sourceMappingURL=report.routes.js.map