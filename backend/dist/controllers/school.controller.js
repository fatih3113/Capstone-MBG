"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SchoolController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
class SchoolController {
    constructor() {
        /**
         * GET /schools — Semua sekolah (public, tidak butuh auth)
         */
        this.getAllSchools = async (_req, res, next) => {
            try {
                const schools = await prisma.school.findMany({
                    orderBy: { name: 'asc' },
                });
                res.json(api_response_1.ApiResponse.success(schools));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /schools/:id — Detail sekolah
         */
        this.getSchoolById = async (req, res, next) => {
            try {
                const school = await prisma.school.findUnique({
                    where: { id: req.params.id },
                    include: {
                        _count: { select: { users: true, mbgMenus: true } },
                    },
                });
                if (!school) {
                    res.status(404).json(api_response_1.ApiResponse.error('Sekolah tidak ditemukan', 404));
                    return;
                }
                res.json(api_response_1.ApiResponse.success(school));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /schools?level=SD&city=Jakarta&sppg_id=... — Filter sekolah berdasarkan level/kota/SPPG
         */
        this.getSchoolsFiltered = async (req, res, next) => {
            try {
                const { level, city, search, sppg_id } = req.query;
                const schools = await prisma.school.findMany({
                    where: {
                        ...(level && { level: level }),
                        // Sekolah milik SPPG tsb + sekolah yang belum ditautkan ke SPPG mana pun,
                        // supaya register tidak buntu bila admin belum mengisi SPPG di Data Sekolah.
                        ...(sppg_id && {
                            OR: [{ sppgId: sppg_id }, { sppgId: null }],
                        }),
                        ...(city && { city: city }),
                        ...(search && {
                            name: { contains: search, mode: 'insensitive' },
                        }),
                    },
                    orderBy: { name: 'asc' },
                });
                res.json(api_response_1.ApiResponse.success(schools));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.SchoolController = SchoolController;
//# sourceMappingURL=school.controller.js.map