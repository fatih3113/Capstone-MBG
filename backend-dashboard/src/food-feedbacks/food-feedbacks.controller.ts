import {
  Controller, Get, Query, UseGuards, Res, HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { FoodFeedbacksService } from './food-feedbacks.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';

@Controller('food-feedbacks')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class FoodFeedbacksController {
  constructor(private readonly service: FoodFeedbacksService) {}

  /** GET /api/v1/food-feedbacks/summary */
  @Get('summary')
  async summary(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const data = await this.service.getSummary(startDate, endDate);
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /api/v1/food-feedbacks */
  @Get()
  async findAll(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('foodName') foodName?: string,
    @Query('consumptionStatus') consumptionStatus?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.service.findAll({
      startDate, endDate, foodName, consumptionStatus,
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
    });
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /api/v1/food-feedbacks/export */
  @Get('export')
  async exportCsv(
    @Res() res: Response,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const csv = await this.service.exportCsv(startDate, endDate);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="food_feedbacks.csv"');
    res.status(HttpStatus.OK).send('\uFEFF' + csv);
  }
}
