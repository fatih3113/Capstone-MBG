import { Request, Response, NextFunction } from 'express';
export declare class SchoolController {
    /**
     * GET /schools — Semua sekolah (public, tidak butuh auth)
     */
    getAllSchools: (_req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /schools/:id — Detail sekolah
     */
    getSchoolById: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /schools?level=SD&city=Jakarta&sppg_id=... — Filter sekolah berdasarkan level/kota/SPPG
     */
    getSchoolsFiltered: (req: Request, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=school.controller.d.ts.map