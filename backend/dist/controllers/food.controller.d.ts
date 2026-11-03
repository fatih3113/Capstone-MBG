import { Request, Response, NextFunction } from 'express';
export declare class FoodController {
    /**
     * GET /foods — All foods
     */
    getAllFoods: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /foods/:id — Food detail
     */
    getFoodById: (req: Request, res: Response, next: NextFunction) => Promise<void>;
    /**
     * GET /foods/search?q=query
     */
    searchFoods: (req: Request, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=food.controller.d.ts.map