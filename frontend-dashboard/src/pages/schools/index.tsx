import { useEffect, useState, useCallback } from 'react';
import { schoolsApi } from '@/api/endpoints';
import type { SchoolItem, InstitutionType } from '@/types/api.types';
import { Plus, Search } from 'lucide-react';
import { SEKOLAH_LEVELS } from './types';
import SchoolList from './SchoolList';
import SchoolCreate from './SchoolCreate';
import SchoolEdit from './SchoolEdit';
import SchoolDelete from './SchoolDelete';

interface SchoolsPageProps {
  type: InstitutionType;
}

export default function SchoolsPage({ type }: SchoolsPageProps) {
  const isPosyandu = type === 'posyandu';
  const label = isPosyandu ? 'Posyandu' : 'Sekolah';

  const [records, setRecords]       = useState<SchoolItem[]>([]);
  const [total, setTotal]           = useState(0);
  const [page, setPage]             = useState(1);
  const [search, setSearch]         = useState('');
  const [level, setLevel]           = useState('');
  const [isLoading, setIsLoading]   = useState(true);
  const [error, setError]           = useState('');

  // Modal state — hanya satu yang aktif pada satu waktu
  const [showCreate, setShowCreate] = useState(false);
  const [editItem, setEditItem]     = useState<SchoolItem | null>(null);
  const [deleteItem, setDeleteItem] = useState<SchoolItem | null>(null);

  const LIMIT = 15;

  const load = useCallback(async () => {
    setIsLoading(true); setError('');
    try {
      const res = await schoolsApi.list({
        search: search || undefined,
        level: level || undefined,
        type,
        page,
        limit: LIMIT,
      });
      setRecords(res.data.data.records);
      setTotal(res.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? `Gagal memuat data ${label.toLowerCase()}`);
    } finally { setIsLoading(false); }
  }, [search, level, page, type, label]);

  useEffect(() => { load(); }, [load]);

  const totalPages = Math.ceil(total / LIMIT);

  return (
    <div className="page">
      {/* Header */}
      <div className="page__header">
        <div>
          <h1 className="page__title">Data {label}</h1>
          <p className="page__subtitle">
            {isPosyandu
              ? 'Kelola daftar posyandu penerima distribusi MBG'
              : 'Kelola daftar sekolah penerima distribusi MBG'}
          </p>
        </div>
        <button id="school-add-btn" className="btn btn--primary" onClick={() => setShowCreate(true)}>
          <Plus size={16} /> Tambah {label}
        </button>
      </div>

      {/* Filter */}
      <div className="filter-bar">
        <div className="filter-bar__group" style={{ flex: 1, minWidth: '180px' }}>
          <label className="filter-bar__label">Cari {label}</label>
          <div className="search-input-wrap">
            <Search size={15} className="search-icon" />
            <input className="form-input form-input--sm search-input"
              placeholder={`Nama ${label.toLowerCase()}...`}
              value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} />
          </div>
        </div>
        {!isPosyandu && (
          <div className="filter-bar__group">
            <label className="filter-bar__label">Jenjang</label>
            <select className="form-input form-input--sm" value={level}
              onChange={(e) => { setLevel(e.target.value); setPage(1); }}>
              <option value="">Semua</option>
              {SEKOLAH_LEVELS.map((l) => <option key={l} value={l}>{l}</option>)}
            </select>
          </div>
        )}
        {(search || level) && (
          <button className="btn btn--ghost btn--sm"
            onClick={() => { setSearch(''); setLevel(''); setPage(1); }}>Reset</button>
        )}
      </div>

      {error && <div className="alert alert--error" role="alert">{error}</div>}

      {/* List */}
      {isLoading ? (
        <div className="loading-box"><div className="spinner" /><p>Memuat data {label.toLowerCase()}...</p></div>
      ) : (
        <SchoolList
          type={type}
          records={records} total={total} page={page} totalPages={totalPages}
          onEdit={(s) => setEditItem(s)}
          onDelete={(s) => setDeleteItem(s)}
          onPageChange={setPage}
        />
      )}

      {/* Create */}
      {showCreate && (
        <SchoolCreate
          type={type}
          onSuccess={() => { setShowCreate(false); load(); }}
          onClose={() => setShowCreate(false)}
        />
      )}

      {/* Edit */}
      {editItem && (
        <SchoolEdit
          school={editItem}
          onSuccess={() => { setEditItem(null); load(); }}
          onClose={() => setEditItem(null)}
        />
      )}

      {/* Delete */}
      {deleteItem && (
        <SchoolDelete
          school={deleteItem}
          onSuccess={() => { setDeleteItem(null); load(); }}
          onClose={() => setDeleteItem(null)}
        />
      )}
    </div>
  );
}