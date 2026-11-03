"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const sppg_controller_1 = require("../controllers/sppg.controller");
const router = (0, express_1.Router)();
const ctrl = new sppg_controller_1.SppgController();
// Semua endpoint publik — tidak perlu auth (digunakan saat register Flutter)
router.get('/regions', ctrl.getRegions);
router.get('/', ctrl.findAll);
exports.default = router;
//# sourceMappingURL=sppg.routes.js.map