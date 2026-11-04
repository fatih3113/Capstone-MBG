import {
  Controller, Get, Post, Put, Delete,
  Param, Query, Body, UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AuthUser, sppgScope } from '../auth/roles';
import { SchoolsService } from './schools.service';

@Controller('schools')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class SchoolsController {
  constructor(private readonly svc: SchoolsService) {}

  @Get()
  async findAll(
    @CurrentUser() user: AuthUser,
    @Query('search') search?: string,
    @Query('level') level?: string,
    @Query('type') type?: string, // sekolah | posyandu
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return {
      success: true,
      data: await this.svc.findAll({ search, level, type, page: +page, limit: +limit }, sppgScope(user)),
    };
  }

  @Post()
  async create(
    @CurrentUser() user: AuthUser,
    @Body() body: { name: string; level: string; address?: string; city?: string; sppgId?: string },
  ) {
    try {
      return { success: true, message: 'Lembaga berhasil ditambahkan', data: await this.svc.create(body, sppgScope(user)) };
    } catch (err: any) { return { success: false, message: err.message }; }
  }

  @Put(':id')
  async update(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() body: any) {
    try {
      return { success: true, message: 'Lembaga berhasil diperbarui', data: await this.svc.update(id, body, sppgScope(user)) };
    } catch (err: any) { return { success: false, message: err.message }; }
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    try {
      return { success: true, message: 'Lembaga berhasil dihapus', data: await this.svc.delete(id, sppgScope(user)) };
    } catch (err: any) { return { success: false, message: err.message }; }
  }
}