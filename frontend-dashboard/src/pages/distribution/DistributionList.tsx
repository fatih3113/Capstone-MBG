import type { SchoolDistribution, DistributionRecord } from '@/types/api.types';
import { Building2, Pencil, Trash2 } from 'lucide-react';
import { fmtDate, LEVEL_COLOR } from './types';

interface DistributionListProps {
  activeTab: 'schools' | 'timeline';
  schools: SchoolDistribution[];
  timeline: DistributionRecord[];
  timelineTotal: number;
  timelinePage: number;
  totalPages: number;
  onEdit: (rec: DistributionRecord) => void;
  onDelete: (rec: DistributionRecord) => void;
  onPageChange: (page: number) => void;
}

export default function DistributionList({
  activeTab, schools, timeline, timelineTotal, timelinePage, totalPages,
  onEdit, onDelete, onPageChange,
}: DistributionListProps) {
  if (activeTab === 'schools') {
    return (
      <div className="card-grid">
        {schools.length === 0 ? (
          <div className="empty-state">
            <Building2 size={40} />
            <p>Belum ada data distribusi. Klik "Tambah Jadwal" untuk mulai.</p>
          </div>
        ) : schools.map((s) => (
          <div key={s.schoolId} className="school-card">
            <div className="school-card__header">
              <div>
                <h3 className="school-card__name">{s.schoolName}</h3>
                <p className="school-card__city">{s.city ?? '—'}</p>
              </div>
              <span className={`badge ${LEVEL_COLOR[s.level] ?? 'badge--default'}`}>{s.level}</span>
            </div>
            <div className="school-card__stats">
              <div className="school-card__stat">
                <span className="school-card__stat-label">Jadwal Menu</span>
                <span className="school-card__stat-value">{s.menuCount} hari</span>
              </div>
              <div className="school-card__stat">
                <span className="school-card__stat-label">Terakhir</span>
                <span className="school-card__stat-value">{fmtDate(s.recentDates[0])}</span>
              </div>
            </div>
            {s.topFoods.length > 0 && (
              <div className="school-card__foods">
                <p className="school-card__foods-label">Menu Terbanyak</p>
                <div className="food-tags">
                  {s.topFoods.map((f) => (
                    <span key={f.name} className="food-tag" title={`${f.count}× disajikan`}>
                      {f.name} <em>×{f.count}</em>
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    );
  }

  // Timeline tab
  return (
    <div>
      <div className="table-wrapper">
        <table className="data-table" id="distribution-timeline-table">
          <thead>
            <tr>
              <th>Tanggal</th>
              <th>Hari</th>
              <th>Sekolah</th>
              <th>Jenjang</th>
              <th>Menu MBG</th>
              <th style={{ width: '90px', textAlign: 'center' }}>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {timeline.length === 0 ? (
              <tr><td colSpan={6} style={{ textAlign: 'center', padding: '2rem', color: 'var(--color-text-3)' }}>
                Tidak ada data. Tambah jadwal baru.
              </td></tr>
            ) : timeline.map((rec) => (
              <tr key={rec.id}>
                <td><strong>{fmtDate(rec.date)}</strong></td>
                <td>{rec.dayName}</td>
                <td>{rec.school.name}</td>
                <td><span className={`badge ${LEVEL_COLOR[rec.school.level] ?? 'badge--default'}`}>{rec.school.level}</span></td>
                <td>
                  <div className="food-tags food-tags--compact">
                    {rec.foods.map((f) => (
                      <span key={f.name} className="food-tag food-tag--sm" title={`${f.portionGram}g`}>{f.name}</span>
                    ))}
                  </div>
                </td>
                <td>
                  <div className="row-actions">
                    <button className="icon-btn" title="Edit jadwal" onClick={() => onEdit(rec)}>
                      <Pencil size={15} />
                    </button>
                    <button className="icon-btn icon-btn--danger" title="Hapus jadwal" onClick={() => onDelete(rec)}>
                      <Trash2 size={15} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="pagination">
          <button id="dist-prev-page" className="btn btn--ghost btn--sm"
            disabled={timelinePage === 1} onClick={() => onPageChange(timelinePage - 1)}>
            ← Sebelumnya
          </button>
          <span className="pagination__info">Halaman {timelinePage} / {totalPages}</span>
          <button id="dist-next-page" className="btn btn--ghost btn--sm"
            disabled={timelinePage === totalPages} onClick={() => onPageChange(timelinePage + 1)}>
            Berikutnya →
          </button>
        </div>
      )}
    </div>
  );
}
