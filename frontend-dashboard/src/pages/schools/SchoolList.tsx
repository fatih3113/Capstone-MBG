import type { SchoolItem } from '@/types/api.types';
import { Pencil, Trash2, Building2 } from 'lucide-react';
import { LEVEL_COLOR } from './types';

interface SchoolListProps {
  records: SchoolItem[];
  total: number;
  page: number;
  totalPages: number;
  onEdit: (school: SchoolItem) => void;
  onDelete: (school: SchoolItem) => void;
  onPageChange: (page: number) => void;
}

export default function SchoolList({
  records, total, page, totalPages, onEdit, onDelete, onPageChange,
}: SchoolListProps) {
  return (
    <div>
      <div className="table-wrapper">
        <table className="data-table" id="schools-table">
          <thead>
            <tr>
              <th>Nama Sekolah / Lembaga</th>
              <th>Jenjang</th>
              <th>Kota / Kab.</th>
              <th>Alamat</th>
              <th style={{ textAlign: 'center' }}>Jadwal Distribusi</th>
              <th style={{ textAlign: 'center', width: '90px' }}>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {records.length === 0 ? (
              <tr><td colSpan={6} style={{ textAlign: 'center', padding: '3rem', color: 'var(--color-text-3)' }}>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '.75rem' }}>
                  <Building2 size={32} /><span>Belum ada sekolah. Klik "Tambah Sekolah".</span>
                </div>
              </td></tr>
            ) : records.map((s) => (
              <tr key={s.id}>
                <td><strong>{s.name}</strong></td>
                <td>
                  <span className={`badge ${LEVEL_COLOR[s.level] ?? 'badge--default'}`}>{s.level}</span>
                </td>
                <td>{s.city ?? '—'}</td>
                <td>
                  <span className="row-sub" title={s.address ?? ''}>{s.address ?? '—'}</span>
                </td>
                <td style={{ textAlign: 'center' }}>
                  <span className={`badge ${s._count.mbgMenus > 0 ? 'badge--green' : 'badge--default'}`}>
                    {s._count.mbgMenus} jadwal
                  </span>
                </td>
                <td>
                  <div className="row-actions">
                    <button className="icon-btn" title="Edit" onClick={() => onEdit(s)}>
                      <Pencil size={15} />
                    </button>
                    <button className="icon-btn icon-btn--danger" title="Hapus" onClick={() => onDelete(s)}>
                      <Trash2 size={15} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Footer pagination */}
      <div className="table-footer">
        <p className="table-footer__count">Total <strong>{total}</strong> sekolah</p>
        {totalPages > 1 && (
          <div className="pagination">
            <button id="school-prev-page" className="btn btn--ghost btn--sm"
              disabled={page === 1} onClick={() => onPageChange(page - 1)}>← Sebelumnya</button>
            <span className="pagination__info">{page} / {totalPages}</span>
            <button id="school-next-page" className="btn btn--ghost btn--sm"
              disabled={page === totalPages} onClick={() => onPageChange(page + 1)}>Berikutnya →</button>
          </div>
        )}
      </div>
    </div>
  );
}
