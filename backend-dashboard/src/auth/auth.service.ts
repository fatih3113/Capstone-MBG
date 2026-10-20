import {
  Injectable,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async login(dto: LoginDto) {
    // Cari user berdasarkan email
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Email atau password salah');
    }

    // Verifikasi password
    const isMatch = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Email atau password salah');
    }

    // Hanya admin yang boleh login ke dashboard
    if (user.role !== 'admin') {
      throw new ForbiddenException(
        'Akses ditolak. Akun ini bukan admin pengelola MBG. ' +
        'Dashboard ini hanya dapat diakses oleh admin.',
      );
    }

    // Buat JWT token dengan secret dashboard (terpisah dari Flutter)
    const payload = {
      sub: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    };

    const token = this.jwtService.sign(payload);

    return {
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        schoolLevel: true,
        createdAt: true,
      },
    });

    if (!user || user.role !== 'admin') {
      throw new ForbiddenException('Akses ditolak');
    }

    return user;
  }
}
