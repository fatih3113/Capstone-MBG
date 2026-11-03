"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const notification_controller_1 = require("../controllers/notification.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
const ctrl = new notification_controller_1.NotificationController();
router.get('/', auth_middleware_1.authMiddleware, ctrl.list);
router.patch('/read-all', auth_middleware_1.authMiddleware, ctrl.markAllRead);
router.patch('/:id/read', auth_middleware_1.authMiddleware, ctrl.markRead);
exports.default = router;
//# sourceMappingURL=notification.routes.js.map