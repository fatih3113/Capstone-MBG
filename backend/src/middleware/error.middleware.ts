// Middleware Penanganan Error Global: menangkap seluruh error tak terduga, mencatatnya ke logger sistem, dan mengembalikan respon JSON yang rapi kepada klien.

import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

// Interface AppError: mendefinisikan objek error kustom dengan atribut status kode HTTP dan penanda error operasional.
export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

// errorHandler: penangkap error tingkat aplikasi Express agar server tidak pernah mati (crash) jika terjadi exception.
export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  _next: NextFunction,
): void => {
  // Menentukan status kode (default 500 Internal Server Error jika tidak dispesifikasikan).
  const statusCode = err.statusCode || 500;
  // Menampilkan pesan error asli hanya jika bertipe operasional, atau pesan ramah jika internal server error.
  const message = err.isOperational
    ? err.message
    : 'Terjadi kesalahan pada server. Silakan coba lagi.';

  // Mencatat rincian error, endpoint yang bermasalah, dan stack trace ke logger Winston.
  logger.error(`[${req.method}] ${req.path} - ${err.message}`, {
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

// createError: fungsi pembantu untuk membuat objek AppError dengan status code tertentu secara cepat.
export const createError = (message: string, statusCode: number): AppError => {
  const error: AppError = new Error(message);
  error.statusCode = statusCode;
  error.isOperational = true;
  return error;
};
