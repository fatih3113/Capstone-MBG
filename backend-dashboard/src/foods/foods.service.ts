import {
  Injectable,
  ForbiddenException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, isSuperAdminRole } from '../auth/roles';

const CATEGORIES = ['Karbohidrat', 'Protein Hewani', 'Protein Nabati', 'Sayuran', 'Buah', 'Minuman'];

@Injectable()
export class FoodsService {
  constructor(private readonly prisma: PrismaService) {}

  /** List makanan (dengan filter per SPPG / master dan data gizi) */
  async findAll(params: {
    user: AuthUser;
    category?: string;
    search?: string;
    isActive?: string;
    scope?: 'all' | 'sppg' | 'master';
    page?: number;
    limit?: number;
  }) {
    const { user, category, search, isActive, scope, page = 1, limit = 20 } = params;
    const skip = (page - 1) * limit;
    const isSuper = isSuperAdminRole(user.role);
    const sppgId = user.sppgId;

    const where: any = {};
    if (category) where.category = category;
    if (search) where.name = { contains: search, mode: 'insensitive' };
    if (isActive !== undefined) where.isActive = isActive === 'true';

    if (isSuper) {
      // Super admin:
      if (scope === 'master') {
        where.sppgId = null;
      } else if (scope === 'sppg') {
        where.sppgId = { not: null };
      }
    } else {
      // Admin SPPG:
      if (!sppgId) {
        throw new ForbiddenException('Akun Anda belum terhubung ke SPPG.');
      }
      if (scope === 'sppg') {
        where.sppgId = sppgId; // hanya menu milik SPPG sendiri
      } else if (scope === 'master') {
        where.sppgId = null; // hanya menu master MBG
      } else {
        // default: Menu SPPG sendiri + Menu Master MBG
        where.OR = [
          { sppgId: null },
          { sppgId },
        ];
      }
    }

    const [records, total] = await Promise.all([
      this.prisma.food.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ category: 'asc' }, { name: 'asc' }],
        include: {
          nutrition: true,
          sppg: { select: { id: true, nama: true, kode: true } },
        },
      }),
      this.prisma.food.count({ where }),
    ]);

    return { records, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  /** Detail 1 makanan */
  async findOne(id: string, user: AuthUser) {
    const food = await this.prisma.food.findUnique({
      where: { id },
      include: {
        nutrition: true,
        sppg: { select: { id: true, nama: true, kode: true } },
      },
    });
    if (!food) throw new NotFoundException('Makanan tidak ditemukan.');

    const isSuper = isSuperAdminRole(user.role);
    if (!isSuper && food.sppgId && food.sppgId !== user.sppgId) {
      throw new ForbiddenException('Anda tidak memiliki akses ke data makanan ini.');
    }
    return food;
  }

  /** Buat makanan baru beserta data gizi */
  async create(data: {
    name: string;
    category: string;
    description?: string;
    imageUrl?: string;
    isActive?: boolean;
    sppgId?: string;
    nutrition?: NutritionInput;
  }, user: AuthUser) {
    const isSuper = isSuperAdminRole(user.role);
    const { nutrition, ...foodData } = data;

    let targetSppgId: string | null = null;
    if (!isSuper) {
      if (!user.sppgId) {
        throw new ForbiddenException('Akun Anda belum terhubung ke SPPG.');
      }
      targetSppgId = user.sppgId; // Terikat otomatis ke SPPG admin yang sedang login
    } else {
      targetSppgId = data.sppgId ?? null;
    }

    const food = await this.prisma.food.create({
      data: {
        ...foodData,
        sppgId: targetSppgId,
        isActive: foodData.isActive ?? true,
        nutrition: nutrition ? { create: nutrition as any } : undefined,
      },
      include: {
        nutrition: true,
        sppg: { select: { id: true, nama: true, kode: true } },
      },
    });
    return food;
  }

  /** Update makanan & data gizinya */
  async update(id: string, data: {
    name?: string;
    category?: string;
    description?: string;
    imageUrl?: string;
    isActive?: boolean;
    nutrition?: NutritionInput;
  }, user: AuthUser) {
    const food = await this.prisma.food.findUnique({ where: { id } });
    if (!food) throw new NotFoundException('Makanan tidak ditemukan.');

    const isSuper = isSuperAdminRole(user.role);
    if (!isSuper) {
      if (food.sppgId !== user.sppgId) {
        throw new ForbiddenException('Anda hanya dapat mengubah menu makanan milik SPPG Anda sendiri.');
      }
    }

    const { nutrition, ...foodData } = data;
    delete (foodData as any).sppgId;

    if (nutrition) {
      await this.prisma.nutrition.upsert({
        where: { foodId: id },
        create: { foodId: id, ...nutrition } as any,
        update: nutrition as any,
      });
    }

    const updated = await this.prisma.food.update({
      where: { id },
      data: foodData,
      include: {
        nutrition: true,
        sppg: { select: { id: true, nama: true, kode: true } },
      },
    });
    return updated;
  }

  /** Toggle aktif/nonaktif (soft delete) */
  async toggleActive(id: string, user: AuthUser) {
    const food = await this.prisma.food.findUnique({ where: { id } });
    if (!food) throw new NotFoundException('Makanan tidak ditemukan.');

    const isSuper = isSuperAdminRole(user.role);
    if (!isSuper && food.sppgId !== user.sppgId) {
      throw new ForbiddenException('Anda hanya dapat mengubah status menu makanan milik SPPG Anda sendiri.');
    }

    return this.prisma.food.update({
      where: { id },
      data: { isActive: !food.isActive },
      include: {
        nutrition: true,
        sppg: { select: { id: true, nama: true, kode: true } },
      },
    });
  }

  /** Hapus permanen (hanya jika tidak punya relasi aktif di jadwal) */
  async delete(id: string, user: AuthUser) {
    const food = await this.prisma.food.findUnique({
      where: { id },
      include: { predictions: true, menuItems: true },
    });
    if (!food) throw new NotFoundException('Makanan tidak ditemukan.');

    const isSuper = isSuperAdminRole(user.role);
    if (!isSuper && food.sppgId !== user.sppgId) {
      throw new ForbiddenException('Anda hanya dapat menghapus menu makanan milik SPPG Anda sendiri.');
    }

    if (food.predictions.length > 0 || food.menuItems.length > 0) {
      throw new BadRequestException('Makanan tidak bisa dihapus karena sudah digunakan di jadwal distribusi atau riwayat scan. Silakan nonaktifkan saja.');
    }

    await this.prisma.nutrition.deleteMany({ where: { foodId: id } });
    await this.prisma.food.delete({ where: { id } });
    return { deleted: true, id };
  }

  /** Daftar kategori */
  getCategories() {
    return CATEGORIES;
  }
}

interface NutritionInput {
  calories?: number;
  protein?: number;
  carbs?: number;
  fat?: number;
  fiber?: number;
  sugar?: number;
  sodium?: number;
  calcium?: number;
  iron?: number;
  vitaminC?: number;
  vitaminA?: number;
  portionGram?: number;
  cookingMethod?: string;
  dataSource?: string;
}
