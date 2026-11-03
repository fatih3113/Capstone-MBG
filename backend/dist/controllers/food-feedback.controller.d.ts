import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class FoodFeedbackController {
    /**
     * POST /reports/food-feedbacks
     * Siswa mengirim feedback makanan dan status konsumsi
     */
    create: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-feedbacks/my
     * Siswa melihat feedback yang pernah dikirim
     */
    listMine: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-feedbacks (admin only)
     * Admin melihat semua feedback dengan filter
     */
    listAll: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-feedbacks/summary (admin only)
     * Ringkasan: distribusi rating, konsumsi, makanan positif/negatif
     */
    summary: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/food-feedbacks/export (admin only)
     */
    exportCsv: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=food-feedback.controller.d.ts.map