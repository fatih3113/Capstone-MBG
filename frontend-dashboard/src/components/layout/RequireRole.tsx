import { ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';

interface RequireRoleProps {
  /** 'super' = hanya Super Admin, 'sppg' = hanya Admin SPPG Daerah */
  role: 'super' | 'sppg';
  children: ReactNode;
}

/**
 * Pembatas halaman di sisi UI. Ini hanya soal pengalaman pengguna:
 * keamanan sebenarnya tetap ditegakkan di backend (@Roles + filter per SPPG).
 */
export default function RequireRole({ role, children }: RequireRoleProps) {
  const { isSuperAdmin, isSppgAdmin } = useAuth();
  const allowed = role === 'super' ? isSuperAdmin : isSppgAdmin;
  if (!allowed) return <Navigate to="/" replace />;
  return <>{children}</>;
}
