import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DistributionService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Ringkasan distribusi: total sekolah, total jadwal menu, dan range tanggal
   */
  async getSummary(startDate?: string, endDate?: string) {
    const where = this._buildWhere(startDate, endDate);

    const [totalMenus, totalSchools, dateRange] = await Promise.all([
      this.prisma.mbgMenu.count({ where }),
      this.prisma.mbgMenu.groupBy({ by: ['schoolId'], where }).then((r) => r.length),
      this.prisma.mbgMenu.aggregate({ _min: { date: true }, _max: { date: true }, where }),
    ]);

    const totalItems = await this.prisma.mbgMenuItem.count({
      where: { menu: where },
    });

    return {
      totalMenuSchedules: totalMenus,
      totalSchoolsCovered: totalSchools,
      totalFoodItems: totalItems,
      dateRange: {
        earliest: dateRange._min.date,
        latest: dateRange._max.date,
      },
    };
  }

  /**
   * Distribusi per sekolah: sekolah + jumlah hari menu + daftar makanan
   */
  async getPerSchool(startDate?: string, endDate?: string) {
    const where = this._buildWhere(startDate, endDate);

    const menus = await this.prisma.mbgMenu.findMany({
      where,
      include: {
        school: { select: { id: true, name: true, level: true, city: true } },
        items: {
          include: {
            food: { select: { name: true, category: true } },
          },
        },
      },
      orderBy: { date: 'desc' },
    });

    // Agregasi per sekolah
    const schoolMap = new Map<string, {
      schoolId: string;
      schoolName: string;
      level: string;
      city: string | null;
      menuCount: number;
      dates: string[];
      foodSummary: Map<string, { name: string; category: string; count: number }>;
    }>();

    for (const menu of menus) {
      const sid = menu.school.id;
      if (!schoolMap.has(sid)) {
        schoolMap.set(sid, {
          schoolId: sid,
          schoolName: menu.school.name,
          level: menu.school.level,
          city: menu.school.city,
          menuCount: 0,
          dates: [],
          foodSummary: new Map(),
        });
      }
      const entry = schoolMap.get(sid)!;
      entry.menuCount++;
      entry.dates.push(menu.date.toISOString().split('T')[0]);

      for (const item of menu.items) {
        const key = item.food.name;
        if (!entry.foodSummary.has(key)) {
          entry.foodSummary.set(key, { name: key, category: item.food.category, count: 0 });
        }
        entry.foodSummary.get(key)!.count++;
      }
    }

    return Array.from(schoolMap.values()).map((s) => ({
      schoolId: s.schoolId,
      schoolName: s.schoolName,
      level: s.level,
      city: s.city,
      menuCount: s.menuCount,
      recentDates: s.dates.slice(0, 5),
      topFoods: Array.from(s.foodSummary.values())
        .sort((a, b) => b.count - a.count)
        .slice(0, 5),
    }));
  }

  /**
   * Timeline distribusi: jadwal per tanggal (untuk kalender/audit)
   */
  async getTimeline(startDate?: string, endDate?: string, page = 1, limit = 30) {
    const where = this._buildWhere(startDate, endDate);
    const skip = (page - 1) * limit;

    const [records, total] = await Promise.all([
      this.prisma.mbgMenu.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date: 'desc' },
        include: {
          school: { select: { name: true, level: true, city: true } },
          items: {
            include: { food: { select: { name: true, category: true } } },
          },
        },
      }),
      this.prisma.mbgMenu.count({ where }),
    ]);

    const formatted = records.map((m) => ({
      id: m.id,
      date: m.date.toISOString().split('T')[0],
      dayName: m.dayName,
      school: m.school,
      foods: m.items.map((i) => ({
        name: i.food.name,
        category: i.food.category,
        portionGram: i.portionGram,
      })),
    }));

    return { records: formatted, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  /**
   * Export CSV untuk keperluan audit
   */
  async exportCsv(startDate?: string, endDate?: string): Promise<string> {
    const where = this._buildWhere(startDate, endDate);

    const records = await this.prisma.mbgMenu.findMany({
      where,
      orderBy: [{ date: 'desc' }, { school: { name: 'asc' } }],
      include: {
        school: { select: { name: true, level: true, city: true } },
        items: {
          include: { food: { select: { name: true, category: true } } },
        },
      },
    });

    const header = ['Tanggal', 'Hari', 'Nama Sekolah', 'Jenjang', 'Kota', 'Menu MBG'].join(',');
    const rows = records.map((r) => [
      r.date.toISOString().split('T')[0],
      `"${r.dayName}"`,
      `"${r.school.name}"`,
      r.school.level,
      `"${r.school.city ?? ''}"`,
      `"${r.items.map((i) => `${i.food.name} (${i.portionGram}g)`).join('; ')}"`,
    ].join(','));

    return [header, ...rows].join('\n');
  }

  private _buildWhere(startDate?: string, endDate?: string) {
    const where: any = {};
    if (startDate || endDate) {
      where.date = {};
      if (startDate) where.date.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.date.lte = end;
      }
    }
    return where;
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────

  /** Semua sekolah (untuk dropdown form) */
  async getSchools() {
    return this.prisma.school.findMany({ orderBy: [{ level: 'asc' }, { name: 'asc' }] });
  }

  /** Semua makanan aktif (untuk dropdown form) */
  async getFoods() {
    return this.prisma.food.findMany({
      where: { isActive: true },
      select: { id: true, name: true, category: true },
      orderBy: [{ category: 'asc' }, { name: 'asc' }],
    });
  }

  /** Buat jadwal distribusi baru */
  async createSchedule(data: {
    schoolId: string;
    date: string;
    items: { foodId: string; portionGram: number }[];
  }) {
    const dateObj = new Date(data.date);
    dateObj.setHours(0, 0, 0, 0);
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const dayName = days[dateObj.getDay()];

    // Cek duplikat
    const existing = await this.prisma.mbgMenu.findUnique({
      where: { schoolId_date: { schoolId: data.schoolId, date: dateObj } },
    });
    if (existing) {
      throw new Error(`Jadwal untuk sekolah ini pada tanggal ${data.date} sudah ada.`);
    }

    const created = await this.prisma.mbgMenu.create({
      data: {
        schoolId: data.schoolId,
        date: dateObj,
        dayName,
        items: {
          create: data.items.map((i) => ({ foodId: i.foodId, portionGram: i.portionGram })),
        },
      },
      include: {
        school: { select: { name: true, level: true } },
        items: { include: { food: { select: { name: true } } } },
      },
    });
    return created;
  }

  /** Update jadwal (ganti item, bisa ganti tanggal) */
  async updateSchedule(id: string, data: {
    schoolId?: string;
    date?: string;
    items?: { foodId: string; portionGram: number }[];
  }) {
    const menu = await this.prisma.mbgMenu.findUnique({ where: { id } });
    if (!menu) throw new Error('Jadwal tidak ditemukan.');

    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const updateData: any = {};

    if (data.date) {
      const dateObj = new Date(data.date);
      dateObj.setHours(0, 0, 0, 0);
      updateData.date = dateObj;
      updateData.dayName = days[dateObj.getDay()];
    }
    if (data.schoolId) updateData.schoolId = data.schoolId;

    // Hapus item lama jika ada item baru
    if (data.items && data.items.length > 0) {
      await this.prisma.mbgMenuItem.deleteMany({ where: { menuId: id } });
      updateData.items = {
        create: data.items.map((i) => ({ foodId: i.foodId, portionGram: i.portionGram })),
      };
    }

    const updated = await this.prisma.mbgMenu.update({
      where: { id },
      data: updateData,
      include: {
        school: { select: { name: true, level: true } },
        items: { include: { food: { select: { name: true } } } },
      },
    });
    return updated;
  }

  /** Hapus jadwal beserta semua item-nya */
  async deleteSchedule(id: string) {
    const menu = await this.prisma.mbgMenu.findUnique({ where: { id } });
    if (!menu) throw new Error('Jadwal tidak ditemukan.');
    await this.prisma.mbgMenuItem.deleteMany({ where: { menuId: id } });
    await this.prisma.mbgMenu.delete({ where: { id } });
    return { deleted: true, id };
  }
}

