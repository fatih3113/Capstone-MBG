import { ForbiddenException } from '@nestjs/common';

/** Role yang tersimpan di kolom users.role */
export const ROLE_SUPER_ADMIN = 'BGN_ADMIN'; // tampil sebagai "Super Admin"
export const ROLE_SPPG_ADMIN = 'SPPG_ADMIN'; // tampil sebagai "Admin SPPG Daerah"
export const ROLE_LEGACY_ADMIN = 'admin';    // role lama -> diperlakukan sebagai Super Admin

export const ACCOUNT_PENDING = 'PENDING';
export const ACCOUNT_ACTIVE = 'ACTIVE';
export const ACCOUNT_REJECTED = 'REJECTED';

export function isSuperAdminRole(role?: string | null): boolean {
  return role === ROLE_SUPER_ADMIN || role === ROLE_LEGACY_ADMIN;
}

export function isSppgAdminRole(role?: string | null): boolean {
  return role === ROLE_SPPG_ADMIN;
}

/** Role yang boleh masuk dashboard. */
export function isDashboardRole(role?: string | null): boolean {
  return isSuperAdminRole(role) || isSppgAdminRole(role);
}

/** Role legacy 'admin' dinormalisasi menjadi BGN_ADMIN agar seragam di JWT & frontend. */
export function normalizeRole(role: string): string {
  return isSuperAdminRole(role) ? ROLE_SUPER_ADMIN : role;
}

/** Bentuk objek req.user hasil JwtStrategy.validate */
export interface AuthUser {
  id: string;
  email: string;
  name: string;
  role: string;
  sppgId: string | null;
}

/**
 * Scope data per SPPG.
 *  - Super Admin  -> undefined (tanpa filter, semua daerah)
 *  - Admin SPPG   -> id SPPG miliknya (semua query WAJIB difilter dengan nilai ini)
 */
export function sppgScope(user: AuthUser): string | undefined {
  if (isSuperAdminRole(user.role)) return undefined;
  if (!user.sppgId) {
    throw new ForbiddenException('Akun Anda belum terhubung ke SPPG manapun.');
  }
  return user.sppgId;
}
