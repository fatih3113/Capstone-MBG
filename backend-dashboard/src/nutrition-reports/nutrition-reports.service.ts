import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NutritionReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params: {
    startDate?: string;
    endDate?: string;
    akgTarget?: string;
    schoolLevel?: string;
    page?: number;
    limit?: number;
  }) {
    const { startDate, endDate, akgTarget, schoolLevel, page = 1, limit = 20 } = params;
    const skip = (page - 1) * limit;
    const where: any = { status: 'success' };

    if (akgTarget) where.akgTarget = { contains: akgTarget, mode: 'insensitive' };
    if (startDate || endDate) {
      where.scannedAt = {};
      if (startDate) where.scannedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.scannedAt.lte = end;
      }
    }

    // Filter by schoolLevel via user relation
    const userFilter = schoolLevel
      ? { user: { schoolLevel: { contains: schoolLevel, mode: 'insensitive' as const } } }
      : {};

    const [records, total] = await Promise.all([
      this.prisma.scanHistory.findMany({
        where: { ...where, ...userFilter },
        skip,
        take: limit,
        orderBy: { scannedAt: 'desc' },
        include: {
          user: { select: { name: true, email: true, schoolLevel: true, class_: true } },
          predictions: {
            include: { food: { select: { name: true, category: true } } },
          },
        },
      }),
      this.prisma.scanHistory.count({ where: { ...where, ...userFilter } }),
    ]);

    const formatted = records.map((s) => ({
      id: s.id,
      scannedAt: s.scannedAt,
      akgTarget: s.akgTarget,
      user: s.user,
      estimatedNutrition: {
        calories: s.totalCalories,
        protein: s.totalProtein,
        carbs: s.totalCarbs,
        fat: s.totalFat,
        fiber: s.totalFiber,
      },
      foods: s.predictions.map((p) => ({
        name: p.food.name,
        category: p.food.category,
        confidence: p.confidence,
        portionGram: p.weightInputGram ?? p.portionEstimateGram,
      })),
      disclaimer: 'Nilai gizi adalah estimasi berdasarkan data komposisi pangan, bukan analisis laboratorium',
    }));

    return { records: formatted, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async exportCsv(startDate?: string, endDate?: string): Promise<string> {
    const where: any = { status: 'success' };
    if (startDate || endDate) {
      where.scannedAt = {};
      if (startDate) where.scannedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.scannedAt.lte = end;
      }
    }

    const records = await this.prisma.scanHistory.findMany({
      where,
      orderBy: { scannedAt: 'desc' },
      include: {
        user: { select: { name: true, email: true, schoolLevel: true } },
        predictions: { include: { food: { select: { name: true } } } },
      },
    });

    const header = [
      'Tanggal Scan', 'Nama Siswa', 'Jenjang', 'Email',
      'Sasaran AKG', 'Kalori* (kcal)', 'Protein* (g)', 'Karbo* (g)',
      'Lemak* (g)', 'Serat* (g)', 'Makanan Terdeteksi',
    ].join(',');

    const rows = records.map((r) => [
      r.scannedAt.toISOString(),
      r.user?.name ?? '',
      r.user?.schoolLevel ?? '',
      r.user?.email ?? '',
      r.akgTarget ?? '',
      r.totalCalories.toFixed(1),
      r.totalProtein.toFixed(1),
      r.totalCarbs.toFixed(1),
      r.totalFat.toFixed(1),
      r.totalFiber.toFixed(1),
      `"${r.predictions.map((p) => p.food.name).join('; ')}"`,
    ].join(','));

    const disclaimer = '"*Semua nilai gizi adalah estimasi berdasarkan data komposisi pangan (TKPI/referensi internal), bukan analisis laboratorium"';
    return [header, ...rows, '', disclaimer].join('\n');
  }

  async getAggregateStats(startDate?: string, endDate?: string) {
    const where: any = { status: 'success' };
    if (startDate || endDate) {
      where.scannedAt = {};
      if (startDate) where.scannedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.scannedAt.lte = end;
      }
    }

    const stats = await this.prisma.scanHistory.aggregate({
      _avg: {
        totalCalories: true,
        totalProtein: true,
        totalCarbs: true,
        totalFat: true,
      },
      _count: { id: true },
      where,
    });

    return {
      totalScans: stats._count.id,
      avgCalories: stats._avg.totalCalories ? +stats._avg.totalCalories.toFixed(1) : 0,
      avgProtein: stats._avg.totalProtein ? +stats._avg.totalProtein.toFixed(1) : 0,
      avgCarbs: stats._avg.totalCarbs ? +stats._avg.totalCarbs.toFixed(1) : 0,
      avgFat: stats._avg.totalFat ? +stats._avg.totalFat.toFixed(1) : 0,
      disclaimer: 'Nilai gizi adalah estimasi berdasarkan data komposisi pangan, bukan analisis laboratorium',
    };
  }
}
