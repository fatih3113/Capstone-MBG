import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { NutritionController } from '../controllers/nutrition.controller';

const router = Router();
const ctrl = new NutritionController();

// GET /api/v1/nutrition?food_ids=id1,id2,...  (dipakai Flutter scan)
router.get('/', authMiddleware, ctrl.getNutritionByFoodIds);

// GET /api/v1/nutrition/food/:foodId
router.get('/food/:foodId', authMiddleware, ctrl.getNutritionByFood);

// GET /api/v1/nutrition/daily?date=YYYY-MM-DD
router.get('/daily', authMiddleware, ctrl.getDailyNutrition);

// GET /api/v1/nutrition/weekly
router.get('/weekly', authMiddleware, ctrl.getWeeklyNutrition);

// GET /api/v1/nutrition/recommendation
router.get('/recommendation', authMiddleware, ctrl.getNutritionRecommendation);

export default router;
