import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class MbgMenuController {

  /**
   * GET /mbg-menu — Menu mingguan (Senin-Jumat) dari sekolah user
   */
  getWeeklyMenu = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { school_id } = req.query;

      // Hitung awal minggu (Senin)
      const monday = new Date();
      monday.setDate(monday.getDate() - (monday.getDay() || 7) + 1);
      monday.setHours(0, 0, 0, 0);

      const friday = new Date(monday);
      friday.setDate(monday.getDate() + 4);
      friday.setHours(23, 59, 59, 999);

      const menus = await prisma.mbgMenu.findMany({
        where: {
          ...(school_id && { schoolId: school_id as string }),
          date: { gte: monday, lte: friday },
        },
        include: {
          items: {
            include: {
              food: { include: { nutrition: true } },
            },
          },
          school: true,
        },
        orderBy: { date: 'asc' },
      });

      res.json(ApiResponse.success(menus));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /mbg-menu/today — Menu hari ini
   */
  getTodayMenu = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { school_id } = req.query;

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const menu = await prisma.mbgMenu.findFirst({
        where: {
          ...(school_id && { schoolId: school_id as string }),
          date: today,
        },
        include: {
          items: {
            include: {
              food: { include: { nutrition: true } },
            },
          },
          school: true,
        },
      });

      if (!menu) {
        res.status(404).json(ApiResponse.error('Menu hari ini tidak tersedia', 404));
        return;
      }

      res.json(ApiResponse.success(menu));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /mbg-menu/date/:date — Menu berdasarkan tanggal
   */
  getMenuByDate = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const date = new Date(req.params.date);

      if (isNaN(date.getTime())) {
        res.status(400).json(ApiResponse.error('Format tanggal tidak valid. Gunakan YYYY-MM-DD', 400));
        return;
      }

      date.setHours(0, 0, 0, 0);

      const menu = await prisma.mbgMenu.findFirst({
        where: { date },
        include: {
          items: {
            include: {
              food: { include: { nutrition: true } },
            },
          },
          school: true,
        },
      });

      if (!menu) {
        res.status(404).json(ApiResponse.error('Menu untuk tanggal ini tidak ditemukan', 404));
        return;
      }

      res.json(ApiResponse.success(menu));
    } catch (error) {
      next(error);
    }
  };
}
