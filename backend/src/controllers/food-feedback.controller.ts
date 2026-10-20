import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class FoodFeedbackController {

  /**
   * POST /reports/food-feedbacks
   * Siswa mengirim feedback makanan dan status konsumsi
   */
  create = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const {
        foodId,
        foodName,
        tasteRating,
        textureRating,
        aromaRating,
        portionRating,
        satisfactionRating,
        consumptionStatus,
        suggestion,
      } = req.body;

      if (!foodName?.trim()) {
        res.status(400).json(ApiResponse.error('Nama makanan wajib diisi', 400));
        return;
      }

      const validConsumptionStatuses = ['habis', 'sebagian', 'hampir_tidak', null, undefined];
      if (consumptionStatus && !validConsumptionStatuses.includes(consumptionStatus)) {
        res.status(400).json(ApiResponse.error(
          'Status konsumsi tidak valid. Gunakan: habis, sebagian, atau hampir_tidak', 400
        ));
        return;
      }

      // Validasi rating 1-5 jika diisi
      const validateRating = (val: any) => {
        if (val === undefined || val === null) return null;
        const n = parseInt(val);
        if (n < 1 || n > 5) throw new Error('Rating harus 1–5');
        return n;
      };

      const record = await prisma.foodFeedback.create({
        data: {
          userId: req.userId!,
          foodId: foodId ?? null,
          foodName: foodName.trim(),
          tastRating: validateRating(tasteRating),
          textureRating: validateRating(textureRating),
          aromaRating: validateRating(aromaRating),
          portionRating: validateRating(portionRating),
          satisfactionRating: validateRating(satisfactionRating),
          consumptionStatus: consumptionStatus ?? null,
          suggestion: suggestion?.trim() ?? null,
        },
      });

      res.status(201).json(ApiResponse.success(record, 'Feedback berhasil dikirim'));
    } catch (error: any) {
      if (error.message === 'Rating harus 1–5') {
        res.status(400).json(ApiResponse.error(error.message, 400));
        return;
      }
      next(error);
    }
  };

  /**
   * GET /reports/food-feedbacks/my
   * Siswa melihat feedback yang pernah dikirim
   */
  listMine = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const records = await prisma.foodFeedback.findMany({
        where: { userId: req.userId! },
        orderBy: { submittedAt: 'desc' },
      });
      res.json(ApiResponse.success(records));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/food-feedbacks (admin only)
   * Admin melihat semua feedback dengan filter
   */
  listAll = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate, foodName, page = '1', limit = '50' } = req.query as Record<string, string>;
      const skip = (parseInt(page) - 1) * parseInt(limit);

      const where: any = {};
      if (startDate) where.submittedAt = { ...where.submittedAt, gte: new Date(startDate) };
      if (endDate) where.submittedAt = { ...where.submittedAt, lte: new Date(endDate) };
      if (foodName) where.foodName = { contains: foodName, mode: 'insensitive' };

      const [records, total] = await Promise.all([
        prisma.foodFeedback.findMany({
          where,
          include: { user: { select: { id: true, name: true, schoolLevel: true } } },
          orderBy: { submittedAt: 'desc' },
          skip,
          take: parseInt(limit),
        }),
        prisma.foodFeedback.count({ where }),
      ]);

      res.json(ApiResponse.success({ records, total }));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/food-feedbacks/summary (admin only)
   * Ringkasan: distribusi rating, konsumsi, makanan positif/negatif
   */
  summary = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate } = req.query as Record<string, string>;
      const where: any = {};
      if (startDate) where.submittedAt = { ...where.submittedAt, gte: new Date(startDate) };
      if (endDate) where.submittedAt = { ...where.submittedAt, lte: new Date(endDate) };

      const [
        totalFeedbacks,
        consumptionDist,
        avgRatingsByFood,
      ] = await Promise.all([
        prisma.foodFeedback.count({ where }),

        // Distribusi status konsumsi
        prisma.foodFeedback.groupBy({
          by: ['consumptionStatus'],
          where,
          _count: { id: true },
        }),

        // Rata-rata rating per makanan (top 10 terbaik & terburuk)
        prisma.foodFeedback.groupBy({
          by: ['foodName'],
          where: { ...where, satisfactionRating: { not: null } },
          _avg: { satisfactionRating: true, tastRating: true },
          _count: { id: true },
          orderBy: { _avg: { satisfactionRating: 'desc' } },
          take: 20,
        }),
      ]);

      // Urutkan dan tandai positif vs negatif
      const sorted = avgRatingsByFood
        .filter((f) => (f._count?.id ?? 0) >= 1)
        .map((f) => ({
          foodName: f.foodName,
          count: f._count.id,
          avgSatisfaction: Math.round((f._avg.satisfactionRating ?? 0) * 10) / 10,
          avgTaste: Math.round((f._avg.tastRating ?? 0) * 10) / 10,
          sentiment: (f._avg.satisfactionRating ?? 0) >= 3.5 ? 'positif' : 'negatif',
        }));

      // Makanan paling sering dilaporkan sebagai "hampir_tidak dimakan"
      const leftoverFoods = await prisma.foodFeedback.groupBy({
        by: ['foodName'],
        where: { ...where, consumptionStatus: 'hampir_tidak' },
        _count: { id: true },
        orderBy: { _count: { id: 'desc' } },
        take: 10,
      });

      res.json(ApiResponse.success({
        totalFeedbacks,
        consumptionDistribution: consumptionDist.map((c) => ({
          // Hanya laporan pilihan pengguna, bukan berat aktual
          status: c.consumptionStatus ?? 'tidak_diisi',
          count: c._count.id,
        })),
        foodSentiment: sorted,
        mostLeftoverReported: leftoverFoods.map((f) => ({
          foodName: f.foodName,
          reportCount: f._count.id,
          note: 'Jumlah laporan pilihan pengguna, bukan berat sisa aktual',
        })),
      }));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/food-feedbacks/export (admin only)
   */
  exportCsv = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate } = req.query as Record<string, string>;
      const where: any = {};
      if (startDate) where.submittedAt = { ...where.submittedAt, gte: new Date(startDate) };
      if (endDate) where.submittedAt = { ...where.submittedAt, lte: new Date(endDate) };

      const records = await prisma.foodFeedback.findMany({
        where,
        include: { user: { select: { name: true, email: true, schoolLevel: true } } },
        orderBy: { submittedAt: 'desc' },
      });

      const header = 'Tanggal,Nama Pengguna,Email,Jenjang,Nama Makanan,Rating Rasa,Rating Tekstur,Rating Aroma,Rating Porsi,Rating Kepuasan,Status Konsumsi,Saran\n';
      const rows = records.map((r) =>
        [
          r.submittedAt.toISOString(),
          `"${r.user.name}"`,
          r.user.email,
          r.user.schoolLevel ?? '',
          `"${r.foodName}"`,
          r.tastRating ?? '',
          r.textureRating ?? '',
          r.aromaRating ?? '',
          r.portionRating ?? '',
          r.satisfactionRating ?? '',
          r.consumptionStatus ?? '',
          `"${r.suggestion ?? ''}"`,
        ].join(',')
      );

      res.setHeader('Content-Type', 'text/csv; charset=utf-8');
      res.setHeader('Content-Disposition', 'attachment; filename="food_feedbacks.csv"');
      res.send('\uFEFF' + header + rows.join('\n'));
    } catch (error) {
      next(error);
    }
  };
}
