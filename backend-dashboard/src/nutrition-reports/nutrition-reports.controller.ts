import {
  Controller, Get, Query, UseGuards, Res, HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { NutritionReportsService } from './nutrition-reports.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';

@Controller('nutrition-reports')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class NutritionReportsController {
  constructor(private readonly service: NutritionReportsService) {}

  /** GET /api/v1/nutrition-reports/stats */
  @Get('stats')
  async stats(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const data = await this.service.getAggregateStats(startDate, endDate);
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /api/v1/nutrition-reports/export */
  @Get('export')
  async exportCsv(
    @Res() res: Response,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const csv = await this.service.exportCsv(startDate, endDate);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="nutrition_reports.csv"');
    res.status(HttpStatus.OK).send('\uFEFF' + csv);
  }

  /** GET /api/v1/nutrition-reports */
  @Get()
  async findAll(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('akgTarget') akgTarget?: string,
    @Query('schoolLevel') schoolLevel?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.service.findAll({
      startDate, endDate, akgTarget, schoolLevel,
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
    });
    return { success: true, message: 'Berhasil', data };
  }
}
