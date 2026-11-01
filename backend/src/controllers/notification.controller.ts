import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';

const prisma = new PrismaClient();

// Ambil id user dari hasil auth middleware.
// Token dibuat dengan { userId, email }, jadi umumnya req.user.userId; id juga dicoba sebagai cadangan.
const getUserId = (req: Request): string | undefined => {
  const u = (req as any).user;
  return u?.userId ?? u?.id;
};

export class NotificationController {
  /**
   * GET /notifications            → semua notifikasi (maks 50, terbaru dulu)
   * GET /notifications?unread=true → hanya yang belum dibaca
   */
  list = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = getUserId(req);
      if (!userId) {
        res.status(401).json(ApiResponse.error('Tidak terautentikasi', 401));
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

      res.json(ApiResponse.success({ items, unreadCount }));
    } catch (e) {
      next(e);
    }
  };

  /**
   * PATCH /notifications/:id/read
   */
  markRead = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = getUserId(req);
      if (!userId) {
        res.status(401).json(ApiResponse.error('Tidak terautentikasi', 401));
        return;
      }

      await prisma.notification.updateMany({
        where: { id: req.params.id, userId }, // userId dicek agar tidak bisa menandai milik orang lain
        data: { isRead: true },
      });

      res.json(ApiResponse.success(null, 'Ditandai dibaca'));
    } catch (e) {
      next(e);
    }
  };

  /**
   * PATCH /notifications/read-all
   */
  markAllRead = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = getUserId(req);
      if (!userId) {
        res.status(401).json(ApiResponse.error('Tidak terautentikasi', 401));
        return;
      }

      await prisma.notification.updateMany({
        where: { userId, isRead: false },
        data: { isRead: true },
      });

      res.json(ApiResponse.success(null, 'Semua notifikasi ditandai dibaca'));
    } catch (e) {
      next(e);
    }
  };
}