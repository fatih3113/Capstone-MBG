import { Router } from 'express';
import { FoodController } from '../controllers/food.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const controller = new FoodController();

router.get('/', authMiddleware, controller.getAllFoods);
router.get('/search', authMiddleware, controller.searchFoods);
router.get('/:id', authMiddleware, controller.getFoodById);

export default router;
