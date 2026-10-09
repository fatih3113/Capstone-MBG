import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { validationResult } from 'express-validator';
import { PrismaClient } from '@prisma/client';
import { ApiResponse } from '../utils/api-response';
import { logger } from '../utils/logger';

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'mbg_nutrition_secret_key_change_in_production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

export class AuthController {

  /**
   * POST /auth/register
   */
  register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(422).json(ApiResponse.validationError(errors.array()));
        return;
      }

      const { name, email, password, school_id, class: className, gender, age } = req.body;

      // Check if email already exists
      const existingUser = await prisma.user.findUnique({ where: { email } });
      if (existingUser) {
        res.status(409).json(ApiResponse.error('Email sudah terdaftar', 409));
        return;
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 12);

      // Create user
      const user = await prisma.user.create({
        data: {
          name,
          email,
          passwordHash,
          schoolId: school_id,
          class_: className,
          gender,
          age: age ? parseInt(age) : null,
        },
        select: {
          id: true, name: true, email: true,
          class_: true, gender: true, age: true,
          schoolLevel: true, createdAt: true,
        },
      });

      logger.info(`New user registered: ${email}`);
      res.status(201).json(ApiResponse.success(user, 'Registrasi berhasil'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * POST /auth/login
   */
  login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(422).json(ApiResponse.validationError(errors.array()));
        return;
      }

      const { email, password } = req.body;

      // Find user
      const user = await prisma.user.findUnique({
        where: { email },
        include: { school: { select: { name: true } } },
      });

      if (!user) {
        res.status(401).json(ApiResponse.error('Email atau password salah', 401));
        return;
      }

      // Verify password
      const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
      if (!isPasswordValid) {
        res.status(401).json(ApiResponse.error('Email atau password salah', 401));
        return;
      }

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, email: user.email },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN } as jwt.SignOptions
      );

      const userData = {
        id: user.id,
        name: user.name,
        email: user.email,
        school_name: user.school?.name,
        class: user.class_,
        gender: user.gender,
        age: user.age,
        school_level: user.schoolLevel,
      };

      logger.info(`User logged in: ${email}`);
      res.json(ApiResponse.success({ token, user: userData }, 'Login berhasil'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * POST /auth/logout
   */
  logout = async (_req: Request, res: Response): Promise<void> => {
    // JWT is stateless; client should delete the token
    // For production, implement token blacklisting with Redis
    res.json(ApiResponse.success(null, 'Logout berhasil'));
  };

  /**
   * POST /auth/forgot-password
   */
  forgotPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { email } = req.body;
      const user = await prisma.user.findUnique({ where: { email } });

      // Always return success to prevent email enumeration
      if (user) {
        // TODO: Send password reset email via mail service (e.g., Nodemailer + SendGrid)
        logger.info(`Password reset requested for: ${email}`);
      }

      res.json(ApiResponse.success(null,
        'Jika email terdaftar, link reset password akan dikirim'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * POST /auth/reset-password
   */
  resetPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { token, new_password } = req.body;
      // TODO: Verify reset token and update password
      res.json(ApiResponse.success(null, 'Password berhasil diubah'));
    } catch (error) {
      next(error);
    }
  };
}
