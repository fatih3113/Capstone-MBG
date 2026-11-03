"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const admin_middleware_1 = require("../middleware/admin.middleware");
const admin_dashboard_controller_1 = require("../controllers/admin-dashboard.controller");
const router = (0, express_1.Router)();
const dashboard = new admin_dashboard_controller_1.AdminDashboardController();
// Semua route admin memerlukan autentikasi + role admin
router.use(auth_middleware_1.authMiddleware, admin_middleware_1.adminMiddleware);
// GET /admin/dashboard — Ringkasan dashboard
router.get('/dashboard', dashboard.overview);
// GET /admin/nutrition-reports — Laporan hasil scan gizi
router.get('/nutrition-reports', dashboard.nutritionReports);
// GET /admin/nutrition-reports/export — Ekspor CSV
router.get('/nutrition-reports/export', dashboard.exportNutritionCsv);
exports.default = router;
//# sourceMappingURL=admin.routes.js.map