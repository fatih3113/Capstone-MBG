import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class AdminDashboardController {

  /**
   * GET /admin/dashboard
   * Ringkasan semua data untuk dashboard admin
   */
  overview = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate } = req.query as Record<string, string>;
      const dateFilter: any = {};
      if (startDate) dateFilter.gte = new Date(startDate);
      if (endDate) dateFilter.lte = new Date(endDate);

      const [
        totalMenuRequests,
        totalFoodRatings,
        totalFeedbacks,
        totalScans,
        avgRating,
        consumptionSummary,
        menuRequestsByStatus,
        topFavorites,
        recentScans,
      ] = await Promise.all([
        prisma.menuRequest.count(
          startDate || endDate ? { where: { submittedAt: dateFilter } } : undefined
        ),
        prisma.foodRating.count(
          startDate || endDate ? { where: { ratedAt: dateFilter } } : undefined
        ),
        prisma.foodFeedback.count(
          startDate || endDate ? { where: { submittedAt: dateFilter } } : undefined
        ),
        prisma.scanHistory.count(
          startDate || endDate ? { where: { scannedAt: dateFilter } } : undefined
        ),

        // Rata-rata rating seluruh makanan
        prisma.foodRating.aggregate({
          _avg: { rating: true },
          where: startDate || endDate ? { ratedAt: dateFilter } : undefined,
        }),

        // Distribusi status konsumsi (bukan berat, hanya pilihan user)
        prisma.foodFeedback.groupBy({
          by: ['consumptionStatus'],
          _count: { id: true },
          where: startDate || endDate ? { submittedAt: dateFilter } : undefined,
        }),

        // Status usulan menu
        prisma.menuRequest.groupBy({
          by: ['status'],
          _count: { id: true },
        }),

        // Top 5 makanan favorit berdasarkan rata-rata rating
        prisma.foodRating.groupBy({
          by: ['foodName'],
          _avg: { rating: true },
          _count: { id: true },
          orderBy: [
            { _avg: { rating: 'desc' } },
            { _count: { id: 'desc' } },
          ],
          take: 5,
          where: startDate || endDate ? { ratedAt: dateFilter } : undefined,
        }),

        // 10 scan terbaru beserta ringkasan gizi
        prisma.scanHistory.findMany({
          take: 10,
          orderBy: { scannedAt: 'desc' },
          include: {
            user: { select: { name: true, schoolLevel: true } },
            predictions: {
              include: { food: { select: { name: true, category: true } } },
              take: 3,
            },
          },
          where: startDate || endDate ? { scannedAt: dateFilter } : undefined,
        }),
      ]);

      res.json(ApiResponse.success({
        summary: {
          totalMenuRequests,
          totalFoodRatings,
          totalFeedbacks,
          totalScans,
          avgFoodRating: Math.round((avgRating._avg.rating ?? 0) * 10) / 10,
        },
        menuRequestsByStatus: menuRequestsByStatus.map((s) => ({
          status: s.status,
          count: s._count.id,
        })),
        consumptionSummary: consumptionSummary.map((c) => ({
          status: c.consumptionStatus ?? 'tidak_diisi',
          count: c._count.id,
          note: 'Jumlah laporan pilihan pengguna, bukan berat sisa aktual',
        })),
        topFavorites: topFavorites.map((f, i) => ({
          rank: i + 1,
          foodName: f.foodName,
          avgRating: Math.round((f._avg.rating ?? 0) * 10) / 10,
          voteCount: f._count.id,
        })),
        recentScans: recentScans.map((s) => ({
          id: s.id,
          scannedAt: s.scannedAt,
          user: s.user,
          akgTarget: s.akgTarget,
          nutrition: {
            calories: s.totalCalories,
            protein: s.totalProtein,
            carbs: s.totalCarbs,
            fat: s.totalFat,
          },
          foods: s.predictions.map((p) => p.food?.name ?? '-'),
        })),
      }));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /admin/nutrition-reports
   * Laporan hasil scan gizi dengan filter
   */
  nutritionReports = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate, akgTarget, page = '1', limit = '20' } = req.query as Record<string, string>;
      const skip = (parseInt(page) - 1) * parseInt(limit);

      const where: any = {};
      if (startDate) where.scannedAt = { ...where.scannedAt, gte: new Date(startDate) };
      if (endDate) where.scannedAt = { ...where.scannedAt, lte: new Date(endDate) };
      if (akgTarget) where.akgTarget = akgTarget;

      const [records, total] = await Promise.all([
        prisma.scanHistory.findMany({
          where,
          include: {
            user: { select: { name: true, email: true, schoolLevel: true } },
            predictions: {
              include: { food: { select: { name: true, category: true } } },
            },
          },
          orderBy: { scannedAt: 'desc' },
          skip,
          take: parseInt(limit),
        }),
        prisma.scanHistory.count({ where }),
      ]);

      const formatted = records.map((r) => ({
        id: r.id,
        scannedAt: r.scannedAt,
        user: r.user,
        akgTarget: r.akgTarget,
        estimatedNutrition: {
          calories: r.totalCalories,
          protein: r.totalProtein,
          carbs: r.totalCarbs,
          fat: r.totalFat,
          fiber: r.totalFiber,
          note: 'Estimasi berdasarkan data komposisi pangan (TKPI/referensi), bukan analisis laboratorium.',
        },
        foods: r.predictions.map((p) => ({
          name: p.food?.name ?? '-',
          category: p.food?.category ?? '-',
          confidence: p.confidence,
          portionGram: p.portionEstimateGram,
          weightInputGram: p.weightInputGram,
        })),
      }));

      res.json(ApiResponse.success({ records: formatted, total, page: parseInt(page) }));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /admin/nutrition-reports/export (admin only)
   */
  exportNutritionCsv = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate } = req.query as Record<string, string>;
      const where: any = {};
      if (startDate) where.scannedAt = { ...where.scannedAt, gte: new Date(startDate) };
      if (endDate) where.scannedAt = { ...where.scannedAt, lte: new Date(endDate) };

      const records = await prisma.scanHistory.findMany({
        where,
        include: { user: { select: { name: true, email: true, schoolLevel: true } } },
        orderBy: { scannedAt: 'desc' },
      });

      const header = 'Tanggal,Nama Pengguna,Email,Jenjang,Sasaran AKG,Kalori (kcal),Protein (g),Karbohidrat (g),Lemak (g),Serat (g)\n';
      const rows = records.map((r) =>
        [
          r.scannedAt.toISOString(),
          `"${r.user.name}"`,
          r.user.email,
          r.user.schoolLevel ?? '',
          r.akgTarget ?? '',
          r.totalCalories.toFixed(1),
          r.totalProtein.toFixed(1),
          r.totalCarbs.toFixed(1),
          r.totalFat.toFixed(1),
          r.totalFiber.toFixed(1),
        ].join(',')
      );

      res.setHeader('Content-Type', 'text/csv; charset=utf-8');
      res.setHeader('Content-Disposition', 'attachment; filename="nutrition_reports.csv"');
      res.send('\uFEFF' + header + rows.join('\n'));
    } catch (error) {
      next(error);
    }
  };
}
