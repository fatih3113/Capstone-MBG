"use strict";
// Middleware Penanganan Error Global: menangkap seluruh error tak terduga, mencatatnya ke logger sistem, dan mengembalikan respon JSON yang rapi kepada klien.
Object.defineProperty(exports, "__esModule", { value: true });
exports.createError = exports.errorHandler = void 0;
const logger_1 = require("../utils/logger");
// errorHandler: penangkap error tingkat aplikasi Express agar server tidak pernah mati (crash) jika terjadi exception.
const errorHandler = (err, req, res, _next) => {
    // Menentukan status kode (default 500 Internal Server Error jika tidak dispesifikasikan).
    const statusCode = err.statusCode || 500;
    // Menampilkan pesan error asli hanya jika bertipe operasional, atau pesan ramah jika internal server error.
    const message = err.isOperational
        ? err.message
        : 'Terjadi kesalahan pada server. Silakan coba lagi.';
    // Mencatat rincian error, endpoint yang bermasalah, dan stack trace ke logger Winston.
    logger_1.logger.error(`[${req.method}] ${req.path} - ${err.message}`, {
        statusCode,
        stack: err.stack,
    });
    // Mengirimkan respon error terformat JSON, menyertakan stack trace hanya pada mode development.
    res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};
exports.errorHandler = errorHandler;
// createError: fungsi pembantu untuk membuat objek AppError dengan status code tertentu secara cepat.
const createError = (message, statusCode) => {
    const error = new Error(message);
    error.statusCode = statusCode;
    error.isOperational = true;
    return error;
};
exports.createError = createError;
//# sourceMappingURL=error.middleware.js.map