import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SchoolsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params: {
    search?: string; level?: string; type?: string; page?: number; limit?: number;
  }, sppgId?: string) {
    const { search, level, type, page = 1, limit = 20 } = params;
    const skip = (page - 1) * limit;
    const where: any = {};
    if (sppgId) where.sppgId = sppgId;
    if (search) where.name = { contains: search, mode: 'insensitive' };

    // Pemisah Sekolah vs Posyandu (Posyandu = level 'Posyandu')
    if (type === 'posyandu') where.level = 'Posyandu';
    else if (type === 'sekolah') where.level = { not: 'Posyandu' };

    // Filter jenjang spesifik (SD/SMP/...) menimpa filter type
    if (level) where.level = level;

    const [records, total] = await Promise.all([
      this.prisma.school.findMany({
        where, skip, take: limit,
        orderBy: [{ level: 'asc' }, { name: 'asc' }],
        include: { _count: { select: { mbgMenus: true } } },
      }),
      this.prisma.school.count({ where }),
    ]);

    return { records, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async create(data: {
    name: string; level: string;
    address?: string; city?: string; sppgId?: string;
  }, sppgId?: string) {
    // Admin SPPG: lembaga baru otomatis milik SPPG-nya (sppgId dari request diabaikan)
    if (sppgId) {
      return this.prisma.school.create({
        data: { name: data.name, level: data.level, address: data.address, city: data.city, sppgId },
      });
    }
    return this.prisma.school.create({ data });
  }

  async update(id: string, data: {
    name?: string; level?: string;
    address?: string; city?: string;
  }, sppgId?: string) {
    const s = await this.prisma.school.findUnique({ where: { id } });
    if (!s) throw new Error('Lembaga tidak ditemukan.');
    if (sppgId) {
      if (s.sppgId !== sppgId) throw new Error('Lembaga tidak termasuk wilayah SPPG Anda.');
      // Admin SPPG hanya boleh mengubah data dasar, tidak boleh memindahkan ke SPPG lain
      return this.prisma.school.update({
        where: { id },
        data: { name: data.name, level: data.level, address: data.address, city: data.city },
      });
    }
    return this.prisma.school.update({ where: { id }, data });
  }

  async delete(id: string, sppgId?: string) {
    const s = await this.prisma.school.findUnique({
      where: { id }, include: { _count: { select: { mbgMenus: true } } },
    });
    if (!s) throw new Error('Lembaga tidak ditemukan.');
    if (sppgId && s.sppgId !== sppgId) throw new Error('Lembaga tidak termasuk wilayah SPPG Anda.');
    if (s._count.mbgMenus > 0)
      throw new Error(`Lembaga tidak bisa dihapus karena memiliki ${s._count.mbgMenus} jadwal distribusi.`);
    await this.prisma.school.delete({ where: { id } });
    return { deleted: true, id };
  }
}