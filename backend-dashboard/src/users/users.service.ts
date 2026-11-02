import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  /** Hanya pengguna mobile; akun admin tidak ditampilkan. */
  private readonly base = { role: 'student' };

  async findAll(p: {
    search?: string; level?: string; gender?: string;
    allergy?: string; schoolId?: string; page: number; limit: number;
  }) {
    const where: any = { ...this.base };

    if (p.search) {
      where.OR = [
        { name: { contains: p.search, mode: 'insensitive' } },
        { email: { contains: p.search, mode: 'insensitive' } },
      ];
    }
    if (p.level) where.schoolLevel = p.level;
    if (p.gender === 'L' || p.gender === 'P') where.gender = p.gender;
    if (p.schoolId) where.schoolId = p.schoolId;

    if (p.allergy === 'ada') where.allergies = { isEmpty: false };
    if (p.allergy === 'tidak') { where.allergy_filled = true; where.allergies = { isEmpty: true }; }
    if (p.allergy === 'belum') where.allergy_filled = false;

    const skip = (p.page - 1) * p.limit;

    const [rows, total] = await Promise.all([
      this.prisma.user.findMany({
        where, skip, take: p.limit,
        orderBy: { createdAt: 'desc' },
        // Pilih field secara eksplisit — passwordHash TIDAK boleh ikut keluar.
        select: {
          id: true, name: true, email: true, gender: true, age: true,
          class_: true, schoolLevel: true, createdAt: true,
          allergies: true, allergy_other: true, allergy_filled: true,
          school: { select: { id: true, name: true } },
          sppg: { select: { id: true, nama: true } },
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    const records = rows.map(({ class_, allergy_other, allergy_filled, ...u }) => ({
      ...u,
      className: class_,
      allergyOther: allergy_other,
      allergyFilled: allergy_filled,
    }));

    return { records, total, page: p.page, limit: p.limit, totalPages: Math.ceil(total / p.limit) };
  }

  async summary() {
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);

    const [total, newThisMonth, withAllergy, withoutSchool, male, female] = await Promise.all([
      this.prisma.user.count({ where: this.base }),
      this.prisma.user.count({ where: { ...this.base, createdAt: { gte: startOfMonth } } }),
      this.prisma.user.count({ where: { ...this.base, allergies: { isEmpty: false } } }),
      this.prisma.user.count({ where: { ...this.base, schoolId: null } }),
      this.prisma.user.count({ where: { ...this.base, gender: 'L' } }),
      this.prisma.user.count({ where: { ...this.base, gender: 'P' } }),
    ]);

    return { total, newThisMonth, withAllergy, withoutSchool, male, female };
  }
}