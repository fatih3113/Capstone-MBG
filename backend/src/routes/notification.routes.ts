import { Router } from 'express';
import { NotificationController } from '../controllers/notification.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const ctrl = new NotificationController();

router.get('/', authMiddleware, ctrl.list);
router.patch('/read-all', authMiddleware, ctrl.markAllRead);
router.patch('/:id/read', authMiddleware, ctrl.markRead);

export default router;
