import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class StatsController {
    /**
     * GET /stats/daily — Statistik gizi hari ini
     */
    getDailyStats: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /stats/weekly — Statistik gizi 7 hari terakhir (Data Warehouse)
     */
    getWeeklyStats: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /stats/top-foods — Makanan paling sering dikonsumsi (Data Warehouse)
     */
    getTopFoods: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /stats/summary — Ringkasan statistik lengkap user
     */
    getSummary: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=stats.controller.d.ts.map