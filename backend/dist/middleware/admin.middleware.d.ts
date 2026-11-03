import { Response, NextFunction } from 'express';
import { JwtRequest } from './auth.middleware';
/**
 * Middleware: Hanya role "admin" yang bisa mengakses endpoint yang dilindungi.
 * Harus dipasang SETELAH authMiddleware.
 */
export declare const adminMiddleware: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=admin.middleware.d.ts.map