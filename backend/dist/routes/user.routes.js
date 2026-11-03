"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middleware/auth.middleware");
const user_controller_1 = require("../controllers/user.controller");
const validation_middleware_1 = require("../middleware/validation.middleware");
const router = (0, express_1.Router)();
const ctrl = new user_controller_1.UserController();
// GET /api/v1/users/profile
router.get('/profile', auth_middleware_1.authMiddleware, ctrl.getProfile);
// PUT /api/v1/users/profile/update
router.put('/profile/update', auth_middleware_1.authMiddleware, validation_middleware_1.validateUpdateProfile, ctrl.updateProfile);
// POST /api/v1/users/profile/photo — Upload foto profil
router.post('/profile/photo', auth_middleware_1.authMiddleware, user_controller_1.uploadProfileImage, ctrl.uploadPhoto);
// DELETE /api/v1/users/profile — Hapus akun
router.delete('/profile', auth_middleware_1.authMiddleware, ctrl.deleteAccount);
exports.default = router;
//# sourceMappingURL=user.routes.js.map