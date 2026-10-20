import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FoodFeedbacksService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(startDate?: string, endDate?: string) {
    const where: any = {};
    if (startDate || endDate) {
      where.submittedAt = {};
      if (startDate) where.submittedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.submittedAt.lte = end;
      }
    }

    const [consumptionDist, allFeedbacks] = await Promise.all([
      this.prisma.foodFeedback.groupBy({
        by: ['consumptionStatus'],
        _count: { id: true },
        where,
      }),
      this.prisma.foodFeedback.findMany({
        where,
        select: {
          foodName: true,
          consumptionStatus: true,
          satisfactionRating: true,
          tastRating: true,
        },
      }),
    ]);

    // Agregat per makanan
    const foodMap = new Map<string, {
      name: string;
      satisfactionSum: number; satisfactionCount: number;
      tasteSum: number; tasteCount: number;
      leftoverCount: number; total: number;
    }>();

    for (const f of allFeedbacks) {
      const key = f.foodName;
      if (!foodMap.has(key)) {
        foodMap.set(key, { name: key, satisfactionSum: 0, satisfactionCount: 0, tasteSum: 0, tasteCount: 0, leftoverCount: 0, total: 0 });
      }
      const entry = foodMap.get(key)!;
      entry.total++;
      if (f.satisfactionRating) { entry.satisfactionSum += f.satisfactionRating; entry.satisfactionCount++; }
      if (f.tastRating) { entry.tasteSum += f.tastRating; entry.tasteCount++; }
      if (f.consumptionStatus === 'hampir_tidak') entry.leftoverCount++;
    }

    const foodSentiment = Array.from(foodMap.values())
      .map((f) => ({
        foodName: f.name,
        avgSatisfaction: f.satisfactionCount > 0 ? +(f.satisfactionSum / f.satisfactionCount).toFixed(2) : null,
        avgTaste: f.tasteCount > 0 ? +(f.tasteSum / f.tasteCount).toFixed(2) : null,
        totalFeedbacks: f.total,
      }))
      .sort((a, b) => (b.avgSatisfaction ?? 0) - (a.avgSatisfaction ?? 0));

    // Makanan paling sering hampir tidak dimakan
    const mostLeftoverReported = Array.from(foodMap.values())
      .filter((f) => f.leftoverCount > 0)
      .sort((a, b) => b.leftoverCount - a.leftoverCount)
      .slice(0, 10)
      .map((f) => ({
        foodName: f.name,
        reportCount: f.leftoverCount,
        note: 'Jumlah laporan pilihan "hampir tidak dimakan" dari siswa (bukan berat aktual)',
      }));

    return {
      consumptionDistribution: consumptionDist.map((c) => ({
        status: c.consumptionStatus ?? 'tidak_diisi',
        count: c._count.id,
      })),
      foodSentiment,
      mostLeftoverReported,
    };
  }

  async findAll(params: {
    startDate?: string;
    endDate?: string;
    foodName?: string;
    consumptionStatus?: string;
    page?: number;
    limit?: number;
  }) {
    const { startDate, endDate, foodName, consumptionStatus, page = 1, limit = 20 } = params;
    const skip = (page - 1) * limit;
    const where: any = {};

    if (foodName) where.foodName = { contains: foodName, mode: 'insensitive' };
    if (consumptionStatus) where.consumptionStatus = consumptionStatus;
    if (startDate || endDate) {
      where.submittedAt = {};
      if (startDate) where.submittedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.submittedAt.lte = end;
      }
    }

    const [records, total] = await Promise.all([
      this.prisma.foodFeedback.findMany({
        where, skip, take: limit,
        orderBy: { submittedAt: 'desc' },
        include: { user: { select: { name: true, schoolLevel: true } } },
      }),
      this.prisma.foodFeedback.count({ where }),
    ]);

    return { records, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async exportCsv(startDate?: string, endDate?: string): Promise<string> {
    const where: any = {};
    if (startDate || endDate) {
      where.submittedAt = {};
      if (startDate) where.submittedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.submittedAt.lte = end;
      }
    }

    const records = await this.prisma.foodFeedback.findMany({
      where,
      orderBy: { submittedAt: 'desc' },
      include: { user: { select: { name: true, email: true, schoolLevel: true } } },
    });

    const header = 'Tanggal,Nama Siswa,Jenjang,Nama Makanan,Rasa,Tekstur,Aroma,Porsi,Kepuasan,Status Konsumsi*,Saran';
    const rows = records.map((r) => [
      r.submittedAt.toISOString(),
      r.user?.name ?? '',
      r.user?.schoolLevel ?? '',
      `"${r.foodName.replace(/"/g, '""')}"`,
      r.tastRating ?? '',
      r.textureRating ?? '',
      r.aromaRating ?? '',
      r.portionRating ?? '',
      r.satisfactionRating ?? '',
      r.consumptionStatus ?? '',
      `"${(r.suggestion ?? '').replace(/"/g, '""')}"`,
    ].join(','));

    const disclaimer = '"*Status konsumsi adalah pilihan pengguna, bukan pengukuran berat sisa aktual"';
    return [header, ...rows, '', disclaimer].join('\n');
  }
}
