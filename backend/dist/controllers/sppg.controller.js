"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SppgController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
class SppgController {
    constructor() {
        /**
         * GET /api/v1/sppg/regions
         * Query params:
         *   level  = "provinsi" | "kabupaten" | "kecamatan"
         *   parent = nama wilayah parent (wajib jika level != provinsi)
         *
         * Endpoint publik — hanya mengembalikan nama wilayah yang memiliki SPPG aktif.
         */
        this.getRegions = async (req, res, next) => {
            try {
                const { level = 'provinsi', parent } = req.query;
                if (level === 'provinsi') {
                    // Daftar provinsi yang memiliki ≥1 SPPG aktif
                    const rows = await prisma.sppg.groupBy({
                        by: ['provinsi'],
                        where: { isActive: true },
                        orderBy: { provinsi: 'asc' },
                    });
                    const data = rows.map((r) => r.provinsi);
                    res.json(api_response_1.ApiResponse.success(data));
                    return;
                }
                if (level === 'kabupaten') {
                    if (!parent) {
                        res.status(400).json(api_response_1.ApiResponse.error('Parameter parent (provinsi) wajib diisi', 400));
                        return;
                    }
                    const rows = await prisma.sppg.groupBy({
                        by: ['kabupatenKota'],
                        where: { isActive: true, provinsi: parent },
                        orderBy: { kabupatenKota: 'asc' },
                    });
                    const data = rows.map((r) => r.kabupatenKota);
                    res.json(api_response_1.ApiResponse.success(data));
                    return;
                }
                if (level === 'kecamatan') {
                    if (!parent) {
                        res.status(400).json(api_response_1.ApiResponse.error('Parameter parent (kabupatenKota) wajib diisi', 400));
                        return;
                    }
                    const rows = await prisma.sppg.groupBy({
                        by: ['kecamatan'],
                        where: { isActive: true, kabupatenKota: parent },
                        orderBy: { kecamatan: 'asc' },
                    });
                    const data = rows.map((r) => r.kecamatan);
                    res.json(api_response_1.ApiResponse.success(data));
                    return;
                }
                res.status(400).json(api_response_1.ApiResponse.error('level harus salah satu dari: provinsi, kabupaten, kecamatan', 400));
            }
            catch (error) {
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
        this.findAll = async (req, res, next) => {
            try {
                const { provinsi, kabupatenKota, kecamatan, search } = req.query;
                const where = { isActive: true };
                if (provinsi)
                    where.provinsi = provinsi;
                if (kabupatenKota)
                    where.kabupatenKota = kabupatenKota;
                if (kecamatan)
                    where.kecamatan = kecamatan;
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
                res.json(api_response_1.ApiResponse.success(sppgs));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /api/v1/sppg/by-code/:kode
         * Endpoint publik untuk validasi kode SPPG saat registrasi bertahap di aplikasi mobile.
         * Hanya mengembalikan SPPG yang:
         *   - verificationStatus === 'APPROVED'
         *   - operationalStatus === 'ACTIVE'
         *   - isActive === true
         */
        this.findByCode = async (req, res, next) => {
            try {
                const rawKode = (req.params.kode || '').trim().toUpperCase();
                if (!rawKode) {
                    res.status(404).json(api_response_1.ApiResponse.error('Kode SPPG tidak ditemukan atau belum aktif', 404));
                    return;
                }
                const sppg = await prisma.sppg.findFirst({
                    where: {
                        kode: { equals: rawKode, mode: 'insensitive' },
                        verificationStatus: 'APPROVED',
                        operationalStatus: 'ACTIVE',
                        isActive: true,
                    },
                    select: {
                        id: true,
                        kode: true,
                        nama: true,
                        provinsi: true,
                        kabupatenKota: true,
                        kecamatan: true,
                        kelurahanDesa: true,
                    },
                });
                if (!sppg) {
                    res.status(404).json(api_response_1.ApiResponse.error('Kode SPPG tidak ditemukan atau belum aktif', 404));
                    return;
                }
                res.json(api_response_1.ApiResponse.success({
                    id: sppg.id,
                    kode: sppg.kode,
                    nama: sppg.nama,
                    provinsi: sppg.provinsi,
                    kabupaten_kota: sppg.kabupatenKota,
                    kabupatenKota: sppg.kabupatenKota,
                    kecamatan: sppg.kecamatan,
                    kelurahan_desa: sppg.kelurahanDesa,
                    kelurahanDesa: sppg.kelurahanDesa,
                }));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.SppgController = SppgController;
//# sourceMappingURL=sppg.controller.js.map