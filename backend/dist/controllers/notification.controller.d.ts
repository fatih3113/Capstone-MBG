import { Request, Response, NextFunction } from 'express';
export declare class NotificationController {
    list: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * PATCH /notifications/:id/read
     */
    markRead: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * PATCH /notifications/read-all
     */
    markAllRead: (req: Request, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=notification.controller.d.ts.map