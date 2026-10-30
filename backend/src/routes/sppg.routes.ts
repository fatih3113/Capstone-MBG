import { Router } from 'express';
import { SppgController } from '../controllers/sppg.controller';

const router = Router();
const ctrl = new SppgController();

// Semua endpoint publik — tidak perlu auth (digunakan saat register Flutter)
router.get('/regions', ctrl.getRegions);
router.get('/', ctrl.findAll);

export default router;
