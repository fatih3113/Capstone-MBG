import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getOverview(startDate?: string, endDate?: string, sppgId?: string) {
    const dateFilter = this.buildDateFilter(startDate, endDate);

    // Filter per SPPG (Admin SPPG). Super Admin: sppgId undefined -> tanpa filter.
    const byUser = sppgId ? { user: { sppgId } } : {};
    const userScope = sppgId ? { sppgId } : {};
    const whereMenuRequest = { ...(dateFilter ? { submittedAt: dateFilter } : {}), ...byUser };
    const whereRating = { ...(dateFilter ? { ratedAt: dateFilter } : {}), ...byUser };
    const whereFeedback = { ...(dateFilter ? { submittedAt: dateFilter } : {}), ...byUser };
    const whereScan = { ...(dateFilter ? { scannedAt: dateFilter } : {}), ...byUser };

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
      posyanduCount,
      schoolCount,
      posyanduUsers,
      totalUsers,
      posyanduScans,
    ] = await Promise.all([
      // Total usulan menu
      this.prisma.menuRequest.count({ where: whereMenuRequest }),

      // Total rating
      this.prisma.foodRating.count({ where: whereRating }),

      // Total feedback
      this.prisma.foodFeedback.count({ where: whereFeedback }),

      // Total scan
      this.prisma.scanHistory.count({ where: whereScan }),

      // Rata-rata rating
      this.prisma.foodRating.aggregate({
        _avg: { rating: true },
        where: whereRating,
      }),

      // Distribusi status usulan menu
      this.prisma.menuRequest.groupBy({
        by: ['status'],
        _count: { id: true },
        where: whereMenuRequest,
        orderBy: { _count: { id: 'desc' } },
      }),

      // Distribusi status konsumsi
      this.prisma.foodFeedback.groupBy({
        by: ['consumptionStatus'],
        _count: { id: true },
        where: whereFeedback,
      }),

      // Top 5 makanan favorit
      this.prisma.foodRating.groupBy({
        by: ['foodName'],
        _avg: { rating: true },
        _count: { id: true },
        where: whereRating,
        orderBy: { _avg: { rating: 'desc' } },
        take: 5,
      }),

      // 10 scan terbaru
      this.prisma.scanHistory.findMany({
        take: 10,
        orderBy: { scannedAt: 'desc' },
        where: whereScan,
        include: {
          user: { select: { name: true, email: true, schoolLevel: true } },
          predictions: {
            include: { food: { select: { name: true, category: true } } },
            take: 5,
          },
        },
      }),

      // ── Ringkasan per lembaga ──────────────────────────────
      // Jumlah lembaga Posyandu
      this.prisma.school.count({ where: { level: 'Posyandu', ...userScope } }),

      // Jumlah lembaga Sekolah (selain Posyandu)
      this.prisma.school.count({ where: { level: { not: 'Posyandu' }, ...userScope } }),

      // Pengguna Posyandu
      this.prisma.user.count({ where: { role: 'student', schoolLevel: 'Posyandu', ...userScope } }),

      // Total pengguna mobile
      this.prisma.user.count({ where: { role: 'student', ...userScope } }),

      // Scan oleh pengguna Posyandu
      this.prisma.scanHistory.count({
        where: {
          ...(dateFilter ? { scannedAt: dateFilter } : {}),
          user: { schoolLevel: 'Posyandu', ...userScope },
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
      institutionSummary: {
        sekolah: {
          institutions: schoolCount,
          users: totalUsers - posyanduUsers,
          scans: totalScans - posyanduScans,
        },
        posyandu: {
          institutions: posyanduCount,
          users: posyanduUsers,
          scans: posyanduScans,
        },
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