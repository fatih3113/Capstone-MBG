"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const food_controller_1 = require("../controllers/food.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
const controller = new food_controller_1.FoodController();
router.get('/', auth_middleware_1.authMiddleware, controller.getAllFoods);
router.get('/search', auth_middleware_1.authMiddleware, controller.searchFoods);
router.get('/:id', auth_middleware_1.authMiddleware, controller.getFoodById);
exports.default = router;
//# sourceMappingURL=food.routes.js.map