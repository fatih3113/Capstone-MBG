"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FoodController = void 0;
const client_1 = require("@prisma/client");
const api_response_1 = require("../utils/api-response");
const prisma = new client_1.PrismaClient();
class FoodController {
    constructor() {
        /**
         * GET /foods — All foods
         */
        this.getAllFoods = async (req, res, next) => {
            try {
                const { category, search, page = '1', limit = '20' } = req.query;
                const where = { isActive: true };
                if (category)
                    where.category = category;
                if (search) {
                    where.name = { contains: search, mode: 'insensitive' };
                }
                const skip = (parseInt(page) - 1) * parseInt(limit);
                const [foods, total] = await Promise.all([
                    prisma.food.findMany({
                        where,
                        include: { nutrition: true },
                        skip,
                        take: parseInt(limit),
                        orderBy: { name: 'asc' },
                    }),
                    prisma.food.count({ where }),
                ]);
                res.json(api_response_1.ApiResponse.paginated(foods, total, parseInt(page), parseInt(limit)));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /foods/:id — Food detail
         */
        this.getFoodById = async (req, res, next) => {
            try {
                const food = await prisma.food.findUnique({
                    where: { id: req.params.id },
                    include: { nutrition: true },
                });
                if (!food) {
                    res.status(404).json(api_response_1.ApiResponse.error('Makanan tidak ditemukan', 404));
                    return;
                }
                res.json(api_response_1.ApiResponse.success(food));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /foods/search?q=query
         */
        this.searchFoods = async (req, res, next) => {
            try {
                const { q } = req.query;
                if (!q) {
                    res.status(400).json(api_response_1.ApiResponse.error('Query pencarian diperlukan', 400));
                    return;
                }
                const foods = await prisma.food.findMany({
                    where: {
                        isActive: true,
                        name: { contains: q, mode: 'insensitive' },
                    },
                    include: { nutrition: true },
                    take: 10,
                });
                res.json(api_response_1.ApiResponse.success(foods));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.FoodController = FoodController;
//# sourceMappingURL=food.controller.js.map