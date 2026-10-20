import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FoodRatingsService {
  constructor(private readonly prisma: PrismaService) {}

  async getRanking(startDate?: string, endDate?: string, limit = 10) {
    const where: any = {};
    if (startDate || endDate) {
      where.ratedAt = {};
      if (startDate) where.ratedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.ratedAt.lte = end;
      }
    }

    const grouped = await this.prisma.foodRating.groupBy({
      by: ['foodName'],
      _avg: { rating: true },
      _count: { id: true },
      where,
      orderBy: { _avg: { rating: 'desc' } },
      take: limit,
    });

    return grouped.map((g, i) => ({
      rank: i + 1,
      foodName: g.foodName,
      avgRating: g._avg.rating ? +g._avg.rating.toFixed(2) : 0,
      voteCount: g._count.id,
    }));
  }

  async findAll(params: {
    startDate?: string;
    endDate?: string;
    foodName?: string;
    page?: number;
    limit?: number;
  }) {
    const { startDate, endDate, foodName, page = 1, limit = 20 } = params;
    const skip = (page - 1) * limit;
    const where: any = {};

    if (foodName) where.foodName = { contains: foodName, mode: 'insensitive' };
    if (startDate || endDate) {
      where.ratedAt = {};
      if (startDate) where.ratedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.ratedAt.lte = end;
      }
    }

    const [records, total] = await Promise.all([
      this.prisma.foodRating.findMany({
        where, skip, take: limit,
        orderBy: { ratedAt: 'desc' },
        include: { user: { select: { name: true, schoolLevel: true } } },
      }),
      this.prisma.foodRating.count({ where }),
    ]);

    return { records, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async exportCsv(startDate?: string, endDate?: string): Promise<string> {
    const where: any = {};
    if (startDate || endDate) {
      where.ratedAt = {};
      if (startDate) where.ratedAt.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.ratedAt.lte = end;
      }
    }

    const records = await this.prisma.foodRating.findMany({
      where,
      orderBy: { ratedAt: 'desc' },
      include: { user: { select: { name: true, email: true, schoolLevel: true } } },
    });

    const header = 'Tanggal,Nama Siswa,Jenjang,Nama Makanan,Rating,Alasan';
    const rows = records.map((r) => [
      r.ratedAt.toISOString(),
      r.user?.name ?? '',
      r.user?.schoolLevel ?? '',
      `"${r.foodName.replace(/"/g, '""')}"`,
      r.rating,
      `"${(r.reason ?? '').replace(/"/g, '""')}"`,
    ].join(','));

    return [header, ...rows].join('\n');
  }
}
