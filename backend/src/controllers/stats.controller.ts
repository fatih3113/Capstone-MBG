import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class StatsController {

  /**
   * GET /stats/daily — Statistik gizi hari ini
   */
  getDailyStats = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const data = await prisma.dailyNutrition.findUnique({
        where: { userId_date: { userId, date: today } },
      });

      res.json(ApiResponse.success(data ?? null));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /stats/weekly — Statistik gizi 7 hari terakhir (Data Warehouse)
   */
  getWeeklyStats = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;

      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const data = await prisma.dailyNutrition.findMany({
        where: { userId, date: { gte: sevenDaysAgo } },
        orderBy: { date: 'asc' },
      });

      // Agregat ringkasan mingguan (Data Warehouse pattern)
      const summary = {
        avgCalories: data.length > 0
          ? data.reduce((sum, d) => sum + d.totalCalories, 0) / data.length
          : 0,
        avgProtein: data.length > 0
          ? data.reduce((sum, d) => sum + d.totalProtein, 0) / data.length
          : 0,
        totalScans: data.reduce((sum, d) => sum + d.totalScans, 0),
        daysLogged: data.length,
      };

      res.json(ApiResponse.success({ daily: data, summary }));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /stats/top-foods — Makanan paling sering dikonsumsi (Data Warehouse)
   */
  getTopFoods = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;
      const limit = parseInt(req.query.limit as string) || 5;

      const topFoods = await prisma.prediction.groupBy({
        by: ['foodId'],
        where: { scan: { userId } },
        _count: { foodId: true },
        orderBy: { _count: { foodId: 'desc' } },
        take: limit,
      });

      const foodIds = topFoods.map((f) => f.foodId);
      const foods = await prisma.food.findMany({
        where: { id: { in: foodIds } },
        include: { nutrition: true },
      });

      const result = topFoods.map((f) => ({
        food: foods.find((fd) => fd.id === f.foodId),
        count: f._count.foodId,
      }));

      res.json(ApiResponse.success(result));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /stats/summary — Ringkasan statistik lengkap user
   */
  getSummary = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;

      const [totalScans, weeklyData] = await Promise.all([
        prisma.scanHistory.count({ where: { userId } }),
        prisma.dailyNutrition.findMany({
          where: {
            userId,
            date: {
              gte: new Date(new Date().setDate(new Date().getDate() - 7)),
            },
          },
          orderBy: { date: 'asc' },
        }),
      ]);

      const avgCalories = weeklyData.length > 0
        ? weeklyData.reduce((sum, d) => sum + d.totalCalories, 0) / weeklyData.length
        : 0;

      res.json(ApiResponse.success({
        totalScans,
        weeklyAvgCalories: Math.round(avgCalories),
        daysLogged: weeklyData.length,
        lastScan: weeklyData.length > 0 ? weeklyData[weeklyData.length - 1].date : null,
      }));
    } catch (error) {
      next(error);
    }
  };
}
