import { Router } from 'express';
import { NotificationController } from '../controllers/notification.controller';
import * as authMiddleware from '../middleware/auth.middleware';

// Nama fungsi auth di proyek Anda belum saya lihat, jadi dicari dari nama yang umum.
// Setelah tahu namanya, boleh diganti jadi:
//   import { namaFungsiAnda as authenticate } from '../middleware/auth.middleware';
const am = authMiddleware as any;
const authenticate =
  am.authenticate ?? am.authMiddleware ?? am.protect ?? am.verifyToken ?? am.requireAuth ?? am.auth;

if (typeof authenticate !== 'function') {
  throw new Error(
    'notification.routes.ts: fungsi auth tidak ditemukan di middleware/auth.middleware.ts. ' +
      'Buka file itu, lihat nama fungsi yang di-export, lalu pakai namanya di sini.'
  );
}

const router = Router();
const ctrl = new NotificationController();

router.get('/', authenticate, ctrl.list);
router.patch('/read-all', authenticate, ctrl.markAllRead);
router.patch('/:id/read', authenticate, ctrl.markRead);

export default router;