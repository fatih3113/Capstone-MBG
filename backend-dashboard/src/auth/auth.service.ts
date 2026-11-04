import {
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Prisma } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterSppgDto } from './dto/register-sppg.dto';
import {
  ACCOUNT_ACTIVE,
  ACCOUNT_PENDING,
  AuthUser,
  isDashboardRole,
  isSppgAdminRole,
  normalizeRole,
  ROLE_SPPG_ADMIN,
} from './roles';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  // ── LOGIN ────────────────────────────────────────────────────────────────

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findFirst({
      where: { email: { equals: dto.email.trim(), mode: 'insensitive' } },
      include: { sppg: true },
    });

    // Pesan sama untuk email salah / password salah (tidak membocorkan email terdaftar)
    if (!user) {
      throw new UnauthorizedException('Email atau password salah');
    }
    const isMatch = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Email atau password salah');
    }

    // Hanya Super Admin & Admin SPPG yang boleh login ke dashboard
    if (!isDashboardRole(user.role)) {
      throw new ForbiddenException(
        'Akses ditolak. Akun ini bukan pengelola MBG. ' +
          'Dashboard ini hanya dapat diakses oleh admin.',
      );
    }

    // Admin SPPG: akun harus sudah di-ACC Super Admin
    if (isSppgAdminRole(user.role)) {
      if (user.accountStatus === ACCOUNT_PENDING) {
        throw new ForbiddenException(
          'Pendaftaran akun Anda masih menunggu persetujuan Super Admin. ' +
            'Silakan coba login kembali setelah akun disetujui.',
        );
      }
      if (user.accountStatus !== ACCOUNT_ACTIVE) {
        const reason = user.sppg?.rejectionReason
          ? ` Alasan: ${user.sppg.rejectionReason}`
          : '';
        throw new ForbiddenException(`Pendaftaran akun Anda ditolak.${reason}`);
      }
      if (!user.sppg || user.sppg.verificationStatus !== 'APPROVED') {
        throw new ForbiddenException('SPPG Anda belum diverifikasi oleh Super Admin.');
      }
      if (user.sppg.operationalStatus === 'SUSPENDED') {
        const reason = user.sppg.suspensionReason
          ? ` Alasan: ${user.sppg.suspensionReason}`
          : '';
        throw new ForbiddenException(
          `SPPG Anda sedang dihentikan sementara.${reason}`,
        );
      }
    } else if (user.accountStatus !== ACCOUNT_ACTIVE) {
      throw new ForbiddenException('Akun tidak aktif.');
    }

    const role = normalizeRole(user.role);
    const token = this.jwtService.sign({
      sub: user.id,
      email: user.email,
      name: user.name,
      role,
      sppgId: user.sppgId ?? null,
    });

    return {
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role,
        sppgId: user.sppgId ?? null,
        sppgName: user.sppg?.nama ?? null,
      },
    };
  }

  // ── REGISTER ADMIN SPPG ──────────────────────────────────────────────────

  /**
   * Membuat SPPG (PENDING) + akun admin SPPG (PENDING) dalam satu operasi.
   * Keduanya baru aktif setelah Super Admin menyetujui.
   */
  async registerSppg(dto: RegisterSppgDto) {
    const email = dto.email.trim().toLowerCase();

    const existing = await this.prisma.user.findFirst({
      where: { email: { equals: email, mode: 'insensitive' } },
      select: { id: true },
    });
    if (existing) {
      throw new ConflictException('Email sudah terdaftar. Gunakan email lain.');
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);

    try {
      await this.prisma.user.create({
        data: {
          name: dto.name.trim(),
          email,
          passwordHash,
          role: ROLE_SPPG_ADMIN,        // dipaksa server, bukan dari request
          accountStatus: ACCOUNT_PENDING,
          sppg: {
            create: {
              nama: dto.sppgNama.trim(),
              provinsi: dto.provinsi.trim(),
              kabupatenKota: dto.kabupatenKota.trim(),
              kecamatan: dto.kecamatan.trim(),
              kelurahanDesa: dto.kelurahanDesa.trim(),
              alamat: dto.alamat?.trim() || null,
              penanggungjawab: dto.penanggungJawab.trim(),
              kontak: dto.kontak.trim(),
              kapasitasPorsi: dto.kapasitasPorsi ?? null,
              is3t: dto.is3t ?? false,
              isActive: false,
              verificationStatus: 'PENDING',
              operationalStatus: 'INACTIVE',
            },
          },
        },
      });
    } catch (err) {
      // Race condition: dua pendaftaran dengan email yang sama bersamaan
      if (
        err instanceof Prisma.PrismaClientKnownRequestError &&
        err.code === 'P2002'
      ) {
        throw new ConflictException('Email sudah terdaftar. Gunakan email lain.');
      }
      throw err;
    }

    return {
      message:
        'Pendaftaran berhasil dikirim. Akun Anda akan aktif setelah disetujui Super Admin.',
    };
  }

  // ── PROFIL ───────────────────────────────────────────────────────────────

  async getProfile(authUser: AuthUser) {
    const user = await this.prisma.user.findUnique({
      where: { id: authUser.id },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        schoolLevel: true,
        createdAt: true,
        sppgId: true,
        sppg: { select: { id: true, nama: true, kode: true } },
      },
    });

    if (!user || !isDashboardRole(user.role)) {
      throw new ForbiddenException('Akses ditolak');
    }
    return { ...user, role: normalizeRole(user.role) };
  }
}
