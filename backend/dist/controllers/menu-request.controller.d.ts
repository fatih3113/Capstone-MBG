import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare class MenuRequestController {
    /**
     * POST /reports/menu-requests
     * Siswa mengusulkan menu baru
     */
    create: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/menu-requests/my
     * Siswa melihat riwayat usulan sendiri
     */
    listMine: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/menu-requests (admin only)
     * Admin melihat semua usulan, dengan filter status & search
     */
    listAll: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * PATCH /reports/menu-requests/:id/status (admin only)
     * Admin mengubah status + catatan usulan
     */
    updateStatus: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/menu-requests/grouped (admin only)
     * Mengelompokkan usulan menu yang sama/mirip
     */
    groupedSummary: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /reports/menu-requests/export?startDate=&endDate= (admin only)
     * Ekspor CSV permintaan menu
     */
    exportCsv: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=menu-request.controller.d.ts.map