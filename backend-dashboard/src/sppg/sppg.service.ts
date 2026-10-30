import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSppgDto } from './dto/create-sppg.dto';
import { UpdateSppgDto } from './dto/update-sppg.dto';
import { QuerySppgDto } from './dto/query-sppg.dto';

@Injectable()
export class SppgService {
  constructor(private readonly prisma: PrismaService) {}

  // ── CRUD ─────────────────────────────────────────────────────────────────

  async findAll(query: QuerySppgDto) {
    const { search, provinsi, kabupatenKota, isActive, page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (search) {
      where.OR = [
        { nama: { contains: search, mode: 'insensitive' } },
        { kode: { contains: search, mode: 'insensitive' } },
      ];
    }
    if (provinsi) where.provinsi = { contains: provinsi, mode: 'insensitive' };
    if (kabupatenKota) where.kabupatenKota = { contains: kabupatenKota, mode: 'insensitive' };
    if (isActive === 'true') where.isActive = true;
    if (isActive === 'false') where.isActive = false;

    const [records, total] = await Promise.all([
      this.prisma.sppg.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ provinsi: 'asc' }, { kabupatenKota: 'asc' }, { nama: 'asc' }],
        include: {
          _count: { select: { users: true, schools: true } },
        },
      }),
      this.prisma.sppg.count({ where }),
    ]);

    return { records, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const sppg = await this.prisma.sppg.findUnique({
      where: { id },
      include: {
        schools: { select: { id: true, name: true, level: true } },
        _count: { select: { users: true, schools: true } },
      },
    });
    if (!sppg) throw new NotFoundException('SPPG tidak ditemukan');
    return sppg;
  }

  async create(dto: CreateSppgDto) {
    return this.prisma.sppg.create({ data: dto });
  }

  async update(id: string, dto: UpdateSppgDto) {
    await this.findOne(id); // throws 404 if not found
    return this.prisma.sppg.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    const sppg = await this.prisma.sppg.findUnique({
      where: { id },
      include: { _count: { select: { users: true, schools: true } } },
    });
    if (!sppg) throw new NotFoundException('SPPG tidak ditemukan');

    if (sppg._count.users > 0) {
      throw new BadRequestException(
        `SPPG tidak dapat dihapus karena masih memiliki ${sppg._count.users} pengguna terdaftar. ` +
        `Pindahkan pengguna ke SPPG lain terlebih dahulu.`
      );
    }
    if (sppg._count.schools > 0) {
      throw new BadRequestException(
        `SPPG tidak dapat dihapus karena masih terhubung dengan ${sppg._count.schools} sekolah. ` +
        `Lepaskan sekolah dari SPPG terlebih dahulu.`
      );
    }

    await this.prisma.sppg.delete({ where: { id } });
    return { deleted: true, id };
  }

  // ── REGIONS SUMMARY ──────────────────────────────────────────────────────

  /**
   * GET /sppg/regions/summary
   * Mengembalikan semua wilayah yang memiliki SPPG, dikelompokkan per provinsi
   * kemudian per kabupaten/kota, beserta statistik agregat.
   */
  async getRegionsSummary() {
    // 1. Ambil semua SPPG beserta agregat user & sekolah
    const sppgs = await this.prisma.sppg.findMany({
      where: { isActive: true },
      include: {
        _count: { select: { users: true, schools: true } },
      },
    });

    // 2. Hitung jumlah scan per SPPG (via user → scanHistory)
    const scanCounts = await this.prisma.scanHistory.groupBy({
      by: ['userId'],
      _count: { id: true },
    });

    // Map userId → scanCount
    const userScanMap = new Map<string, number>();
    for (const s of scanCounts) {
      userScanMap.set(s.userId, s._count.id);
    }

    // 3. Ambil sppgId per userId
    const userSppgMap = await this.prisma.user.findMany({
      where: { sppgId: { not: null } },
      select: { id: true, sppgId: true },
    });

    // Map sppgId → totalScan
    const sppgScanMap = new Map<string, number>();
    for (const u of userSppgMap) {
      if (!u.sppgId) continue;
      const scans = userScanMap.get(u.id) ?? 0;
      sppgScanMap.set(u.sppgId, (sppgScanMap.get(u.sppgId) ?? 0) + scans);
    }

    // 4. Rata-rata rating makanan per SPPG (via user → foodRatings)
    const ratingByUser = await this.prisma.foodRating.groupBy({
      by: ['userId'],
      _avg: { rating: true },
    });
    const userRatingMap = new Map<string, number>();
    for (const r of ratingByUser) {
      if (r._avg.rating !== null) userRatingMap.set(r.userId, r._avg.rating);
    }

    const sppgRatingMap = new Map<string, number[]>();
    for (const u of userSppgMap) {
      if (!u.sppgId) continue;
      const avg = userRatingMap.get(u.id);
      if (avg !== undefined) {
        const arr = sppgRatingMap.get(u.sppgId) ?? [];
        arr.push(avg);
        sppgRatingMap.set(u.sppgId, arr);
      }
    }

    // 5. Distribusi status konsumsi per SPPG (via user → foodFeedbacks)
    const consumptionByUser = await this.prisma.foodFeedback.groupBy({
      by: ['userId', 'consumptionStatus'],
      _count: { id: true },
    });
    const sppgConsumptionMap = new Map<string, Record<string, number>>();
    for (const u of userSppgMap) {
      if (!u.sppgId) continue;
      const entries = consumptionByUser.filter((c) => c.userId === u.id);
      for (const e of entries) {
        const status = e.consumptionStatus ?? 'tidak_diketahui';
        const map = sppgConsumptionMap.get(u.sppgId) ?? {};
        map[status] = (map[status] ?? 0) + e._count.id;
        sppgConsumptionMap.set(u.sppgId, map);
      }
    }

    // 6. Susun hasil per provinsi → kabupaten → kecamatan → SPPG
    const provinsiMap = new Map<string, any>();

    for (const sppg of sppgs) {
      const ratings = sppgRatingMap.get(sppg.id) ?? [];
      const avgRating = ratings.length > 0
        ? ratings.reduce((a, b) => a + b, 0) / ratings.length
        : null;

      const sppgItem = {
        id: sppg.id,
        kode: sppg.kode,
        nama: sppg.nama,
        kecamatan: sppg.kecamatan,
        kelurahanDesa: sppg.kelurahanDesa,
        alamat: sppg.alamat,
        latitude: sppg.latitude,
        longitude: sppg.longitude,
        jumlahSekolah: sppg._count.schools,
        jumlahSiswaTerdaftar: sppg._count.users,
        jumlahScan: sppgScanMap.get(sppg.id) ?? 0,
        rataRataRating: avgRating ? +avgRating.toFixed(2) : null,
        distribusiKonsumsi: sppgConsumptionMap.get(sppg.id) ?? {},
      };

      // Provinsi
      if (!provinsiMap.has(sppg.provinsi)) {
        provinsiMap.set(sppg.provinsi, { provinsi: sppg.provinsi, kabupaten: new Map() });
      }
      const provEntry = provinsiMap.get(sppg.provinsi);

      // Kabupaten
      if (!provEntry.kabupaten.has(sppg.kabupatenKota)) {
        provEntry.kabupaten.set(sppg.kabupatenKota, {
          kabupatenKota: sppg.kabupatenKota,
          kecamatanMap: new Map(),
        });
      }
      const kabEntry = provEntry.kabupaten.get(sppg.kabupatenKota);

      // Kecamatan
      if (!kabEntry.kecamatanMap.has(sppg.kecamatan)) {
        kabEntry.kecamatanMap.set(sppg.kecamatan, { kecamatan: sppg.kecamatan, sppgList: [] });
      }
      kabEntry.kecamatanMap.get(sppg.kecamatan).sppgList.push(sppgItem);
    }

    // 7. Serialisasi Map → Array
    const result = Array.from(provinsiMap.values()).map((prov) => {
      const kabList = Array.from(prov.kabupaten.values()).map((kab: any) => {
        const kecList = Array.from(kab.kecamatanMap.values()).map((kec: any) => ({
          kecamatan: kec.kecamatan,
          sppgList: kec.sppgList,
          jumlahSppg: kec.sppgList.length,
        }));
        return {
          kabupatenKota: kab.kabupatenKota,
          kecamatanList: kecList,
          jumlahSppg: kecList.reduce((a: number, k: any) => a + k.jumlahSppg, 0),
          jumlahSekolah: kecList.reduce((a: number, k: any) =>
            a + k.sppgList.reduce((b: number, s: any) => b + s.jumlahSekolah, 0), 0),
          jumlahSiswaTerdaftar: kecList.reduce((a: number, k: any) =>
            a + k.sppgList.reduce((b: number, s: any) => b + s.jumlahSiswaTerdaftar, 0), 0),
        };
      });
      return {
        provinsi: prov.provinsi,
        kabupatenList: kabList,
        jumlahSppg: kabList.reduce((a: number, k: any) => a + k.jumlahSppg, 0),
        jumlahSekolah: kabList.reduce((a: number, k: any) => a + k.jumlahSekolah, 0),
        jumlahSiswaTerdaftar: kabList.reduce((a: number, k: any) => a + k.jumlahSiswaTerdaftar, 0),
      };
    });

    // Ringkasan global
    const totalSppg = sppgs.length;
    const totalProvinsi = provinsiMap.size;
    const totalKabupaten = result.reduce((a, p) => a + p.kabupatenList.length, 0);
    const totalSiswa = result.reduce((a, p) => a + p.jumlahSiswaTerdaftar, 0);

    return { summary: { totalSppg, totalProvinsi, totalKabupaten, totalSiswa }, wilayah: result };
  }

  /**
   * GET /sppg/regions/:provinsi
   * Detail per provinsi dengan hierarki lengkap.
   */
  async getProvinsiDetail(provinsi: string) {
    const sppgs = await this.prisma.sppg.findMany({
      where: {
        isActive: true,
        provinsi: { equals: provinsi, mode: 'insensitive' },
      },
      include: {
        _count: { select: { users: true, schools: true } },
        schools: { select: { id: true, name: true, level: true } },
      },
      orderBy: [{ kabupatenKota: 'asc' }, { kecamatan: 'asc' }, { nama: 'asc' }],
    });

    if (sppgs.length === 0) {
      throw new NotFoundException(`Tidak ada SPPG aktif di provinsi "${provinsi}"`);
    }

    return sppgs;
  }
}
