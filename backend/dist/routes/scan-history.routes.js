"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const scan_history_controller_1 = require("../controllers/scan-history.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validation_middleware_1 = require("../middleware/validation.middleware");
const router = (0, express_1.Router)();
const controller = new scan_history_controller_1.ScanHistoryController();
router.get('/', auth_middleware_1.authMiddleware, controller.getUserHistory);
router.get('/:id', auth_middleware_1.authMiddleware, controller.getScanDetail);
router.post('/save', auth_middleware_1.authMiddleware, validation_middleware_1.validateSaveScan, controller.saveScan);
exports.default = router;
//# sourceMappingURL=scan-history.routes.js.map