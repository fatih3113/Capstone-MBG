import { Request, Response, NextFunction } from 'express';
export declare class AuthController {
    /**
     * POST /auth/register
     */
    register: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * POST /auth/login
     */
    login: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * POST /auth/logout
     */
    logout: (_req: Request, res: Response) => Promise<void>;
    /**
     * POST /auth/forgot-password
     */
    forgotPassword: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * POST /auth/reset-password
     */
    resetPassword: (req: Request, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=auth.controller.d.ts.map