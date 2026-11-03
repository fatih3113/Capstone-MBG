import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class NutritionController {
    /**
     * GET /nutrition?food_ids=id1,id2,...
     * Ambil data gizi untuk beberapa food sekaligus (dipakai oleh Flutter scan)
     */
    getNutritionByFoodIds: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /nutrition/food/:foodId
     * Ambil data gizi berdasarkan foodId
     */
    getNutritionByFood: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /nutrition/daily?date=YYYY-MM-DD
     * Ambil agregat gizi harian user
     */
    getDailyNutrition: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /nutrition/weekly
     * Ambil data gizi 7 hari terakhir
     */
    getWeeklyNutrition: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /nutrition/recommendation
     * Rekomendasi gizi berbasis rule-based (Pemrograman Sistem Cerdas)
     */
    getNutritionRecommendation: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=nutrition.controller.d.ts.map