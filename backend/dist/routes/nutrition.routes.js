"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const nutrition_controller_1 = require("../controllers/nutrition.controller");
const router = (0, express_1.Router)();
const ctrl = new nutrition_controller_1.NutritionController();
// GET /api/v1/nutrition?food_ids=id1,id2,...  (dipakai Flutter scan)
router.get('/', auth_middleware_1.authMiddleware, ctrl.getNutritionByFoodIds);
// GET /api/v1/nutrition/food/:foodId
router.get('/food/:foodId', auth_middleware_1.authMiddleware, ctrl.getNutritionByFood);
// GET /api/v1/nutrition/daily?date=YYYY-MM-DD
router.get('/daily', auth_middleware_1.authMiddleware, ctrl.getDailyNutrition);
// GET /api/v1/nutrition/weekly
router.get('/weekly', auth_middleware_1.authMiddleware, ctrl.getWeeklyNutrition);
// GET /api/v1/nutrition/recommendation
router.get('/recommendation', auth_middleware_1.authMiddleware, ctrl.getNutritionRecommendation);
exports.default = router;
//# sourceMappingURL=nutrition.routes.js.map