import { Request, Response, NextFunction } from 'express';
export declare class SppgController {
    /**
     * GET /api/v1/sppg/regions
     * Query params:
     *   level  = "provinsi" | "kabupaten" | "kecamatan"
     *   parent = nama wilayah parent (wajib jika level != provinsi)
     *
     * Endpoint publik — hanya mengembalikan nama wilayah yang memiliki SPPG aktif.
     */
    getRegions: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /api/v1/sppg
     * Query params: provinsi, kabupatenKota, kecamatan, search
     *
     * Endpoint publik — daftar SPPG aktif pada wilayah terpilih.
     * Tidak membocorkan data user.
     */
    findAll: (req: Request, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=sppg.controller.d.ts.map