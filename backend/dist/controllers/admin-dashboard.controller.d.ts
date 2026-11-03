import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class AdminDashboardController {
    /**
     * GET /admin/dashboard
     * Ringkasan semua data untuk dashboard admin
     */
    overview: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /admin/nutrition-reports
     * Laporan hasil scan gizi dengan filter
     */
    nutritionReports: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /admin/nutrition-reports/export (admin only)
     */
    exportNutritionCsv: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=admin-dashboard.controller.d.ts.map