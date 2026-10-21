import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class NutritionController {

  /**
   * GET /nutrition?food_ids=id1,id2,...
   * Ambil data gizi untuk beberapa food sekaligus (dipakai oleh Flutter scan)
   */
  getNutritionByFoodIds = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { food_ids } = req.query as Record<string, string>;
      if (!food_ids) {
        res.status(400).json(ApiResponse.error('Parameter food_ids wajib diisi', 400));
        return;
      }

      const ids = food_ids.split(',').map((id) => id.trim()).filter(Boolean);

      const nutritions = await prisma.nutrition.findMany({
        where: { foodId: { in: ids } },
        include: { food: { select: { id: true, name: true, category: true } } },
      });

      res.json(ApiResponse.success(nutritions));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /nutrition/food/:foodId
   * Ambil data gizi berdasarkan foodId
   */
  getNutritionByFood = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const nutrition = await prisma.nutrition.findUnique({
        where: { foodId: req.params.foodId },
        include: { food: true },
      });

      if (!nutrition) {
        res.status(404).json(ApiResponse.error('Data gizi tidak ditemukan', 404));
        return;
      }

      res.json(ApiResponse.success(nutrition));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /nutrition/daily?date=YYYY-MM-DD
   * Ambil agregat gizi harian user
   */
  getDailyNutrition = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;
      const { date } = req.query;

      const targetDate = date ? new Date(date as string) : new Date();
      targetDate.setHours(0, 0, 0, 0);

      const data = await prisma.dailyNutrition.findUnique({
        where: { userId_date: { userId, date: targetDate } },
      });

      res.json(ApiResponse.success(data));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /nutrition/weekly
   * Ambil data gizi 7 hari terakhir
   */
  getWeeklyNutrition = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const data = await prisma.dailyNutrition.findMany({
        where: { userId, date: { gte: sevenDaysAgo } },
        orderBy: { date: 'asc' },
      });

      res.json(ApiResponse.success(data));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /nutrition/recommendation
   * Rekomendasi gizi berbasis rule-based (Pemrograman Sistem Cerdas)
   */
  getNutritionRecommendation = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;

      // Ambil data user untuk kalkulasi kebutuhan
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        res.status(404).json(ApiResponse.error('User tidak ditemukan', 404));
        return;
      }

      // Rule-based recommendation berdasarkan usia dan jenis kelamin (Pemrograman Sistem Cerdas)
      const age = user.age ?? 12;
      const gender = user.gender ?? 'L';
      const schoolLevel = user.schoolLevel ?? 'SD';

      let caloriesTarget: number;
      let proteinTarget: number;
      let carbsTarget: number;
      let fatTarget: number;
      let fiberTarget: number;

      // Aturan berdasarkan AKG (Angka Kecukupan Gizi) Indonesia
      if (schoolLevel === 'SD') {
        caloriesTarget = gender === 'L' ? 1850 : 1750;
        proteinTarget = gender === 'L' ? 49 : 45;
        carbsTarget = gender === 'L' ? 265 : 250;
        fatTarget = gender === 'L' ? 62 : 58;
        fiberTarget = 22;
      } else if (schoolLevel === 'SMP') {
        caloriesTarget = gender === 'L' ? 2200 : 2000;
        proteinTarget = gender === 'L' ? 60 : 55;
        carbsTarget = gender === 'L' ? 315 : 285;
        fatTarget = gender === 'L' ? 73 : 67;
        fiberTarget = 26;
      } else {
        // SMA / SMK
        caloriesTarget = gender === 'L' ? 2650 : 2100;
        proteinTarget = gender === 'L' ? 75 : 59;
        carbsTarget = gender === 'L' ? 375 : 300;
        fatTarget = gender === 'L' ? 88 : 70;
        fiberTarget = 30;
      }

      // Ambil data hari ini untuk membandingkan
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const todayData = await prisma.dailyNutrition.findUnique({
        where: { userId_date: { userId, date: today } },
      });

      const consumed = {
        calories: todayData?.totalCalories ?? 0,
        protein: todayData?.totalProtein ?? 0,
        carbs: todayData?.totalCarbs ?? 0,
        fat: todayData?.totalFat ?? 0,
        fiber: todayData?.totalFiber ?? 0,
      };

      // Hitung sisa kebutuhan
      const remaining = {
        calories: Math.max(0, caloriesTarget - consumed.calories),
        protein: Math.max(0, proteinTarget - consumed.protein),
        carbs: Math.max(0, carbsTarget - consumed.carbs),
        fat: Math.max(0, fatTarget - consumed.fat),
        fiber: Math.max(0, fiberTarget - consumed.fiber),
      };

      // Status pencapaian
      const caloriesPct = (consumed.calories / caloriesTarget) * 100;
      let status: string;
      let message: string;
      if (caloriesPct < 60) {
        status = 'kurang';
        message = 'Asupan kalori hari ini masih kurang. Tambahkan makanan bergizi.';
      } else if (caloriesPct > 110) {
        status = 'berlebih';
        message = 'Asupan kalori sudah melebihi kebutuhan. Perbanyak sayur dan buah.';
      } else {
        status = 'cukup';
        message = 'Asupan gizi hari ini sudah cukup baik. Pertahankan!';
      }

      res.json(ApiResponse.success({
        target: { caloriesTarget, proteinTarget, carbsTarget, fatTarget, fiberTarget },
        consumed,
        remaining,
        status,
        message,
        percentage: Math.round(caloriesPct),
      }));
    } catch (error) {
      next(error);
    }
  };
}
