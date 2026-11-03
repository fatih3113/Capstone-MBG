import { Response, NextFunction } from 'express';
import { JwtRequest } from '../middleware/auth.middleware';
export declare const uploadProfileImage: import("express").RequestHandler<import("express-serve-static-core").ParamsDictionary, any, any, import("qs").ParsedQs, Record<string, any>>;
export declare class UserController {
    /**
     * GET /users/profile — Profil user yang sedang login
     */
    getProfile: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * PUT /users/profile/update — Update profil user
     */
    updateProfile: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * POST /users/profile/photo — Upload foto profil
     */
    uploadPhoto: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
    /**
     * DELETE /users/profile — Hapus akun user
     */
    deleteAccount: (req: JwtRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=user.controller.d.ts.map