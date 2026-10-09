import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class ScanHistoryController {

  /**
   * GET /scan-history — Get user scan history
   */
  getUserHistory = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;
      const { page = '1', limit = '20' } = req.query;
      const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

      const [history, total] = await Promise.all([
        prisma.scanHistory.findMany({
          where: { userId },
          include: {
            predictions: {
              include: { food: true },
            },
          },
          orderBy: { scannedAt: 'desc' },
          skip,
          take: parseInt(limit as string),
        }),
        prisma.scanHistory.count({ where: { userId } }),
      ]);

      res.json(ApiResponse.paginated(history, total,
        parseInt(page as string), parseInt(limit as string)));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /scan-history/:id — Scan detail
   */
  getScanDetail = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const scan = await prisma.scanHistory.findFirst({
        where: { id: req.params.id, userId: req.userId },
        include: {
          predictions: {
            include: { food: { include: { nutrition: true } } },
          },
        },
      });

      if (!scan) {
        res.status(404).json(ApiResponse.error('Riwayat scan tidak ditemukan', 404));
        return;
      }

      res.json(ApiResponse.success(scan));
    } catch (error) {
      next(error);
    }
  };

  /**
   * POST /scan-history/save — Save scan result
   */
  saveScan = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.userId!;
      const {
        image_url,
        total_calories,
        total_protein,
        total_carbs,
        total_fat,
        total_fiber,
        predictions,
        sensory_data,      // data sensorik opsional
        consumption_data,  // data konsumsi opsional
      } = req.body;

      // Create scan history with predictions in a transaction
      const scan = await prisma.$transaction(async (tx) => {
        const scanRecord = await tx.scanHistory.create({
          data: {
            userId,
            imageUrl: image_url,
            totalCalories: total_calories,
            totalProtein: total_protein,
            totalCarbs: total_carbs,
            totalFat: total_fat,
            totalFiber: total_fiber,
            status: 'success',
            // Data evaluasi (sensorik & konsumsi)
            sensoryData: sensory_data ?? null,
            consumptionData: consumption_data ?? null,
            predictions: {
              create: predictions.map((p: any) => ({
                foodId: p.food_id,
                confidence: p.confidence,
                portionEstimateGram: p.portion_estimate_gram || 100,
                calories: p.calories,
                protein: p.protein,
                carbs: p.carbs,
                fat: p.fat,
              })),
            },
          },
          include: { predictions: true },
        });

        // Update daily nutrition aggregate
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        await tx.dailyNutrition.upsert({
          where: { userId_date: { userId, date: today } },
          create: {
            userId,
            date: today,
            totalCalories: total_calories,
            totalProtein: total_protein,
            totalCarbs: total_carbs,
            totalFat: total_fat,
            totalFiber: total_fiber,
            totalScans: 1,
          },
          update: {
            totalCalories: { increment: total_calories },
            totalProtein: { increment: total_protein },
            totalCarbs: { increment: total_carbs },
            totalFat: { increment: total_fat },
            totalFiber: { increment: total_fiber },
            totalScans: { increment: 1 },
          },
        });

        return scanRecord;
      });

      res.status(201).json(ApiResponse.success(scan, 'Scan berhasil disimpan'));
    } catch (error) {
      next(error);
    }
  };
}
