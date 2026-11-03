"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const mbg_menu_controller_1 = require("../controllers/mbg-menu.controller");
const router = (0, express_1.Router)();
const ctrl = new mbg_menu_controller_1.MbgMenuController();
// GET /api/v1/mbg-menu — Menu mingguan
router.get('/', auth_middleware_1.authMiddleware, ctrl.getWeeklyMenu);
// GET /api/v1/mbg-menu/today — Menu hari ini
router.get('/today', auth_middleware_1.authMiddleware, ctrl.getTodayMenu);
// GET /api/v1/mbg-menu/date/:date — Menu berdasarkan tanggal
router.get('/date/:date', ctrl.getMenuByDate);
exports.default = router;
//# sourceMappingURL=mbg-menu.routes.js.map