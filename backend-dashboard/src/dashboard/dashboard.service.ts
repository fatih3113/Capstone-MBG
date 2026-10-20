import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getOverview(startDate?: string, endDate?: string) {
    const dateFilter = this.buildDateFilter(startDate, endDate);

    const [
      totalMenuRequests,
      totalFoodRatings,
      totalFeedbacks,
      totalScans,
      avgRatingAgg,
      menuRequestsByStatus,
      consumptionDistribution,
      topFavorites,
      recentScans,
    ] = await Promise.all([
      // Total usulan menu
      this.prisma.menuRequest.count({
        where: dateFilter ? { submittedAt: dateFilter } : undefined,
      }),

      // Total rating
      this.prisma.foodRating.count({
        where: dateFilter ? { ratedAt: dateFilter } : undefined,
      }),

      // Total feedback
      this.prisma.foodFeedback.count({
        where: dateFilter ? { submittedAt: dateFilter } : undefined,
      }),

      // Total scan
      this.prisma.scanHistory.count({
        where: dateFilter ? { scannedAt: dateFilter } : undefined,
      }),

      // Rata-rata rating
      this.prisma.foodRating.aggregate({
        _avg: { rating: true },
        where: dateFilter ? { ratedAt: dateFilter } : undefined,
      }),

      // Distribusi status usulan menu
      this.prisma.menuRequest.groupBy({
        by: ['status'],
        _count: { id: true },
        where: dateFilter ? { submittedAt: dateFilter } : undefined,
        orderBy: { _count: { id: 'desc' } },
      }),

      // Distribusi status konsumsi
      this.prisma.foodFeedback.groupBy({
        by: ['consumptionStatus'],
        _count: { id: true },
        where: dateFilter ? { submittedAt: dateFilter } : undefined,
      }),

      // Top 5 makanan favorit
      this.prisma.foodRating.groupBy({
        by: ['foodName'],
        _avg: { rating: true },
        _count: { id: true },
        where: dateFilter ? { ratedAt: dateFilter } : undefined,
        orderBy: { _avg: { rating: 'desc' } },
        take: 5,
      }),

      // 10 scan terbaru
      this.prisma.scanHistory.findMany({
        take: 10,
        orderBy: { scannedAt: 'desc' },
        where: dateFilter ? { scannedAt: dateFilter } : undefined,
        include: {
          user: { select: { name: true, email: true, schoolLevel: true } },
          predictions: {
            include: { food: { select: { name: true, category: true } } },
            take: 5,
          },
        },
      }),
    ]);

    return {
      summary: {
        totalMenuRequests,
        totalFoodRatings,
        totalFeedbacks,
        totalScans,
        avgFoodRating: avgRatingAgg._avg.rating
          ? +avgRatingAgg._avg.rating.toFixed(2)
          : null,
      },
      menuRequestsByStatus: menuRequestsByStatus.map((s) => ({
        status: s.status,
        count: s._count.id,
      })),
      consumptionSummary: consumptionDistribution.map((c) => ({
        status: c.consumptionStatus ?? 'tidak_diisi',
        count: c._count.id,
      })),
      topFavorites: topFavorites.map((f) => ({
        foodName: f.foodName,
        avgRating: f._avg.rating ? +f._avg.rating.toFixed(2) : 0,
        voteCount: f._count.id,
      })),
      recentScans: recentScans.map((s) => ({
        id: s.id,
        scannedAt: s.scannedAt,
        akgTarget: s.akgTarget,
        user: s.user,
        nutrition: {
          calories: s.totalCalories,
          protein: s.totalProtein,
          carbs: s.totalCarbs,
          fat: s.totalFat,
        },
        foods: s.predictions.map((p) => p.food.name),
      })),
    };
  }

  private buildDateFilter(startDate?: string, endDate?: string) {
    if (!startDate && !endDate) return null;
    const filter: any = {};
    if (startDate) filter.gte = new Date(startDate);
    if (endDate) {
      const end = new Date(endDate);
      end.setHours(23, 59, 59, 999);
      filter.lte = end;
    }
    return filter;
  }
}
