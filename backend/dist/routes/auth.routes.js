"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("../controllers/auth.controller");
const validation_middleware_1 = require("../middleware/validation.middleware");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
const controller = new auth_controller_1.AuthController();
router.post('/register', validation_middleware_1.validateRegister, controller.register);
router.post('/login', validation_middleware_1.validateLogin, controller.login);
router.post('/logout', auth_middleware_1.authMiddleware, controller.logout);
router.post('/forgot-password', controller.forgotPassword);
router.post('/reset-password', controller.resetPassword);
exports.default = router;
//# sourceMappingURL=auth.routes.js.map