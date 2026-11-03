import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class ScanHistoryController {
    /**
     * GET /scan-history — Get user scan history
     */
    getUserHistory: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /scan-history/:id — Scan detail
     */
    getScanDetail: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * POST /scan-history/save — Save scan result
     */
    saveScan: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=scan-history.controller.d.ts.map