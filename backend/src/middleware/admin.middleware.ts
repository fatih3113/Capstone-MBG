// Middleware Otorisasi Admin: memastikan pengguna yang login memiliki role 'admin' sebelum diizinkan mengakses data manajemen/dashboard MBG.

import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { JwtRequest } from './auth.middleware';

// Inisialisasi Prisma Client untuk mengecek data user di database.
const prisma = new PrismaClient();

// adminMiddleware: memverifikasi role akun pengguna di database; harus dipasang setelah authMiddleware.
export const adminMiddleware = async (
  req: JwtRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    // Mengambil data role dari database berdasarkan userId yang diekstrak oleh authMiddleware.
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
      select: { role: true },
    });

    // Menolak akses dengan HTTP 403 Forbidden jika akun tidak ditemukan atau bukan role pengelola (admin/SPPG).
    const allowedRoles = ['admin', 'BGN_ADMIN', 'SPPG_ADMIN'];
    if (!user || !allowedRoles.includes(user.role)) {
      res.status(403).json({
        success: false,
        message: 'Akses ditolak. Halaman ini hanya untuk admin pengelola MBG atau SPPG.',
      });
      return;
    }

    // Melanjutkan ke controller rute admin jika role terkonfirmasi valid.
    next();
  } catch (error) {
    // Menangani error jika terjadi gangguan koneksi database saat pengecekan role.
    res.status(500).json({ success: false, message: 'Gagal memverifikasi role pengguna.' });
  }
};
