import { useEffect, useState } from 'react';
import { menuRequestsApi } from '@/api/endpoints';
import type { MenuRequest, GroupedMenuRequest } from '@/types/api.types';
import { downloadCsv } from '@/api/client';
import { Download, Search } from 'lucide-react';
import { STATUSES, STATUS_LABELS } from './types';
import MenuRequestList from './MenuRequestList';
import MenuRequestUpdateStatus from './MenuRequestUpdateStatus';

export default function MenuRequestsPage() {
  const [records, setRecords]       = useState<MenuRequest[]>([]);
  const [grouped, setGrouped]       = useState<GroupedMenuRequest[]>([]);
  const [total, setTotal]           = useState(0);
  const [page, setPage]             = useState(1);
  const [isLoading, setIsLoading]   = useState(true);
  const [error, setError]           = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [search, setSearch]         = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [startDate, setStartDate]   = useState('');
  const [endDate, setEndDate]       = useState('');

  // Modal state
  const [selectedRequest, setSelectedRequest] = useState<MenuRequest | null>(null);

  const LIMIT = 15;

  const load = async () => {
    setIsLoading(true); setError('');
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
    } finally { setIsLoading(false); }
  };

  useEffect(() => { load(); }, [statusFilter, search, startDate, endDate, page]);

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
          <MenuRequestList
            records={records} total={total} page={page} totalPages={totalPages}
            onUpdateStatus={(r) => setSelectedRequest(r)}
            onPageChange={setPage}
          />
        )}
      </div>

      {/* Update Status Modal */}
      {selectedRequest && (
        <MenuRequestUpdateStatus
          request={selectedRequest}
          onSuccess={() => { setSelectedRequest(null); load(); }}
          onClose={() => setSelectedRequest(null)}
        />
      )}
    </div>
  );
}
