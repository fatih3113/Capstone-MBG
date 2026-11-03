"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ApiResponse = void 0;
class ApiResponse {
    static success(data, message = 'Berhasil', statusCode = 200) {
        return { success: true, message, data, status_code: statusCode };
    }
    static error(message, statusCode = 400) {
        return { success: false, message, status_code: statusCode };
    }
    static paginated(data, total, currentPage, perPage) {
        return {
            success: true,
            message: 'Berhasil',
            data,
            total,
            current_page: currentPage,
            last_page: Math.ceil(total / perPage),
            per_page: perPage,
        };
    }
    static validationError(errors) {
        return {
            success: false,
            message: 'Validasi gagal',
            errors: errors.map((e) => ({ field: e.path, message: e.msg })),
        };
    }
}
exports.ApiResponse = ApiResponse;
//# sourceMappingURL=api-response.js.map