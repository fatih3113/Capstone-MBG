import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { validateLogin, validateRegister } from '../middleware/validation.middleware';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const controller = new AuthController();


router.post('/register', validateRegister, controller.register);


router.post('/login', validateLogin, controller.login);


router.post('/logout', authMiddleware, controller.logout);


router.post('/forgot-password', controller.forgotPassword);

router.post('/reset-password', controller.resetPassword);

export default router;
