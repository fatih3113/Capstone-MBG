"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const sppg_controller_1 = require("../controllers/sppg.controller");
const router = (0, express_1.Router)();
const ctrl = new sppg_controller_1.SppgController();
// Rate limiter khusus endpoint kode SPPG
const byCodeLimiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000,
    max: 20,
    message: { success: false, message: 'Terlalu banyak percobaan, coba lagi dalam 15 menit.' },
    standardHeaders: true,
    legacyHeaders: false,
});
// Semua endpoint publik — tidak perlu auth (digunakan saat register Flutter)
router.get('/regions', ctrl.getRegions);
router.get('/by-code/:kode', byCodeLimiter, ctrl.findByCode);
router.get('/', ctrl.findAll);
exports.default = router;
//# sourceMappingURL=sppg.routes.js.map