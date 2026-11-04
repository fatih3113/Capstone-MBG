// Middleware Autentikasi JWT: memverifikasi token bearer pada setiap request terproteksi dan menyematkan data identitas user (userId & email) ke objek request.

import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

// Interface JwtRequest: memperluas Request bawaan Express agar controller bisa langsung membaca userId dan userEmail pengguna yang sedang login.
export interface JwtRequest extends Request {
  userId?: string;
  userEmail?: string;
}

// Kunci rahasia untuk memvalidasi keaslian tanda tangan token JWT (diambil dari variabel environment .env).
const JWT_SECRET = process.env.JWT_SECRET || 'mbg_nutrition_secret_key_change_in_production';

// authMiddleware: fungsi penjaga pintu yang memeriksa apakah klien menyertakan header token yang sah sebelum mengizinkan akses ke rute API.
export const authMiddleware = (
  req: JwtRequest,
  res: Response,
  next: NextFunction,
): void => {
  // Mengambil nilai header 'Authorization' yang dikirim oleh aplikasi Flutter atau web klien.
  const authHeader = req.headers.authorization;

  // Menolak request jika header Authorization tidak ada atau tidak berawalan format 'Bearer '.
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({
      success: false,
      message: 'Token autentikasi diperlukan',
    });
    return;
  }

  // Memisahkan kata 'Bearer' dan mengambil token JWT-nya saja.
  const token = authHeader.split(' ')[1];

  try {
    // Memverifikasi tanda tangan digital token dan masa berlakunya secara kriptografis menggunakan secret key.
    const decoded = jwt.verify(token, JWT_SECRET) as {
      userId: string;
      email: string;
    };
    // Menyimpan id dan email user ke objek req agar controller di urutan berikutnya tahu siapa yang membuat request.
    req.userId = decoded.userId;
    req.userEmail = decoded.email;
    next();
  } catch (error) {
    // Menangani kondisi saat token kedaluwarsa atau isi token tidak sah/rusak.
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({
        success: false,
        message: 'Token telah kadaluarsa. Silakan login kembali.',
      });
    } else {
      res.status(401).json({
        success: false,
        message: 'Token tidak valid.',
      });
    }
  }
};
