import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../prisma/prisma.service';
import {
  ACCOUNT_ACTIVE,
  AuthUser,
  isDashboardRole,
  isSppgAdminRole,
  normalizeRole,
} from '../roles';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET_DASHBOARD,
    });
  }

  /**
   * Status akun dicek ulang ke database di SETIAP request, bukan hanya dipercaya
   * dari isi token. Jadi akun yang ditolak / SPPG yang disuspend langsung
   * kehilangan akses tanpa menunggu token kedaluwarsa.
   */
  async validate(payload: any): Promise<AuthUser> {
    if (!payload?.sub) {
      throw new UnauthorizedException('Token tidak valid');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        accountStatus: true,
        sppgId: true,
        sppg: {
          select: { verificationStatus: true, operationalStatus: true },
        },
      },
    });

    if (!user || !isDashboardRole(user.role)) {
      throw new UnauthorizedException('Token tidak valid');
    }
    if (user.accountStatus !== ACCOUNT_ACTIVE) {
      throw new UnauthorizedException('Akun tidak aktif');
    }
    if (isSppgAdminRole(user.role)) {
      if (
        !user.sppgId ||
        !user.sppg ||
        user.sppg.verificationStatus !== 'APPROVED' ||
        user.sppg.operationalStatus === 'SUSPENDED'
      ) {
        throw new UnauthorizedException('Akses SPPG tidak aktif');
      }
    }

    return {
      id: user.id,
      email: user.email,
      name: user.name,
      role: normalizeRole(user.role),
      sppgId: user.sppgId ?? null,
    };
  }
}
