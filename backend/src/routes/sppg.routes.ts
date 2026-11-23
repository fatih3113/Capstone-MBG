import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { SppgController } from '../controllers/sppg.controller';

const router = Router();
const ctrl = new SppgController();

// Rate limiter khusus endpoint kode SPPG
const byCodeLimiter = rateLimit({
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

export default router;
