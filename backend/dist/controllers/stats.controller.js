"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.StatsController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
class StatsController {
    constructor() {
        /**
         * GET /stats/daily — Statistik gizi hari ini
         */
        this.getDailyStats = async (req, res, next) => {
            try {
                const userId = req.userId;
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const data = await prisma.dailyNutrition.findUnique({
                    where: { userId_date: { userId, date: today } },
                });
                res.json(api_response_1.ApiResponse.success(data ?? null));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /stats/weekly — Statistik gizi 7 hari terakhir (Data Warehouse)
         */
        this.getWeeklyStats = async (req, res, next) => {
            try {
                const userId = req.userId;
                const sevenDaysAgo = new Date();
                sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
                const data = await prisma.dailyNutrition.findMany({
                    where: { userId, date: { gte: sevenDaysAgo } },
                    orderBy: { date: 'asc' },
                });
                // Agregat ringkasan mingguan (Data Warehouse pattern)
                const summary = {
                    avgCalories: data.length > 0
                        ? data.reduce((sum, d) => sum + d.totalCalories, 0) / data.length
                        : 0,
                    avgProtein: data.length > 0
                        ? data.reduce((sum, d) => sum + d.totalProtein, 0) / data.length
                        : 0,
                    totalScans: data.reduce((sum, d) => sum + d.totalScans, 0),
                    daysLogged: data.length,
                };
                res.json(api_response_1.ApiResponse.success({ daily: data, summary }));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /stats/top-foods — Makanan paling sering dikonsumsi (Data Warehouse)
         */
        this.getTopFoods = async (req, res, next) => {
            try {
                const userId = req.userId;
                const limit = parseInt(req.query.limit) || 5;
                const topFoods = await prisma.prediction.groupBy({
                    by: ['foodId'],
                    where: { scan: { userId } },
                    _count: { foodId: true },
                    orderBy: { _count: { foodId: 'desc' } },
                    take: limit,
                });
                const foodIds = topFoods.map((f) => f.foodId);
                const foods = await prisma.food.findMany({
                    where: { id: { in: foodIds } },
                    include: { nutrition: true },
                });
                const result = topFoods.map((f) => ({
                    food: foods.find((fd) => fd.id === f.foodId),
                    count: f._count.foodId,
                }));
                res.json(api_response_1.ApiResponse.success(result));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /stats/summary — Ringkasan statistik lengkap user
         */
        this.getSummary = async (req, res, next) => {
            try {
                const userId = req.userId;
                const [totalScans, weeklyData] = await Promise.all([
                    prisma.scanHistory.count({ where: { userId } }),
                    prisma.dailyNutrition.findMany({
                        where: {
                            userId,
                            date: {
                                gte: new Date(new Date().setDate(new Date().getDate() - 7)),
                            },
                        },
                        orderBy: { date: 'asc' },
                    }),
                ]);
                const avgCalories = weeklyData.length > 0
                    ? weeklyData.reduce((sum, d) => sum + d.totalCalories, 0) / weeklyData.length
                    : 0;
                res.json(api_response_1.ApiResponse.success({
                    totalScans,
                    weeklyAvgCalories: Math.round(avgCalories),
                    daysLogged: weeklyData.length,
                    lastScan: weeklyData.length > 0 ? weeklyData[weeklyData.length - 1].date : null,
                }));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.StatsController = StatsController;
//# sourceMappingURL=stats.controller.js.map