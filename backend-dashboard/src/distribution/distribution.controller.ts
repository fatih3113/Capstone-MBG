import {
  Controller, Get, Post, Put, Delete,
  Param, Query, Body, Res, UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';
import { DistributionService } from './distribution.service';

@Controller('distribution')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class DistributionController {
  constructor(private readonly svc: DistributionService) {}

  /** GET /distribution/summary */
  @Get('summary')
  async summary(@Query('startDate') s?: string, @Query('endDate') e?: string) {
    return { success: true, message: 'Berhasil', data: await this.svc.getSummary(s, e) };
  }

  /** GET /distribution/per-school */
  @Get('per-school')
  async perSchool(@Query('startDate') s?: string, @Query('endDate') e?: string) {
    return { success: true, message: 'Berhasil', data: await this.svc.getPerSchool(s, e) };
  }

  /** GET /distribution/timeline */
  @Get('timeline')
  async timeline(
    @Query('startDate') s?: string, @Query('endDate') e?: string,
    @Query('page') page = 1, @Query('limit') limit = 30,
  ) {
    return { success: true, message: 'Berhasil', data: await this.svc.getTimeline(s, e, +page, +limit) };
  }

  /** GET /distribution/export */
  @Get('export')
  async exportCsv(@Query('startDate') s: string, @Query('endDate') e: string, @Res() res: Response) {
    const csv = await this.svc.exportCsv(s, e);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="distribusi_mbg.csv"');
    res.send('\uFEFF' + csv);
  }

  // ─── Helpers untuk form ────────────────────────────────────────────────────

  /** GET /distribution/schools — daftar sekolah untuk dropdown */
  @Get('schools')
  async schools() {
    return { success: true, message: 'Berhasil', data: await this.svc.getSchools() };
  }

  /** GET /distribution/foods — daftar makanan untuk dropdown */
  @Get('foods')
  async foods() {
    return { success: true, message: 'Berhasil', data: await this.svc.getFoods() };
  }

  // ─── CRUD Jadwal ──────────────────────────────────────────────────────────

  /** POST /distribution/schedule — buat jadwal baru */
  @Post('schedule')
  async create(@Body() body: {
    schoolId: string;
    date: string;
    items: { foodId: string; portionGram: number }[];
  }) {
    try {
      const data = await this.svc.createSchedule(body);
      return { success: true, message: 'Jadwal berhasil dibuat', data };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  /** PUT /distribution/schedule/:id — edit jadwal */
  @Put('schedule/:id')
  async update(
    @Param('id') id: string,
    @Body() body: {
      schoolId?: string;
      date?: string;
      items?: { foodId: string; portionGram: number }[];
    },
  ) {
    try {
      const data = await this.svc.updateSchedule(id, body);
      return { success: true, message: 'Jadwal berhasil diperbarui', data };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  /** DELETE /distribution/schedule/:id — hapus jadwal */
  @Delete('schedule/:id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string) {
    try {
      const data = await this.svc.deleteSchedule(id);
      return { success: true, message: 'Jadwal berhasil dihapus', data };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }
}

