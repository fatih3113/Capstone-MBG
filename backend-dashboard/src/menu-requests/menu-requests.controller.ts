import {
  Controller, Get, Patch, Body, Param, Query,
  UseGuards, Res, HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { MenuRequestsService } from './menu-requests.service';
import { UpdateStatusDto } from './dto/update-status.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';

@Controller('menu-requests')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class MenuRequestsController {
  constructor(private readonly service: MenuRequestsService) {}

  /** GET /api/v1/menu-requests?status=&search=&page=&limit=&startDate=&endDate= */
  @Get()
  async findAll(
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.service.findAll({
      status, search, startDate, endDate,
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
    });
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /api/v1/menu-requests/grouped */
  @Get('grouped')
  async grouped() {
    const data = await this.service.grouped();
    return { success: true, message: 'Berhasil', data };
  }

  /** GET /api/v1/menu-requests/export */
  @Get('export')
  async exportCsv(
    @Res() res: Response,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const csv = await this.service.exportCsv(startDate, endDate);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="menu_requests.csv"');
    res.status(HttpStatus.OK).send('\uFEFF' + csv); // BOM for Excel
  }

  /** PATCH /api/v1/menu-requests/:id/status */
  @Patch(':id/status')
  async updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateStatusDto,
  ) {
    const data = await this.service.updateStatus(id, dto);
    return { success: true, message: 'Status usulan berhasil diperbarui', data };
  }
}
