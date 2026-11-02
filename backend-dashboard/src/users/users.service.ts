import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  /** Hanya pengguna mobile; akun admin tidak ditampilkan. */
  private readonly base = { role: 'student' };

  /**
   * Pemisah pengguna Sekolah vs Posyandu.
   * Posyandu = schoolLevel 'Posyandu'; Sekolah = selain itu (termasuk yang null).
   */
  private scope(type?: string) {
    if (type === 'posyandu') return { schoolLevel: 'Posyandu' };
    if (type === 'sekolah') {
      return { OR: [{ schoolLevel: null }, { schoolLevel: { not: 'Posyandu' } }] };
    }
    return {};
  }

  async findAll(p: {
    search?: string; level?: string; gender?: string; type?: string;
    allergy?: string; schoolId?: string; page: number; limit: number;
  }) {
    const where: any = { ...this.base };
    const and: any[] = [this.scope(p.type)];

    if (p.search) {
      and.push({
        OR: [
          { name: { contains: p.search, mode: 'insensitive' } },
          { email: { contains: p.search, mode: 'insensitive' } },
        ],
      });
    }
    where.AND = and;

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

  async summary(type?: string) {
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);

    const w = (extra: any = {}) => ({ ...this.base, ...extra, AND: [this.scope(type)] });

    const [total, newThisMonth, withAllergy, withoutSchool, male, female] = await Promise.all([
      this.prisma.user.count({ where: w() }),
      this.prisma.user.count({ where: w({ createdAt: { gte: startOfMonth } }) }),
      this.prisma.user.count({ where: w({ allergies: { isEmpty: false } }) }),
      this.prisma.user.count({ where: w({ schoolId: null }) }),
      this.prisma.user.count({ where: w({ gender: 'L' }) }),
      this.prisma.user.count({ where: w({ gender: 'P' }) }),
    ]);

    return { total, newThisMonth, withAllergy, withoutSchool, male, female };
  }
}