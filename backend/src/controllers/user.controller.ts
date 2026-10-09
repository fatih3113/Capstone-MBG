import { Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import multer from 'multer';
import path from 'path';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';

const prisma = new PrismaClient();

// Multer config untuk upload profile picture
const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, 'uploads/profiles/'),
  filename: (req: JwtRequest, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `profile_${req.userId}_${Date.now()}${ext}`);
  },
});
export const uploadProfileImage = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (_, file, cb) => {
    const allowed = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    cb(null, allowed.includes(file.mimetype));
  },
}).single('profile_image');

export class UserController {

  /**
   * GET /users/profile — Profil user yang sedang login
   */
  getProfile = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user = await prisma.user.findUnique({
        where: { id: req.userId },
        select: {
          id: true, name: true, email: true, class_: true,
          gender: true, age: true, schoolLevel: true,
          profileImageUrl: true, schoolId: true, createdAt: true, updatedAt: true,
          school: { select: { id: true, name: true, level: true, city: true, address: true } },
        },
      });

      if (!user) {
        res.status(404).json(ApiResponse.error('User tidak ditemukan', 404));
        return;
      }

      res.json(ApiResponse.success(user));
    } catch (error) {
      next(error);
    }
  };

  /**
   * PUT /users/profile/update — Update profil user
   */
  updateProfile = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { name, class: className, gender, age, school_level, school_id } = req.body;

      const user = await prisma.user.update({
        where: { id: req.userId },
        data: {
          ...(name && { name }),
          ...(className !== undefined && { class_: className }),
          ...(gender && { gender }),
          ...(age !== undefined && { age: parseInt(age) }),
          ...(school_level && { schoolLevel: school_level }),
          ...(school_id && { schoolId: school_id }),
        },
        select: {
          id: true, name: true, email: true, class_: true,
          gender: true, age: true, schoolLevel: true,
          profileImageUrl: true, schoolId: true, createdAt: true, updatedAt: true,
        },
      });

      res.json(ApiResponse.success(user, 'Profil berhasil diperbarui'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * POST /users/profile/photo — Upload foto profil
   */
  uploadPhoto = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.file) {
        res.status(400).json(ApiResponse.error('Tidak ada file yang diunggah', 400));
        return;
      }

      const imageUrl = `/uploads/profiles/${req.file.filename}`;

      const user = await prisma.user.update({
        where: { id: req.userId },
        data: { profileImageUrl: imageUrl },
        select: {
          id: true, name: true, email: true, class_: true,
          gender: true, age: true, schoolLevel: true,
          profileImageUrl: true, schoolId: true, createdAt: true, updatedAt: true,
        },
      });

      res.json(ApiResponse.success({ profile_image_url: imageUrl, user }, 'Foto profil berhasil diperbarui'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * DELETE /users/profile — Hapus akun user
   */
  deleteAccount = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      await prisma.user.delete({ where: { id: req.userId } });
      res.json(ApiResponse.success(null, 'Akun berhasil dihapus'));
    } catch (error) {
      next(error);
    }
  };
}
