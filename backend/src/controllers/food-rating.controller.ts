import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class FoodRatingController {

  /**
   * POST /reports/food-ratings
   * Siswa memberikan rating makanan favorit (1-5)
   */
  create = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { foodId, foodName, rating, reason } = req.body;
      if (!foodName?.trim()) {
        res.status(400).json(ApiResponse.error('Nama makanan wajib diisi', 400));
        return;
      }
      if (!rating || rating < 1 || rating > 5) {
        res.status(400).json(ApiResponse.error('Rating harus antara 1–5', 400));
        return;
      }

      const record = await prisma.foodRating.create({
        data: {
          userId: req.userId!,
          foodId: foodId ?? null,
          foodName: foodName.trim(),
          rating: parseInt(rating),
          reason: reason?.trim() ?? null,
        },
      });

      res.status(201).json(ApiResponse.success(record, 'Rating berhasil disimpan'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/food-ratings/my
   * Siswa melihat rating yang pernah diberikan
   */
  listMine = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const records = await prisma.foodRating.findMany({
        where: { userId: req.userId! },
        orderBy: { ratedAt: 'desc' },
      });
      res.json(ApiResponse.success(records));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/food-ratings/ranking
   * Ranking makanan favorit: jumlah suara + rata-rata rating
   * Accessible: both student (summary) and admin (full)
   */
  ranking = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate, limit = '10' } = req.query as Record<string, string>;

      const where: any = {};
      if (startDate) where.ratedAt = { ...where.ratedAt, gte: new Date(startDate) };
      if (endDate) where.ratedAt = { ...where.ratedAt, lte: new Date(endDate) };

      const grouped = await prisma.foodRating.groupBy({
        by: ['foodName'],
        where,
        _count: { id: true },
        _avg: { rating: true },
        orderBy: [
          { _avg: { rating: 'desc' } },
          { _count: { id: 'desc' } },
        ],
        take: parseInt(limit),
      });

      const result = grouped.map((g, idx) => ({
        rank: idx + 1,
        foodName: g.foodName,
        voteCount: g._count.id,
        avgRating: Math.round((g._avg.rating ?? 0) * 10) / 10,
      }));

      res.json(ApiResponse.success(result));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/food-ratings (admin only)
   * Semua data rating dengan filter
   */
  listAll = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate, page = '1', limit = '50' } = req.query as Record<string, string>;
      const skip = (parseInt(page) - 1) * parseInt(limit);

      const where: any = {};
      if (startDate) where.ratedAt = { ...where.ratedAt, gte: new Date(startDate) };
      if (endDate) where.ratedAt = { ...where.ratedAt, lte: new Date(endDate) };

      const [records, total] = await Promise.all([
        prisma.foodRating.findMany({
          where,
          include: { user: { select: { id: true, name: true, schoolLevel: true } } },
          orderBy: { ratedAt: 'desc' },
          skip,
          take: parseInt(limit),
        }),
        prisma.foodRating.count({ where }),
      ]);

      res.json(ApiResponse.success({ records, total }));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/food-ratings/export (admin only)
   */
  exportCsv = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate } = req.query as Record<string, string>;
      const where: any = {};
      if (startDate) where.ratedAt = { ...where.ratedAt, gte: new Date(startDate) };
      if (endDate) where.ratedAt = { ...where.ratedAt, lte: new Date(endDate) };

      const records = await prisma.foodRating.findMany({
        where,
        include: { user: { select: { name: true, email: true, schoolLevel: true } } },
        orderBy: { ratedAt: 'desc' },
      });

      const header = 'Tanggal,Nama Pengguna,Email,Jenjang,Nama Makanan,Rating,Alasan\n';
      const rows = records.map((r) =>
        [
          r.ratedAt.toISOString(),
          `"${r.user.name}"`,
          r.user.email,
          r.user.schoolLevel ?? '',
          `"${r.foodName}"`,
          r.rating,
          `"${r.reason ?? ''}"`,
        ].join(',')
      );

      res.setHeader('Content-Type', 'text/csv; charset=utf-8');
      res.setHeader('Content-Disposition', 'attachment; filename="food_ratings.csv"');
      res.send('\uFEFF' + header + rows.join('\n'));
    } catch (error) {
      next(error);
    }
  };
}
