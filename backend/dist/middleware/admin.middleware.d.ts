import { Response, NextFunction } from 'express';
import { JwtRequest } from './auth.middleware';
export declare const adminMiddleware: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=admin.middleware.d.ts.map