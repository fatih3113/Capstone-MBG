import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';

const prisma = new PrismaClient();

export class FoodController {

  /**
   * GET /foods — All foods
   */
  getAllFoods = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { category, search, page = '1', limit = '20' } = req.query;

      const where: any = { isActive: true };
      if (category) where.category = category;
      if (search) {
        where.name = { contains: search as string, mode: 'insensitive' };
      }

      const skip = (parseInt(page as string) - 1) * parseInt(limit as string);
      const [foods, total] = await Promise.all([
        prisma.food.findMany({
          where,
          include: { nutrition: true },
          skip,
          take: parseInt(limit as string),
          orderBy: { name: 'asc' },
        }),
        prisma.food.count({ where }),
      ]);

      res.json(ApiResponse.paginated(foods, total,
        parseInt(page as string), parseInt(limit as string)));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /foods/:id — Food detail
   */
  getFoodById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const food = await prisma.food.findUnique({
        where: { id: req.params.id },
        include: { nutrition: true },
      });

      if (!food) {
        res.status(404).json(ApiResponse.error('Makanan tidak ditemukan', 404));
        return;
      }

      res.json(ApiResponse.success(food));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /foods/search?q=query
   */
  searchFoods = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { q } = req.query;
      if (!q) {
        res.status(400).json(ApiResponse.error('Query pencarian diperlukan', 400));
        return;
      }

      const foods = await prisma.food.findMany({
        where: {
          isActive: true,
          name: { contains: q as string, mode: 'insensitive' },
        },
        include: { nutrition: true },
        take: 10,
      });

      res.json(ApiResponse.success(foods));
    } catch (error) {
      next(error);
    }
  };
}
