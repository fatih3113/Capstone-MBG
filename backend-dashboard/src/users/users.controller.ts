import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminRoleGuard } from '../auth/guards/admin-role.guard';
import { UsersService } from './users.service';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AuthUser, sppgScope } from '../auth/roles';

/** Data pengguna aplikasi mobile (role "student"). Hanya untuk admin. */
@Controller('users')
@UseGuards(JwtAuthGuard, AdminRoleGuard)
export class UsersController {
  constructor(private readonly svc: UsersService) {}

  @Get('summary')
  async summary(@CurrentUser() user: AuthUser, @Query('type') type?: string) {
    return { success: true, data: await this.svc.summary(type, sppgScope(user)) };
  }

  @Get()
  async findAll(
    @CurrentUser() user: AuthUser,
    @Query('search') search?: string,
    @Query('level') level?: string,
    @Query('gender') gender?: string,
    @Query('allergy') allergy?: string, // ada | tidak | belum
    @Query('schoolId') schoolId?: string,
    @Query('type') type?: string,       // sekolah | posyandu
    @Query('page') page = 1,
    @Query('limit') limit = 15,
  ) {
    return {
      success: true,
      data: await this.svc.findAll({
        search, level, gender, allergy, schoolId, type,
        page: Math.max(1, +page || 1),
        limit: Math.min(100, Math.max(1, +limit || 15)),
      }, sppgScope(user)),
    };
  }
}