import type { UserItem } from '@/types/api.types';
import { Users } from 'lucide-react';
import { ALLERGY_LABEL, LEVEL_COLOR, fmtDate, genderLabel } from './types';

interface UserListProps {
  records: UserItem[];
  total: number;
  page: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export default function UserList({ records, total, page, totalPages, onPageChange }: UserListProps) {
  return (
    <div>
      <div className="table-wrapper">
        <table className="data-table" id="users-table">
          <thead>
            <tr>
              <th>Pengguna</th>
              <th>Sekolah / SPPG</th>
              <th>Kelas</th>
              <th>Jenjang</th>
              <th>Jenis Kelamin</th>
              <th style={{ textAlign: 'center' }}>Umur</th>
              <th>Alergi</th>
              <th>Terdaftar</th>
            </tr>
          </thead>
          <tbody>
            {records.length === 0 ? (
              <tr><td colSpan={8} style={{ textAlign: 'center', padding: '3rem', color: 'var(--color-text-3)' }}>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '.75rem' }}>
                  <Users size={32} /><span>Belum ada pengguna yang cocok.</span>
                </div>
              </td></tr>
            ) : records.map((u) => (
              <tr key={u.id}>
                <td>
                  <strong>{u.name}</strong>
                  <div className="row-sub">{u.email}</div>
                </td>
                <td>
                  {u.school
                    ? <strong style={{ fontWeight: 500 }}>{u.school.name}</strong>
                    : <span className="badge badge--orange">Belum pilih sekolah</span>}
                  <div className="row-sub">{u.sppg?.nama ?? '—'}</div>
                </td>
                <td>{u.className || '—'}</td>
                <td>
                  {u.schoolLevel
                    ? <span className={`badge ${LEVEL_COLOR[u.schoolLevel] ?? 'badge--default'}`}>{u.schoolLevel}</span>
                    : '—'}
                </td>
                <td>{genderLabel(u.gender)}</td>
                <td style={{ textAlign: 'center' }}>{u.age ?? '—'}</td>
                <td>
                  {!u.allergyFilled ? (
                    <span className="badge badge--neutral">Belum diisi</span>
                  ) : u.allergies.length === 0 ? (
                    <span className="badge badge--green">Tidak ada</span>
                  ) : (
                    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
                      {u.allergies.map((a) => (
                        <span key={a} className="badge badge--orange"
                          title={a === 'lainnya' ? (u.allergyOther ?? '') : undefined}>
                          {a === 'lainnya' && u.allergyOther
                            ? `Lainnya: ${u.allergyOther}`
                            : (ALLERGY_LABEL[a] ?? a)}
                        </span>
                      ))}
                    </div>
                  )}
                </td>
                <td>{fmtDate(u.createdAt)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="table-footer">
        <p className="table-footer__count">Total <strong>{total}</strong> pengguna</p>
        {totalPages > 1 && (
          <div className="pagination">
            <button className="btn btn--ghost btn--sm" disabled={page === 1}
              onClick={() => onPageChange(page - 1)}>← Sebelumnya</button>
            <span className="pagination__info">{page} / {totalPages}</span>
            <button className="btn btn--ghost btn--sm" disabled={page === totalPages}
              onClick={() => onPageChange(page + 1)}>Berikutnya →</button>
          </div>
        )}
      </div>
    </div>
  );
}