import {
  Controller, Get, Post, Put, Delete,
  Param, Query, Body, UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';
import { SchoolsService } from './schools.service';

@Controller('schools')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class SchoolsController {
  constructor(private readonly svc: SchoolsService) {}

  @Get()
  async findAll(
    @Query('search') search?: string,
    @Query('level') level?: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return { success: true, data: await this.svc.findAll({ search, level, page: +page, limit: +limit }) };
  }

  @Post()
  async create(@Body() body: { name: string; level: string; address?: string; city?: string }) {
    try {
      return { success: true, message: 'Sekolah berhasil ditambahkan', data: await this.svc.create(body) };
    } catch (err: any) { return { success: false, message: err.message }; }
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    try {
      return { success: true, message: 'Sekolah berhasil diperbarui', data: await this.svc.update(id, body) };
    } catch (err: any) { return { success: false, message: err.message }; }
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string) {
    try {
      return { success: true, message: 'Sekolah berhasil dihapus', data: await this.svc.delete(id) };
    } catch (err: any) { return { success: false, message: err.message }; }
  }
}
