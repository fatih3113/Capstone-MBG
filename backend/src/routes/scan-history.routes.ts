import { Router } from 'express';
import { ScanHistoryController } from '../controllers/scan-history.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { validateSaveScan } from '../middleware/validation.middleware';

const router = Router();
const controller = new ScanHistoryController();

router.get('/', authMiddleware, controller.getUserHistory);
router.get('/:id', authMiddleware, controller.getScanDetail);
router.post('/save', authMiddleware, validateSaveScan, controller.saveScan);

export default router;
