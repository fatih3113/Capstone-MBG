import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AuthUser, ROLE_SUPER_ADMIN } from '../auth/roles';
import { SppgVerificationService } from './sppg-verification.service';
import { RejectApplicationDto } from './dto/reject-application.dto';

/** Verifikasi pendaftaran akun SPPG — HANYA Super Admin. */
@Controller('sppg-verification')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
@Roles(ROLE_SUPER_ADMIN)
export class SppgVerificationController {
  constructor(private readonly svc: SppgVerificationService) {}

  /** GET /sppg-verification?status=PENDING|ACTIVE|REJECTED|ALL&search=&page=&limit= */
  @Get()
  async list(
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.svc.list({
      status,
      search,
      page: Math.max(1, +(page ?? 1) || 1),
      limit: Math.min(100, Math.max(1, +(limit ?? 15) || 15)),
    });
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /sppg-verification/pending-count — harus SEBELUM route ber-parameter */
  @Get('pending-count')
  async pendingCount() {
    return { success: true, message: 'Berhasil', data: await this.svc.pendingCount() };
  }

  /** PATCH /sppg-verification/:id/approve  (id = user id pendaftar) */
  @Patch(':id/approve')
  async approve(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    const data = await this.svc.approve(id, user.id);
    return { success: true, message: 'Akun SPPG berhasil disetujui', data };
  }

  /** PATCH /sppg-verification/:id/reject  body: { reason } */
  @Patch(':id/reject')
  async reject(
    @Param('id') id: string,
    @Body() dto: RejectApplicationDto,
    @CurrentUser() user: AuthUser,
  ) {
    const data = await this.svc.reject(id, dto.reason, user.id);
    return { success: true, message: 'Pendaftaran akun SPPG ditolak', data };
  }
}
