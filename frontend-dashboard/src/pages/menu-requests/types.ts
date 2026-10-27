import type { MenuRequestStatus } from '@/types/api.types';

export const STATUSES: MenuRequestStatus[] = ['received', 'reviewing', 'considered', 'approved', 'rejected'];

export const STATUS_LABELS: Record<string, string> = {
  received: 'Diterima',
  reviewing: 'Ditinjau',
  considered: 'Dipertimbangkan',
  approved: 'Disetujui',
  rejected: 'Ditolak',
};

export function fmt(d: string) {
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });
}
