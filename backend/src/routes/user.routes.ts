import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { UserController, uploadProfileImage } from '../controllers/user.controller';

const router = Router();
const ctrl = new UserController();

// GET /api/v1/users/profile
router.get('/profile', authMiddleware, ctrl.getProfile);

// PUT /api/v1/users/profile/update
router.put('/profile/update', authMiddleware, ctrl.updateProfile);

// POST /api/v1/users/profile/photo — Upload foto profil
router.post('/profile/photo', authMiddleware, uploadProfileImage, ctrl.uploadPhoto);

// DELETE /api/v1/users/profile — Hapus akun
router.delete('/profile', authMiddleware, ctrl.deleteAccount);

export default router;
