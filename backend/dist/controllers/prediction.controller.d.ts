import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare const uploadScanImage: import("express").RequestHandler<import("express-serve-static-core").ParamsDictionary, any, any, import("qs").ParsedQs, Record<string, any>>;
export declare class PredictionController {
    /**
     * POST /predictions/classify
     * Klasifikasi gambar makanan.
     * Strategi (Strategy Pattern):
     *   1. Jika ML_SERVICE_URL di-set → forward ke Python/TensorFlow microservice
     *   2. Fallback ke mock predictions (development/testing)
     */
    classifyImage: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /predictions/:id — Detail prediksi
     */
    getPredictionById: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /predictions/scan/:scanId — Semua prediksi dari satu scan
     */
    getPredictionsByScan: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=prediction.controller.d.ts.map