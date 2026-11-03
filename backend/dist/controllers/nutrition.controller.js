"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NutritionController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
class NutritionController {
    constructor() {
        /**
         * GET /nutrition?food_ids=id1,id2,...
         * Ambil data gizi untuk beberapa food sekaligus (dipakai oleh Flutter scan)
         */
        this.getNutritionByFoodIds = async (req, res, next) => {
            try {
                const { food_ids } = req.query;
                if (!food_ids) {
                    res.status(400).json(api_response_1.ApiResponse.error('Parameter food_ids wajib diisi', 400));
                    return;
                }
                const ids = food_ids.split(',').map((id) => id.trim()).filter(Boolean);
                const nutritions = await prisma.nutrition.findMany({
                    where: { foodId: { in: ids } },
                    include: { food: { select: { id: true, name: true, category: true } } },
                });
                res.json(api_response_1.ApiResponse.success(nutritions));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /nutrition/food/:foodId
         * Ambil data gizi berdasarkan foodId
         */
        this.getNutritionByFood = async (req, res, next) => {
            try {
                const nutrition = await prisma.nutrition.findUnique({
                    where: { foodId: req.params.foodId },
                    include: { food: true },
                });
                if (!nutrition) {
                    res.status(404).json(api_response_1.ApiResponse.error('Data gizi tidak ditemukan', 404));
                    return;
                }
                res.json(api_response_1.ApiResponse.success(nutrition));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /nutrition/daily?date=YYYY-MM-DD
         * Ambil agregat gizi harian user
         */
        this.getDailyNutrition = async (req, res, next) => {
            try {
                const userId = req.userId;
                const { date } = req.query;
                const targetDate = date ? new Date(date) : new Date();
                targetDate.setHours(0, 0, 0, 0);
                const data = await prisma.dailyNutrition.findUnique({
                    where: { userId_date: { userId, date: targetDate } },
                });
                res.json(api_response_1.ApiResponse.success(data));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /nutrition/weekly
         * Ambil data gizi 7 hari terakhir
         */
        this.getWeeklyNutrition = async (req, res, next) => {
            try {
                const userId = req.userId;
                const sevenDaysAgo = new Date();
                sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
                const data = await prisma.dailyNutrition.findMany({
                    where: { userId, date: { gte: sevenDaysAgo } },
                    orderBy: { date: 'asc' },
                });
                res.json(api_response_1.ApiResponse.success(data));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /nutrition/recommendation
         * Rekomendasi gizi berbasis rule-based (Pemrograman Sistem Cerdas)
         */
        this.getNutritionRecommendation = async (req, res, next) => {
            try {
                const userId = req.userId;
                // Ambil data user untuk kalkulasi kebutuhan
                const user = await prisma.user.findUnique({ where: { id: userId } });
                if (!user) {
                    res.status(404).json(api_response_1.ApiResponse.error('User tidak ditemukan', 404));
                    return;
                }
                // Rule-based recommendation berdasarkan usia dan jenis kelamin (Pemrograman Sistem Cerdas)
                const age = user.age ?? 12;
                const gender = user.gender ?? 'L';
                const schoolLevel = user.schoolLevel ?? 'SD';
                let caloriesTarget;
                let proteinTarget;
                let carbsTarget;
                let fatTarget;
                let fiberTarget;
                // Aturan berdasarkan AKG (Angka Kecukupan Gizi) Indonesia
                // Peserta Posyandu usia balita → AKG 2019 (Permenkes 28/2019), L & P sama.
                // Catatan: umur < 1 tahun ikut target 1-3 tahun.
                const isBalita = schoolLevel === 'Posyandu' && age <= 6;
                if (isBalita) {
                    if (age <= 3) {
                        // 1-3 tahun
                        caloriesTarget = 1350;
                        proteinTarget = 20;
                        carbsTarget = 215;
                        fatTarget = 45;
                        fiberTarget = 19;
                    }
                    else {
                        // 4-6 tahun
                        caloriesTarget = 1400;
                        proteinTarget = 25;
                        carbsTarget = 220;
                        fatTarget = 50;
                        fiberTarget = 20;
                    }
                }
                else if (schoolLevel === 'SD') {
                    caloriesTarget = gender === 'L' ? 1850 : 1750;
                    proteinTarget = gender === 'L' ? 49 : 45;
                    carbsTarget = gender === 'L' ? 265 : 250;
                    fatTarget = gender === 'L' ? 62 : 58;
                    fiberTarget = 22;
                }
                else if (schoolLevel === 'SMP') {
                    caloriesTarget = gender === 'L' ? 2200 : 2000;
                    proteinTarget = gender === 'L' ? 60 : 55;
                    carbsTarget = gender === 'L' ? 315 : 285;
                    fatTarget = gender === 'L' ? 73 : 67;
                    fiberTarget = 26;
                }
                else {
                    // SMA / SMK
                    caloriesTarget = gender === 'L' ? 2650 : 2100;
                    proteinTarget = gender === 'L' ? 75 : 59;
                    carbsTarget = gender === 'L' ? 375 : 300;
                    fatTarget = gender === 'L' ? 88 : 70;
                    fiberTarget = 30;
                }
                // Ambil data hari ini untuk membandingkan
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const todayData = await prisma.dailyNutrition.findUnique({
                    where: { userId_date: { userId, date: today } },
                });
                const consumed = {
                    calories: todayData?.totalCalories ?? 0,
                    protein: todayData?.totalProtein ?? 0,
                    carbs: todayData?.totalCarbs ?? 0,
                    fat: todayData?.totalFat ?? 0,
                    fiber: todayData?.totalFiber ?? 0,
                };
                // Hitung sisa kebutuhan
                const remaining = {
                    calories: Math.max(0, caloriesTarget - consumed.calories),
                    protein: Math.max(0, proteinTarget - consumed.protein),
                    carbs: Math.max(0, carbsTarget - consumed.carbs),
                    fat: Math.max(0, fatTarget - consumed.fat),
                    fiber: Math.max(0, fiberTarget - consumed.fiber),
                };
                // Status pencapaian
                const caloriesPct = (consumed.calories / caloriesTarget) * 100;
                let status;
                let message;
                if (caloriesPct < 60) {
                    status = 'kurang';
                    message = 'Asupan kalori hari ini masih kurang. Tambahkan makanan bergizi.';
                }
                else if (caloriesPct > 110) {
                    status = 'berlebih';
                    message = 'Asupan kalori sudah melebihi kebutuhan. Perbanyak sayur dan buah.';
                }
                else {
                    status = 'cukup';
                    message = 'Asupan gizi hari ini sudah cukup baik. Pertahankan!';
                }
                res.json(api_response_1.ApiResponse.success({
                    target: { caloriesTarget, proteinTarget, carbsTarget, fatTarget, fiberTarget },
                    consumed,
                    remaining,
                    status,
                    message,
                    percentage: Math.round(caloriesPct),
                }));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.NutritionController = NutritionController;
//# sourceMappingURL=nutrition.controller.js.map