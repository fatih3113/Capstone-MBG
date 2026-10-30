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

@Controller('sppg')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class SppgController {
  constructor(private readonly svc: SppgService) {}

  /**
   * GET /sppg/regions/summary
   * Harus SEBELUM GET /sppg/regions/:provinsi agar NestJS tidak salah routing
   */
  @Get('regions/summary')
  async getRegionsSummary() {
    return { success: true, data: await this.svc.getRegionsSummary() };
  }

  @Get('regions/:provinsi')
  async getProvinsiDetail(@Param('provinsi') provinsi: string) {
    return { success: true, data: await this.svc.getProvinsiDetail(provinsi) };
  }

  @Get()
  async findAll(@Query() query: QuerySppgDto) {
    return { success: true, data: await this.svc.findAll(query) };
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return { success: true, data: await this.svc.findOne(id) };
  }

  @Post()
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
