import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  ACCOUNT_ACTIVE,
  ACCOUNT_PENDING,
  ACCOUNT_REJECTED,
  ROLE_SPPG_ADMIN,
} from '../auth/roles';

const SELECT = {
  id: true,
  name: true,
  email: true,
  accountStatus: true,
  createdAt: true,
  sppg: {
    select: {
      id: true,
      kode: true,
      nama: true,
      provinsi: true,
      kabupatenKota: true,
      kecamatan: true,
      kelurahanDesa: true,
      alamat: true,
      penanggungjawab: true,
      kontak: true,
      kapasitasPorsi: true,
      is3t: true,
      verificationStatus: true,
      rejectionReason: true,
      verifiedAt: true,
    },
  },
} as const;

@Injectable()
export class SppgVerificationService {
  constructor(private readonly prisma: PrismaService) {}

  /** Daftar pendaftaran akun Admin SPPG. status: PENDING | ACTIVE | REJECTED | ALL */
  async list(params: {
    status?: string;
    search?: string;
    page: number;
    limit: number;
  }) {
    const { status = ACCOUNT_PENDING, search, page, limit } = params;

    const where: any = { role: ROLE_SPPG_ADMIN };
    if (status && status !== 'ALL') where.accountStatus = status;
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { sppg: { nama: { contains: search, mode: 'insensitive' } } },
        { sppg: { kabupatenKota: { contains: search, mode: 'insensitive' } } },
      ];
    }

    const [records, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: SELECT,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.user.count({ where }),
    ]);

    return { records, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  /** Jumlah pendaftaran yang menunggu persetujuan (untuk badge sidebar). */
  async pendingCount() {
    const count = await this.prisma.user.count({
      where: { role: ROLE_SPPG_ADMIN, accountStatus: ACCOUNT_PENDING },
    });
    return { count };
  }

  /** Setujui: aktifkan akun admin + SPPG-nya sekaligus. */
  async approve(userId: string, verifierId: string) {
    const applicant = await this.findApplicant(userId);
    const now = new Date();

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: applicant.id },
        data: { accountStatus: ACCOUNT_ACTIVE },
      }),
      ...(applicant.sppgId
        ? [
            this.prisma.sppg.update({
              where: { id: applicant.sppgId },
              data: {
                verificationStatus: 'APPROVED',
                operationalStatus: 'ACTIVE',
                isActive: true,
                rejectionReason: null,
                verifiedBy: verifierId,
                verifiedAt: now,
              },
            }),
          ]
        : []),
    ]);

    return this.prisma.user.findUnique({ where: { id: applicant.id }, select: SELECT });
  }

  /** Tolak dengan alasan wajib. Akun tidak bisa login, alasan tampil saat login. */
  async reject(userId: string, reason: string, verifierId: string) {
    const applicant = await this.findApplicant(userId);
    const now = new Date();

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: applicant.id },
        data: { accountStatus: ACCOUNT_REJECTED },
      }),
      ...(applicant.sppgId
        ? [
            this.prisma.sppg.update({
              where: { id: applicant.sppgId },
              data: {
                verificationStatus: 'REJECTED',
                operationalStatus: 'INACTIVE',
                isActive: false,
                rejectionReason: reason.trim(),
                verifiedBy: verifierId,
                verifiedAt: now,
              },
            }),
          ]
        : []),
    ]);

    return this.prisma.user.findUnique({ where: { id: applicant.id }, select: SELECT });
  }

  private async findApplicant(userId: string) {
    const applicant = await this.prisma.user.findFirst({
      where: { id: userId, role: ROLE_SPPG_ADMIN },
      select: { id: true, sppgId: true },
    });
    if (!applicant) {
      throw new NotFoundException('Pendaftaran akun SPPG tidak ditemukan');
    }
    return applicant;
  }
}
