import { Request, Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class MbgMenuController {
    /**
     * GET /mbg-menu — Menu mingguan (Senin-Jumat) dari sekolah/SPPG user
     */
    getWeeklyMenu: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /mbg-menu/today — Menu hari ini
     */
    getTodayMenu: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /mbg-menu/date/:date — Menu berdasarkan tanggal
     */
    getMenuByDate: (req: Request, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=mbg-menu.controller.d.ts.map