import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';

const prisma = new PrismaClient();

export class SppgController {

  /**
   * GET /api/v1/sppg/regions
   * Query params:
   *   level  = "provinsi" | "kabupaten" | "kecamatan"
   *   parent = nama wilayah parent (wajib jika level != provinsi)
   *
   * Endpoint publik — hanya mengembalikan nama wilayah yang memiliki SPPG aktif.
   */
  getRegions = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { level = 'provinsi', parent } = req.query as { level?: string; parent?: string };

      if (level === 'provinsi') {
        // Daftar provinsi yang memiliki ≥1 SPPG aktif
        const rows = await prisma.sppg.groupBy({
          by: ['provinsi'],
          where: { isActive: true },
          orderBy: { provinsi: 'asc' },
        });
        const data = rows.map((r) => r.provinsi);
        res.json(ApiResponse.success(data));
        return;
      }

      if (level === 'kabupaten') {
        if (!parent) {
          res.status(400).json(ApiResponse.error('Parameter parent (provinsi) wajib diisi', 400));
          return;
        }
        const rows = await prisma.sppg.groupBy({
          by: ['kabupatenKota'],
          where: { isActive: true, provinsi: parent },
          orderBy: { kabupatenKota: 'asc' },
        });
        const data = rows.map((r) => r.kabupatenKota);
        res.json(ApiResponse.success(data));
        return;
      }

      if (level === 'kecamatan') {
        if (!parent) {
          res.status(400).json(ApiResponse.error('Parameter parent (kabupatenKota) wajib diisi', 400));
          return;
        }
        const rows = await prisma.sppg.groupBy({
          by: ['kecamatan'],
          where: { isActive: true, kabupatenKota: parent },
          orderBy: { kecamatan: 'asc' },
        });
        const data = rows.map((r) => r.kecamatan);
        res.json(ApiResponse.success(data));
        return;
      }

      res.status(400).json(ApiResponse.error('level harus salah satu dari: provinsi, kabupaten, kecamatan', 400));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /api/v1/sppg
   * Query params: provinsi, kabupatenKota, kecamatan, search
   *
   * Endpoint publik — daftar SPPG aktif pada wilayah terpilih.
   * Tidak membocorkan data user.
   */
  findAll = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { provinsi, kabupatenKota, kecamatan, search } = req.query as Record<string, string | undefined>;

      const where: any = { isActive: true };
      if (provinsi) where.provinsi = provinsi;
      if (kabupatenKota) where.kabupatenKota = kabupatenKota;
      if (kecamatan) where.kecamatan = kecamatan;
      if (search) {
        where.OR = [
          { nama: { contains: search, mode: 'insensitive' } },
          { kode: { contains: search, mode: 'insensitive' } },
        ];
      }

      const sppgs = await prisma.sppg.findMany({
        where,
        select: {
          id: true,
          kode: true,
          nama: true,
          provinsi: true,
          kabupatenKota: true,
          kecamatan: true,
          kelurahanDesa: true,
          alamat: true,
          latitude: true,
          longitude: true,
        },
        orderBy: [{ provinsi: 'asc' }, { kabupatenKota: 'asc' }, { nama: 'asc' }],
      });

      res.json(ApiResponse.success(sppgs));
    } catch (error) {
      next(error);
    }
  };
}
