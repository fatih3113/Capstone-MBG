import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { PredictionController, uploadScanImage } from '../controllers/prediction.controller';

const router = Router();
const ctrl = new PredictionController();

// POST /api/v1/predictions/classify — Klasifikasi gambar
router.post('/classify', authMiddleware, uploadScanImage, ctrl.classifyImage);

// GET /api/v1/predictions/scan/:scanId — Semua prediksi dari satu scan
router.get('/scan/:scanId', authMiddleware, ctrl.getPredictionsByScan);

// GET /api/v1/predictions/:id — Detail prediksi
router.get('/:id', authMiddleware, ctrl.getPredictionById);

export default router;
