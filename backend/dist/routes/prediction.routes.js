"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const prediction_controller_1 = require("../controllers/prediction.controller");
const router = (0, express_1.Router)();
const ctrl = new prediction_controller_1.PredictionController();
// POST /api/v1/predictions/classify — Klasifikasi gambar
router.post('/classify', auth_middleware_1.authMiddleware, prediction_controller_1.uploadScanImage, ctrl.classifyImage);
// GET /api/v1/predictions/scan/:scanId — Semua prediksi dari satu scan
router.get('/scan/:scanId', auth_middleware_1.authMiddleware, ctrl.getPredictionsByScan);
// GET /api/v1/predictions/:id — Detail prediksi
router.get('/:id', auth_middleware_1.authMiddleware, ctrl.getPredictionById);
exports.default = router;
//# sourceMappingURL=prediction.routes.js.map