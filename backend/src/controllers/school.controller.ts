import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';

const prisma = new PrismaClient();

export class SchoolController {

  /**
   * GET /schools — Semua sekolah (public, tidak butuh auth)
   */
  getAllSchools = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const schools = await prisma.school.findMany({
        orderBy: { name: 'asc' },
      });
      res.json(ApiResponse.success(schools));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /schools/:id — Detail sekolah
   */
  getSchoolById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const school = await prisma.school.findUnique({
        where: { id: req.params.id },
        include: {
          _count: { select: { users: true, mbgMenus: true } },
        },
      });

      if (!school) {
        res.status(404).json(ApiResponse.error('Sekolah tidak ditemukan', 404));
        return;
      }

      res.json(ApiResponse.success(school));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /schools?level=SD&city=Jakarta — Filter sekolah berdasarkan level/kota
   */
  getSchoolsFiltered = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { level, city, search } = req.query;

      const schools = await prisma.school.findMany({
        where: {
          ...(level && { level: level as string }),
          ...(city && { city: city as string }),
          ...(search && {
            name: { contains: search as string, mode: 'insensitive' },
          }),
        },
        orderBy: { name: 'asc' },
      });

      res.json(ApiResponse.success(schools));
    } catch (error) {
      next(error);
    }
  };
}
