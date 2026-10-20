import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateStatusDto } from './dto/update-status.dto';

@Injectable()
export class MenuRequestsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params: {
    status?: string;
    search?: string;
    startDate?: string;
    endDate?: string;
    page?: number;
    limit?: number;
  }) {
    const { status, search, startDate, endDate, page = 1, limit = 20 } = params;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (status) where.status = status;
    if (search) where.menuName = { contains: search, mode: 'insensitive' };
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
      this.prisma.menuRequest.findMany({
        where,
        skip,
        take: limit,
        orderBy: { submittedAt: 'desc' },
        include: {
          user: { select: { name: true, email: true, schoolLevel: true, class_: true } },
        },
      }),
      this.prisma.menuRequest.count({ where }),
    ]);

    return {
      records,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async grouped() {
    const grouped = await this.prisma.menuRequest.groupBy({
      by: ['menuName'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 20,
    });

    return grouped.map((g) => ({
      menuName: g.menuName,
      count: g._count.id,
    }));
  }

  async updateStatus(id: string, dto: UpdateStatusDto) {
    const existing = await this.prisma.menuRequest.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Usulan menu dengan id '${id}' tidak ditemukan`);
    }

    return this.prisma.menuRequest.update({
      where: { id },
      data: {
        status: dto.status,
        ...(dto.adminNote !== undefined && { adminNote: dto.adminNote }),
      },
      include: {
        user: { select: { name: true, email: true } },
      },
    });
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

    const records = await this.prisma.menuRequest.findMany({
      where,
      orderBy: { submittedAt: 'desc' },
      include: { user: { select: { name: true, email: true, schoolLevel: true } } },
    });

    const header = 'Tanggal,Nama Siswa,Jenjang,Email,Menu Diusulkan,Alasan,Status,Catatan Admin';
    const rows = records.map((r) => {
      const cols = [
        r.submittedAt.toISOString(),
        r.user?.name ?? '',
        r.user?.schoolLevel ?? '',
        r.user?.email ?? '',
        `"${r.menuName.replace(/"/g, '""')}"`,
        `"${(r.reason ?? '').replace(/"/g, '""')}"`,
        r.status,
        `"${(r.adminNote ?? '').replace(/"/g, '""')}"`,
      ];
      return cols.join(',');
    });

    return [header, ...rows].join('\n');
  }
}
