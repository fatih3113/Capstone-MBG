import {
  Controller, Get, Post, Put, Delete, Patch,
  Param, Query, Body, UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';
import { FoodsService } from './foods.service';

@Controller('foods')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class FoodsController {
  constructor(private readonly svc: FoodsService) {}

  /** GET /foods/categories */
  @Get('categories')
  categories() {
    return { success: true, data: this.svc.getCategories() };
  }

  /** GET /foods?category=&search=&isActive=&page=&limit= */
  @Get()
  async findAll(
    @Query('category') category?: string,
    @Query('search') search?: string,
    @Query('isActive') isActive?: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return {
      success: true, message: 'Berhasil',
      data: await this.svc.findAll({ category, search, isActive, page: +page, limit: +limit }),
    };
  }

  /** GET /foods/:id */
  @Get(':id')
  async findOne(@Param('id') id: string) {
    try {
      return { success: true, data: await this.svc.findOne(id) };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  /** POST /foods */
  @Post()
  async create(@Body() body: any) {
    try {
      return { success: true, message: 'Makanan berhasil ditambahkan', data: await this.svc.create(body) };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  /** PUT /foods/:id */
  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    try {
      return { success: true, message: 'Makanan berhasil diperbarui', data: await this.svc.update(id, body) };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  /** PATCH /foods/:id/toggle — aktif / nonaktif */
  @Patch(':id/toggle')
  async toggle(@Param('id') id: string) {
    try {
      return { success: true, message: 'Status berhasil diubah', data: await this.svc.toggleActive(id) };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }

  /** DELETE /foods/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string) {
    try {
      return { success: true, message: 'Makanan berhasil dihapus', data: await this.svc.delete(id) };
    } catch (err: any) {
      return { success: false, message: err.message };
    }
  }
}
