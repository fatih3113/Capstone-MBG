import { useEffect, useState } from 'react';
import { menuRequestsApi } from '@/api/endpoints';
import type { MenuRequest, GroupedMenuRequest, MenuRequestStatus } from '@/types/api.types';
import StatusBadge from '@/components/ui/StatusBadge';
import { downloadCsv } from '@/api/client';
import { Download, Search } from 'lucide-react';

const STATUSES: MenuRequestStatus[] = ['received', 'reviewing', 'considered', 'approved', 'rejected'];
const STATUS_LABELS: Record<string, string> = {
  received: 'Diterima', reviewing: 'Ditinjau', considered: 'Dipertimbangkan',
  approved: 'Disetujui', rejected: 'Ditolak',
};

function fmt(d: string) {
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });
}

export default function MenuRequestsPage() {
  const [records, setRecords] = useState<MenuRequest[]>([]);
  const [grouped, setGrouped] = useState<GroupedMenuRequest[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [search, setSearch] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  // Modal state
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [newStatus, setNewStatus] = useState<MenuRequestStatus>('received');
  const [adminNote, setAdminNote] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  const LIMIT = 15;

  const load = async () => {
    setIsLoading(true);
    setError('');
    try {
      const [listRes, groupedRes] = await Promise.all([
        menuRequestsApi.list({ status: statusFilter || undefined, search: search || undefined, startDate: startDate || undefined, endDate: endDate || undefined, page, limit: LIMIT }),
        menuRequestsApi.grouped(),
      ]);
      setRecords(listRes.data.data.records);
      setTotal(listRes.data.data.total);
      setGrouped(groupedRes.data.data);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { load(); }, [statusFilter, search, startDate, endDate, page]);

  const openModal = (r: MenuRequest) => {
    setSelectedId(r.id);
    setNewStatus(r.status as MenuRequestStatus);
    setAdminNote(r.adminNote ?? '');
  };

  const saveStatus = async () => {
    if (!selectedId) return;
    setIsSaving(true);
    try {
      await menuRequestsApi.updateStatus(selectedId, newStatus, adminNote);
      setSelectedId(null);
      load();
    } catch (err: any) {
      alert(err?.response?.data?.message ?? 'Gagal menyimpan status');
    } finally {
      setIsSaving(false);
    }
  };

  const handleExport = () => {
    const params: Record<string, string> = {};
    if (startDate) params.startDate = startDate;
    if (endDate) params.endDate = endDate;
    downloadCsv('/menu-requests/export', 'menu_requests.csv', params);
  };

  const totalPages = Math.ceil(total / LIMIT);

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Usulan Menu Siswa</h1>
          <p className="page__subtitle">Kelola dan tindaklanjuti usulan menu dari siswa</p>
        </div>
        <button id="menu-requests-export-btn" className="btn btn--secondary" onClick={handleExport}>
          <Download size={16} /> Ekspor CSV
        </button>
      </div>

      {error && <div className="alert alert--error">{error}</div>}

      {/* Top grouped */}
      {grouped.length > 0 && (
        <div className="table-card" style={{ marginBottom: 24 }}>
          <h2 className="table-card__title">Usulan Terpopuler</h2>
          <div className="tag-cloud">
            {grouped.slice(0, 10).map((g) => (
              <span key={g.menuName} className="tag">
                {g.menuName} <strong>({g.count})</strong>
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="filter-bar">
        <select id="menu-requests-status-filter" className="form-input form-input--sm"
          value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}>
          <option value="">Semua Status</option>
          {STATUSES.map((s) => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
        </select>
        <div className="search-box">
          <Search size={16} />
          <input
            id="menu-requests-search"
            type="text" placeholder="Cari nama menu..."
            className="form-input form-input--sm" value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            onKeyDown={(e) => { if (e.key === 'Enter') { setSearch(searchInput); setPage(1); } }}
          />
        </div>
        <input type="date" className="form-input form-input--sm" value={startDate}
          onChange={(e) => { setStartDate(e.target.value); setPage(1); }} />
        <input type="date" className="form-input form-input--sm" value={endDate}
          onChange={(e) => { setEndDate(e.target.value); setPage(1); }} />
      </div>

      {/* Table */}
      <div className="table-card">
        {isLoading ? (
          <div className="loading-state"><div className="spinner" /></div>
        ) : (
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
                          onClick={() => openModal(r)}
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
                <button className="btn btn--ghost btn--sm" disabled={page <= 1} onClick={() => setPage(p => p - 1)}>‹</button>
                <span>{page} / {totalPages || 1}</span>
                <button className="btn btn--ghost btn--sm" disabled={page >= totalPages} onClick={() => setPage(p => p + 1)}>›</button>
              </div>
            </div>
          </>
        )}
      </div>

      {/* Modal Update Status */}
      {selectedId && (
        <div className="modal-overlay" onClick={() => setSelectedId(null)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h3 className="modal__title">Update Status Usulan</h3>
            <div className="form-group">
              <label className="form-label">Status Baru</label>
              <select id="modal-status-select" className="form-input"
                value={newStatus} onChange={(e) => setNewStatus(e.target.value as MenuRequestStatus)}>
                {STATUSES.map((s) => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label className="form-label">Catatan Admin (opsional)</label>
              <textarea id="modal-admin-note" className="form-input" rows={3}
                value={adminNote} onChange={(e) => setAdminNote(e.target.value)}
                placeholder="Contoh: Akan dipertimbangkan untuk menu bulan depan" />
            </div>
            <div className="modal__actions">
              <button className="btn btn--ghost" onClick={() => setSelectedId(null)}>Batal</button>
              <button id="modal-save-btn" className="btn btn--primary" onClick={saveStatus} disabled={isSaving}>
                {isSaving ? <span className="spinner spinner--sm" /> : 'Simpan'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
