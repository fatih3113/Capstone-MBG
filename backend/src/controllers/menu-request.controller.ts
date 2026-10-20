import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

export class MenuRequestController {

  /**
   * POST /reports/menu-requests
   * Siswa mengusulkan menu baru
   */
  create = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { menuName, reason } = req.body;
      if (!menuName?.trim()) {
        res.status(400).json(ApiResponse.error('Nama menu wajib diisi', 400));
        return;
      }

      const record = await prisma.menuRequest.create({
        data: {
          userId: req.userId!,
          menuName: menuName.trim(),
          reason: reason?.trim() ?? null,
          status: 'received',
        },
      });

      res.status(201).json(ApiResponse.success(record, 'Usulan menu berhasil dikirim'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/menu-requests/my
   * Siswa melihat riwayat usulan sendiri
   */
  listMine = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const records = await prisma.menuRequest.findMany({
        where: { userId: req.userId! },
        orderBy: { submittedAt: 'desc' },
      });
      res.json(ApiResponse.success(records));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/menu-requests (admin only)
   * Admin melihat semua usulan, dengan filter status & search
   */
  listAll = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { status, search, page = '1', limit = '20' } = req.query as Record<string, string>;
      const skip = (parseInt(page) - 1) * parseInt(limit);

      const where: any = {};
      if (status) where.status = status;
      if (search) {
        where.OR = [
          { menuName: { contains: search, mode: 'insensitive' } },
          { reason: { contains: search, mode: 'insensitive' } },
        ];
      }

      const [records, total] = await Promise.all([
        prisma.menuRequest.findMany({
          where,
          include: {
            user: { select: { id: true, name: true, email: true, schoolLevel: true } },
          },
          orderBy: { submittedAt: 'desc' },
          skip,
          take: parseInt(limit),
        }),
        prisma.menuRequest.count({ where }),
      ]);

      res.json(ApiResponse.success({ records, total, page: parseInt(page), limit: parseInt(limit) }));
    } catch (error) {
      next(error);
    }
  };

  /**
   * PATCH /reports/menu-requests/:id/status (admin only)
   * Admin mengubah status + catatan usulan
   */
  updateStatus = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { status, adminNote } = req.body;
      const validStatuses = ['received', 'reviewing', 'considered', 'approved', 'rejected'];
      if (!validStatuses.includes(status)) {
        res.status(400).json(ApiResponse.error('Status tidak valid', 400));
        return;
      }

      const record = await prisma.menuRequest.findUnique({ where: { id: req.params.id } });
      if (!record) {
        res.status(404).json(ApiResponse.error('Usulan tidak ditemukan', 404));
        return;
      }

      const updated = await prisma.menuRequest.update({
        where: { id: req.params.id },
        data: { status, adminNote: adminNote?.trim() ?? record.adminNote },
      });

      res.json(ApiResponse.success(updated, 'Status usulan diperbarui'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/menu-requests/grouped (admin only)
   * Mengelompokkan usulan menu yang sama/mirip
   */
  groupedSummary = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const grouped = await prisma.menuRequest.groupBy({
        by: ['menuName'],
        _count: { id: true },
        orderBy: { _count: { id: 'desc' } },
        take: 20,
      });
      res.json(ApiResponse.success(grouped));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /reports/menu-requests/export?startDate=&endDate= (admin only)
   * Ekspor CSV permintaan menu
   */
  exportCsv = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { startDate, endDate } = req.query as Record<string, string>;
      const where: any = {};
      if (startDate) where.submittedAt = { ...where.submittedAt, gte: new Date(startDate) };
      if (endDate) where.submittedAt = { ...where.submittedAt, lte: new Date(endDate) };

      const records = await prisma.menuRequest.findMany({
        where,
        include: { user: { select: { name: true, email: true, schoolLevel: true } } },
        orderBy: { submittedAt: 'desc' },
      });

      const header = 'Tanggal,Nama Pengguna,Email,Jenjang,Menu Diusulkan,Alasan,Status,Catatan Admin\n';
      const rows = records.map((r) =>
        [
          r.submittedAt.toISOString(),
          `"${r.user.name}"`,
          r.user.email,
          r.user.schoolLevel ?? '',
          `"${r.menuName}"`,
          `"${r.reason ?? ''}"`,
          r.status,
          `"${r.adminNote ?? ''}"`,
        ].join(',')
      );

      res.setHeader('Content-Type', 'text/csv; charset=utf-8');
      res.setHeader('Content-Disposition', 'attachment; filename="menu_requests.csv"');
      res.send('\uFEFF' + header + rows.join('\n'));
    } catch (error) {
      next(error);
    }
  };
}
