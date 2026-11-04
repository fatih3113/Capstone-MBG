import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

/**
 * Guard khusus aksi Super Admin (Admin MBG Pusat / BGN).
 * Menolak role SPPG_ADMIN pada endpoint manajerial tingkat pusat seperti tambah/edit/hapus SPPG.
 */
@Injectable()
export class SuperAdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    const allowed = ['admin', 'BGN_ADMIN'];
    if (!user || !allowed.includes(user.role)) {
      throw new ForbiddenException(
        'Akses ditolak. Pengelolaan unit SPPG (tambah, edit, hapus) hanya dapat dilakukan oleh Admin MBG Pusat (BGN).',
      );
    }
    return true;
  }
}

