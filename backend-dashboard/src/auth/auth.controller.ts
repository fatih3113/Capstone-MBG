import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterSppgDto } from './dto/register-sppg.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AdminRoleGuard } from './guards/admin-role.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { AuthUser } from './roles';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /api/v1/auth/login
   * Login dashboard (Super Admin & Admin SPPG). Dibatasi 10x / 15 menit per IP.
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 10, ttl: 15 * 60 * 1000 } })
  async login(@Body() dto: LoginDto) {
    const result = await this.authService.login(dto);
    return {
      success: true,
      message: 'Login berhasil',
      data: result,
    };
  }

  /**
   * POST /api/v1/auth/register-sppg
   * Pendaftaran akun Admin SPPG Daerah (publik). Status awal PENDING sampai
   * di-ACC Super Admin. Dibatasi 5x / jam per IP.
   */
  @Post('register-sppg')
  @HttpCode(HttpStatus.CREATED)
  @Throttle({ default: { limit: 5, ttl: 60 * 60 * 1000 } })
  async registerSppg(@Body() dto: RegisterSppgDto) {
    const result = await this.authService.registerSppg(dto);
    return {
      success: true,
      message: result.message,
      data: null,
    };
  }

  /**
   * GET /api/v1/auth/profile
   * Profil pengguna dashboard yang sedang login.
   */
  @Get('profile')
  @UseGuards(JwtAuthGuard, AdminRoleGuard)
  async getProfile(@CurrentUser() user: AuthUser) {
    const data = await this.authService.getProfile(user);
    return {
      success: true,
      message: 'Berhasil',
      data,
    };
  }
}
