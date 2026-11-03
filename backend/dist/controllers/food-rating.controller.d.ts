import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class FoodRatingController {
    /**
     * POST /reports/food-ratings
     * Siswa memberikan rating makanan favorit (1-5)
     */
    create: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-ratings/my
     * Siswa melihat rating yang pernah diberikan
     */
    listMine: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-ratings/ranking
     * Ranking makanan favorit: jumlah suara + rata-rata rating
     * Accessible: both student (summary) and admin (full)
     */
    ranking: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-ratings (admin only)
     * Semua data rating dengan filter
     */
    listAll: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-ratings/export (admin only)
     */
    exportCsv: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=food-rating.controller.d.ts.map