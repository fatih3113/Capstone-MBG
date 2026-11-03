import { Request, Response, NextFunction } from 'express';
export interface JwtRequest extends Request {
    userId?: string;
    userEmail?: string;
}
export declare const authMiddleware: (req: JwtRequest, res: Response, next: NextFunction) => void;
//# sourceMappingURL=auth.middleware.d.ts.map