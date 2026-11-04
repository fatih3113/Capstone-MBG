import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { isDashboardRole } from '../roles';

/**
 * Guard utama dashboard.
 *  1. User harus punya role dashboard (Super Admin atau Admin SPPG).
 *  2. Jika endpoint/controller diberi @Roles(...), role user harus termasuk di dalamnya.
 *
 * Nama file/class dipertahankan agar semua controller lama tidak perlu diubah.
 */
@Injectable()
export class AdminRoleGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const user = context.switchToHttp().getRequest().user;

    if (!user || !isDashboardRole(user.role)) {
      throw new ForbiddenException(
        'Akses ditolak. Endpoint ini hanya untuk pengelola MBG.',
      );
    }

    const required = this.reflector.getAllAndOverride<string[] | undefined>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (required && required.length > 0 && !required.includes(user.role)) {
      throw new ForbiddenException(
        'Akses ditolak. Fitur ini hanya dapat diakses oleh Super Admin.',
      );
    }
    return true;
  }
}
