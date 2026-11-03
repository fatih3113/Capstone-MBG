"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MenuRequestController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
class MenuRequestController {
    constructor() {
        /**
         * POST /reports/menu-requests
         * Siswa mengusulkan menu baru
         */
        this.create = async (req, res, next) => {
            try {
                const { menuName, reason } = req.body;
                if (!menuName?.trim()) {
                    res.status(400).json(api_response_1.ApiResponse.error('Nama menu wajib diisi', 400));
                    return;
                }
                const record = await prisma.menuRequest.create({
                    data: {
                        userId: req.userId,
                        menuName: menuName.trim(),
                        reason: reason?.trim() ?? null,
                        status: 'received',
                    },
                });
                res.status(201).json(api_response_1.ApiResponse.success(record, 'Usulan menu berhasil dikirim'));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /reports/menu-requests/my
         * Siswa melihat riwayat usulan sendiri
         */
        this.listMine = async (req, res, next) => {
            try {
                const records = await prisma.menuRequest.findMany({
                    where: { userId: req.userId },
                    orderBy: { submittedAt: 'desc' },
                });
                res.json(api_response_1.ApiResponse.success(records));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /reports/menu-requests (admin only)
         * Admin melihat semua usulan, dengan filter status & search
         */
        this.listAll = async (req, res, next) => {
            try {
                const { status, search, page = '1', limit = '20' } = req.query;
                const skip = (parseInt(page) - 1) * parseInt(limit);
                const where = {};
                if (status)
                    where.status = status;
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
                res.json(api_response_1.ApiResponse.success({ records, total, page: parseInt(page), limit: parseInt(limit) }));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * PATCH /reports/menu-requests/:id/status (admin only)
         * Admin mengubah status + catatan usulan
         */
        this.updateStatus = async (req, res, next) => {
            try {
                const { status, adminNote } = req.body;
                const validStatuses = ['received', 'reviewing', 'considered', 'approved', 'rejected'];
                if (!validStatuses.includes(status)) {
                    res.status(400).json(api_response_1.ApiResponse.error('Status tidak valid', 400));
                    return;
                }
                const record = await prisma.menuRequest.findUnique({ where: { id: req.params.id } });
                if (!record) {
                    res.status(404).json(api_response_1.ApiResponse.error('Usulan tidak ditemukan', 404));
                    return;
                }
                const updated = await prisma.menuRequest.update({
                    where: { id: req.params.id },
                    data: { status, adminNote: adminNote?.trim() ?? record.adminNote },
                });
                res.json(api_response_1.ApiResponse.success(updated, 'Status usulan diperbarui'));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /reports/menu-requests/grouped (admin only)
         * Mengelompokkan usulan menu yang sama/mirip
         */
        this.groupedSummary = async (req, res, next) => {
            try {
                const grouped = await prisma.menuRequest.groupBy({
                    by: ['menuName'],
                    _count: { id: true },
                    orderBy: { _count: { id: 'desc' } },
                    take: 20,
                });
                res.json(api_response_1.ApiResponse.success(grouped));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /reports/menu-requests/export?startDate=&endDate= (admin only)
         * Ekspor CSV permintaan menu
         */
        this.exportCsv = async (req, res, next) => {
            try {
                const { startDate, endDate } = req.query;
                const where = {};
                if (startDate)
                    where.submittedAt = { ...where.submittedAt, gte: new Date(startDate) };
                if (endDate)
                    where.submittedAt = { ...where.submittedAt, lte: new Date(endDate) };
                const records = await prisma.menuRequest.findMany({
                    where,
                    include: { user: { select: { name: true, email: true, schoolLevel: true } } },
                    orderBy: { submittedAt: 'desc' },
                });
                const header = 'Tanggal,Nama Pengguna,Email,Jenjang,Menu Diusulkan,Alasan,Status,Catatan Admin\n';
                const rows = records.map((r) => [
                    r.submittedAt.toISOString(),
                    `"${r.user.name}"`,
                    r.user.email,
                    r.user.schoolLevel ?? '',
                    `"${r.menuName}"`,
                    `"${r.reason ?? ''}"`,
                    r.status,
                    `"${r.adminNote ?? ''}"`,
                ].join(','));
                res.setHeader('Content-Type', 'text/csv; charset=utf-8');
                res.setHeader('Content-Disposition', 'attachment; filename="menu_requests.csv"');
                res.send('\uFEFF' + header + rows.join('\n'));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.MenuRequestController = MenuRequestController;
//# sourceMappingURL=menu-request.controller.js.map