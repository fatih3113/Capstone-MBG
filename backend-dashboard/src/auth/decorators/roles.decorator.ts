import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'dashboard_roles';

/**
 * Batasi endpoint/controller ke role tertentu, mis. @Roles(ROLE_SUPER_ADMIN).
 * Tanpa decorator ini, semua role dashboard (Super Admin & Admin SPPG) boleh masuk.
 * Dicek oleh AdminRoleGuard.
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
