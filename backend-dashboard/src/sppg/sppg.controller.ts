import {
  Controller, Get, Post, Patch, Delete,
  Param, Query, Body, UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';
import { SppgService } from './sppg.service';
import { CreateSppgDto } from './dto/create-sppg.dto';
import { UpdateSppgDto } from './dto/update-sppg.dto';
import { QuerySppgDto } from './dto/query-sppg.dto';
import { UpdateSppgProfileDto } from './dto/update-sppg-profile.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AuthUser, ROLE_SUPER_ADMIN, sppgScope } from '../auth/roles';

@Controller('sppg')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class SppgController {
  constructor(private readonly svc: SppgService) {}

  /**
   * GET /sppg/regions/summary
   * Harus SEBELUM GET /sppg/regions/:provinsi agar NestJS tidak salah routing
   */
  @Get('regions/summary')
  async getRegionsSummary(@CurrentUser() user: AuthUser) {
    return { success: true, data: await this.svc.getRegionsSummary(sppgScope(user)) };
  }

  @Get('regions/:provinsi')
  async getProvinsiDetail(@CurrentUser() user: AuthUser, @Param('provinsi') provinsi: string) {
    return { success: true, data: await this.svc.getProvinsiDetail(provinsi, sppgScope(user)) };
  }

  /**
   * GET /sppg/me — profil SPPG milik Admin SPPG yang sedang login.
   * Harus SEBELUM GET /sppg/:id.
   */
  @Get('me')
  async getMine(@CurrentUser() user: AuthUser) {
    const sppgId = sppgScope(user);
    if (!sppgId) {
      return { success: false, message: 'Super Admin tidak memiliki SPPG tunggal. Gunakan daftar SPPG.' };
    }
    return { success: true, data: await this.svc.findOne(sppgId, sppgId) };
  }

  /**
   * PATCH /sppg/:id/profile — Admin SPPG mengubah data kontak SPPG-nya sendiri.
   * Super Admin juga boleh. Field dibatasi oleh UpdateSppgProfileDto.
   */
  @Patch(':id/profile')
  async updateProfile(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdateSppgProfileDto,
  ) {
    return {
      success: true,
      message: 'Profil SPPG berhasil diperbarui',
      data: await this.svc.updateProfile(id, dto, sppgScope(user)),
    };
  }

  @Get()
  async findAll(@CurrentUser() user: AuthUser, @Query() query: QuerySppgDto) {
    return { success: true, data: await this.svc.findAll(query, sppgScope(user)) };
  }

  @Get(':id')
  async findOne(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return { success: true, data: await this.svc.findOne(id, sppgScope(user)) };
  }

  @Post()
  @Roles(ROLE_SUPER_ADMIN)
  async create(@Body() dto: CreateSppgDto) {
    try {
      return {
        success: true,
        message: 'SPPG berhasil ditambahkan',
        data: await this.svc.create(dto),
      };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  @Patch(':id')
  @Roles(ROLE_SUPER_ADMIN)
  async update(@Param('id') id: string, @Body() dto: UpdateSppgDto) {
    try {
      return {
        success: true,
        message: 'SPPG berhasil diperbarui',
        data: await this.svc.update(id, dto),
      };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  @Delete(':id')
  @Roles(ROLE_SUPER_ADMIN)
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string) {
    try {
      return {
        success: true,
        message: 'SPPG berhasil dihapus',
        data: await this.svc.remove(id),
      };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }
}
