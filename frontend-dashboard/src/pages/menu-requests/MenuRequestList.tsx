import type { MenuRequest } from '@/types/api.types';
import StatusBadge from '@/components/ui/StatusBadge';
import { fmt } from './types';

interface MenuRequestListProps {
  records: MenuRequest[];
  total: number;
  page: number;
  totalPages: number;
  onUpdateStatus: (request: MenuRequest) => void;
  onPageChange: (page: number) => void;
}

export default function MenuRequestList({
  records, total, page, totalPages, onUpdateStatus, onPageChange,
}: MenuRequestListProps) {
  return (
    <>
      <div className="table-wrapper">
        <table className="data-table">
          <thead>
            <tr>
              <th>Tanggal</th><th>Siswa</th><th>Jenjang</th>
              <th>Menu Diusulkan</th><th>Alasan</th>
              <th>Status</th><th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {records.length === 0 ? (
              <tr><td colSpan={7} style={{ textAlign: 'center', color: '#6b7280' }}>Tidak ada data</td></tr>
            ) : records.map((r) => (
              <tr key={r.id}>
                <td>{fmt(r.submittedAt)}</td>
                <td>{r.user.name}</td>
                <td>{r.user.schoolLevel ?? '—'}</td>
                <td><strong>{r.menuName}</strong></td>
                <td>{r.reason ?? '—'}</td>
                <td><StatusBadge status={r.status} /></td>
                <td>
                  <button
                    id={`update-status-btn-${r.id}`}
                    className="btn btn--ghost btn--sm"
                    onClick={() => onUpdateStatus(r)}
                  >
                    Update
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {/* Pagination */}
      <div className="pagination">
        <span>Total: {total} data</span>
        <div className="pagination__controls">
          <button className="btn btn--ghost btn--sm" disabled={page <= 1} onClick={() => onPageChange(page - 1)}>‹</button>
          <span>{page} / {totalPages || 1}</span>
          <button className="btn btn--ghost btn--sm" disabled={page >= totalPages} onClick={() => onPageChange(page + 1)}>›</button>
        </div>
      </div>
    </>
  );
}
