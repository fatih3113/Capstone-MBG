"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
// Ambil id user dari hasil auth middleware (authMiddleware menyimpan di req.userId).
const getUserId = (req) => {
    return req.userId;
};
class NotificationController {
    constructor() {
        this.list = async (req, res, next) => {
            try {
                const userId = getUserId(req);
                if (!userId) {
                    res.status(401).json(api_response_1.ApiResponse.error('Tidak terautentikasi', 401));
                    return;
                }
                const onlyUnread = req.query.unread === 'true';
                const [items, unreadCount] = await Promise.all([
                    prisma.notification.findMany({
                        where: { userId, ...(onlyUnread ? { isRead: false } : {}) },
                        orderBy: { createdAt: 'desc' },
                        take: 50,
                    }),
                    prisma.notification.count({ where: { userId, isRead: false } }),
                ]);
                res.json(api_response_1.ApiResponse.success({ items, unreadCount }));
            }
            catch (e) {
                next(e);
            }
        };
        /**
         * PATCH /notifications/:id/read
         */
        this.markRead = async (req, res, next) => {
            try {
                const userId = getUserId(req);
                if (!userId) {
                    res.status(401).json(api_response_1.ApiResponse.error('Tidak terautentikasi', 401));
                    return;
                }
                await prisma.notification.updateMany({
                    where: { id: req.params.id, userId }, // userId dicek agar tidak bisa menandai milik orang lain
                    data: { isRead: true },
                });
                res.json(api_response_1.ApiResponse.success(null, 'Ditandai dibaca'));
            }
            catch (e) {
                next(e);
            }
        };
        /**
         * PATCH /notifications/read-all
         */
        this.markAllRead = async (req, res, next) => {
            try {
                const userId = getUserId(req);
                if (!userId) {
                    res.status(401).json(api_response_1.ApiResponse.error('Tidak terautentikasi', 401));
                    return;
                }
                await prisma.notification.updateMany({
                    where: { userId, isRead: false },
                    data: { isRead: true },
                });
                res.json(api_response_1.ApiResponse.success(null, 'Semua notifikasi ditandai dibaca'));
            }
            catch (e) {
                next(e);
            }
        };
    }
}
exports.NotificationController = NotificationController;
//# sourceMappingURL=notification.controller.js.map