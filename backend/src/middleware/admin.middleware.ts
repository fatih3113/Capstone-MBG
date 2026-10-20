import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import { JwtRequest } from './auth.middleware';

const prisma = new PrismaClient();

/**
 * Middleware: Hanya role "admin" yang bisa mengakses endpoint yang dilindungi.
 * Harus dipasang SETELAH authMiddleware.
 */
export const adminMiddleware = async (
  req: JwtRequest,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
      select: { role: true },
    });

    if (!user || user.role !== 'admin') {
      res.status(403).json({
        success: false,
        message: 'Akses ditolak. Halaman ini hanya untuk admin pengelola MBG.',
      });
      return;
    }

    next();
  } catch (error) {
    res.status(500).json({ success: false, message: 'Gagal memverifikasi role pengguna.' });
  }
};
