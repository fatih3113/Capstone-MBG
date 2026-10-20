import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AdminRoleGuard } from './guards/admin-role.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /api/v1/auth/login
   * Login khusus admin dashboard. Mengembalikan JWT dengan secret terpisah.
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginDto) {
    const result = await this.authService.login(dto);
    return {
      success: true,
      message: 'Login berhasil',
      data: result,
    };
  }

  /**
   * GET /api/v1/auth/profile
   * Ambil profil admin yang sedang login.
   */
  @Get('profile')
  @UseGuards(JwtAuthGuard, AdminRoleGuard)
  async getProfile(@Request() req: any) {
    const user = await this.authService.getProfile(req.user.id);
    return {
      success: true,
      message: 'Berhasil',
      data: user,
    };
  }
}
