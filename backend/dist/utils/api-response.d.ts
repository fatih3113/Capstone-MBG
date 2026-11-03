export declare class ApiResponse {
    static success<T>(data: T, message?: string, statusCode?: number): {
        success: boolean;
        message: string;
        data: T;
        status_code: number;
    };
    static error(message: string, statusCode?: number): {
        success: boolean;
        message: string;
        status_code: number;
    };
    static paginated<T>(data: T[], total: number, currentPage: number, perPage: number): {
        success: boolean;
        message: string;
        data: T[];
        total: number;
        current_page: number;
        last_page: number;
        per_page: number;
    };
    static validationError(errors: any[]): {
        success: boolean;
        message: string;
        errors: {
            field: any;
            message: any;
        }[];
    };
}
//# sourceMappingURL=api-response.d.ts.map