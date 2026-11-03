"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const stats_controller_1 = require("../controllers/stats.controller");
const router = (0, express_1.Router)();
const ctrl = new stats_controller_1.StatsController();
// GET /api/v1/stats/daily — Statistik hari ini
router.get('/daily', auth_middleware_1.authMiddleware, ctrl.getDailyStats);
// GET /api/v1/stats/weekly — Statistik 7 hari terakhir
router.get('/weekly', auth_middleware_1.authMiddleware, ctrl.getWeeklyStats);
// GET /api/v1/stats/top-foods — Makanan paling sering dikonsumsi
router.get('/top-foods', auth_middleware_1.authMiddleware, ctrl.getTopFoods);
// GET /api/v1/stats/summary — Ringkasan lengkap
router.get('/summary', auth_middleware_1.authMiddleware, ctrl.getSummary);
exports.default = router;
//# sourceMappingURL=stats.routes.js.map