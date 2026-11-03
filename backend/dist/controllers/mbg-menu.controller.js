"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MbgMenuController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
/**
 * Tentukan filter sekolah untuk menu:
 *  1. Jika query ?school_id= diberikan → pakai itu.
 *  2. Jika tidak, pakai sekolah milik user (schoolId).
 *  3. Jika user hanya punya sppgId (hasil register) → semua sekolah di SPPG itu.
 *  4. Jika tidak ada sama sekali → tanpa filter (perilaku lama).
 */
async function buildSchoolFilter(req) {
    const { school_id } = req.query;
    if (school_id)
        return { schoolId: school_id };
    if (req.userId) {
        const me = await prisma.user.findUnique({
            where: { id: req.userId },
            select: { schoolId: true, sppgId: true },
        });
        if (me?.schoolId)
            return { schoolId: me.schoolId };
        if (me?.sppgId)
            return { school: { sppgId: me.sppgId } };
    }
    return {};
}
class MbgMenuController {
    constructor() {
        /**
         * GET /mbg-menu — Menu mingguan (Senin-Jumat) dari sekolah/SPPG user
         */
        this.getWeeklyMenu = async (req, res, next) => {
            try {
                const schoolFilter = await buildSchoolFilter(req); // ← BARU
                // Hitung awal minggu (Senin)
                const monday = new Date();
                monday.setDate(monday.getDate() - (monday.getDay() || 7) + 1);
                monday.setHours(0, 0, 0, 0);
                const friday = new Date(monday);
                friday.setDate(monday.getDate() + 4);
                friday.setHours(23, 59, 59, 999);
                const menus = await prisma.mbgMenu.findMany({
                    where: {
                        ...schoolFilter, // ← BARU (menggantikan ...(school_id && { schoolId }))
                        date: { gte: monday, lte: friday },
                    },
                    include: {
                        items: {
                            include: {
                                food: { include: { nutrition: true } },
                            },
                        },
                        school: true,
                    },
                    orderBy: { date: 'asc' },
                });
                res.json(api_response_1.ApiResponse.success(menus));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /mbg-menu/today — Menu hari ini
         */
        this.getTodayMenu = async (req, res, next) => {
            try {
                const schoolFilter = await buildSchoolFilter(req); // ← BARU
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const menu = await prisma.mbgMenu.findFirst({
                    where: {
                        ...schoolFilter, // ← BARU
                        date: today,
                    },
                    include: {
                        items: {
                            include: {
                                food: { include: { nutrition: true } },
                            },
                        },
                        school: true,
                    },
                });
                if (!menu) {
                    res.status(404).json(api_response_1.ApiResponse.error('Menu hari ini tidak tersedia', 404));
                    return;
                }
                res.json(api_response_1.ApiResponse.success(menu));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /mbg-menu/date/:date — Menu berdasarkan tanggal
         */
        this.getMenuByDate = async (req, res, next) => {
            try {
                const date = new Date(req.params.date);
                if (isNaN(date.getTime())) {
                    res.status(400).json(api_response_1.ApiResponse.error('Format tanggal tidak valid. Gunakan YYYY-MM-DD', 400));
                    return;
                }
                date.setHours(0, 0, 0, 0);
                const menu = await prisma.mbgMenu.findFirst({
                    where: { date },
                    include: {
                        items: {
                            include: {
                                food: { include: { nutrition: true } },
                            },
                        },
                        school: true,
                    },
                });
                if (!menu) {
                    res.status(404).json(api_response_1.ApiResponse.error('Menu untuk tanggal ini tidak ditemukan', 404));
                    return;
                }
                res.json(api_response_1.ApiResponse.success(menu));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.MbgMenuController = MbgMenuController;
//# sourceMappingURL=mbg-menu.controller.js.map