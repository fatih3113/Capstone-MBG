import {
  Controller, Get, Query, UseGuards, Res, HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { FoodRatingsService } from './food-ratings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';

@Controller('food-ratings')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class FoodRatingsController {
  constructor(private readonly service: FoodRatingsService) {}

  /** GET /api/v1/food-ratings/ranking */
  @Get('ranking')
  async ranking(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.service.getRanking(startDate, endDate, limit ? +limit : 10);
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /api/v1/food-ratings */
  @Get()
  async findAll(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('foodName') foodName?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.service.findAll({
      startDate, endDate, foodName,
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
    });
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /api/v1/food-ratings/export */
  @Get('export')
  async exportCsv(
    @Res() res: Response,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const csv = await this.service.exportCsv(startDate, endDate);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="food_ratings.csv"');
    res.status(HttpStatus.OK).send('\uFEFF' + csv);
  }
}
