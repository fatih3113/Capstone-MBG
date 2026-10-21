import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const CATEGORIES = ['Karbohidrat', 'Protein Hewani', 'Protein Nabati', 'Sayuran', 'Buah', 'Minuman'];

@Injectable()
export class FoodsService {
  constructor(private readonly prisma: PrismaService) {}

  /** List semua makanan (dengan data gizi) */
  async findAll(params: {
    category?: string;
    search?: string;
    isActive?: string;
    page?: number;
    limit?: number;
  }) {
    const { category, search, isActive, page = 1, limit = 20 } = params;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (category) where.category = category;
    if (search) where.name = { contains: search, mode: 'insensitive' };
    if (isActive !== undefined) where.isActive = isActive === 'true';

    const [records, total] = await Promise.all([
      this.prisma.food.findMany({
        where, skip, take: limit,
        orderBy: [{ category: 'asc' }, { name: 'asc' }],
        include: { nutrition: true },
      }),
      this.prisma.food.count({ where }),
    ]);

    return { records, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  /** Detail 1 makanan */
  async findOne(id: string) {
    const food = await this.prisma.food.findUnique({
      where: { id },
      include: { nutrition: true },
    });
    if (!food) throw new Error('Makanan tidak ditemukan.');
    return food;
  }

  /** Buat makanan baru beserta data gizi */
  async create(data: {
    name: string;
    category: string;
    description?: string;
    imageUrl?: string;
    isActive?: boolean;
    nutrition?: NutritionInput;
  }) {
    const { nutrition, ...foodData } = data;
    // Cast nutrition ke any karena NutritionInput semua optional sementara Prisma butuh wajib
    const food = await this.prisma.food.create({
      data: {
        ...foodData,
        isActive: foodData.isActive ?? true,
        nutrition: nutrition ? { create: nutrition as any } : undefined,
      },
      include: { nutrition: true },
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
  }) {
    const food = await this.prisma.food.findUnique({ where: { id } });
    if (!food) throw new Error('Makanan tidak ditemukan.');

    const { nutrition, ...foodData } = data;

    if (nutrition) {
      // Upsert gizi: 'create' tanpa foodId (Prisma nested), 'update' pakai spread
      await this.prisma.nutrition.upsert({
        where: { foodId: id },
        create: { foodId: id, ...nutrition } as any,
        update: nutrition as any,
      });
    }

    const updated = await this.prisma.food.update({
      where: { id },
      data: foodData,
      include: { nutrition: true },
    });
    return updated;
  }

  /** Toggle aktif/nonaktif (soft delete) */
  async toggleActive(id: string) {
    const food = await this.prisma.food.findUnique({ where: { id } });
    if (!food) throw new Error('Makanan tidak ditemukan.');
    return this.prisma.food.update({
      where: { id },
      data: { isActive: !food.isActive },
      include: { nutrition: true },
    });
  }

  /** Hapus permanen (hanya jika tidak punya relasi aktif) */
  async delete(id: string) {
    const food = await this.prisma.food.findUnique({ where: { id }, include: { predictions: true, menuItems: true } });
    if (!food) throw new Error('Makanan tidak ditemukan.');
    if (food.predictions.length > 0 || food.menuItems.length > 0) {
      throw new Error('Makanan tidak bisa dihapus karena sudah digunakan di jadwal atau riwayat scan. Nonaktifkan saja.');
    }
    // Hapus nutrition dulu, lalu food
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
