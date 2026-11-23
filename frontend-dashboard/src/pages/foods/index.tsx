import { useEffect, useState, useCallback } from 'react';
import { foodsApi } from '@/api/endpoints';
import { useAuth } from '@/hooks/useAuth';
import type { FoodItem } from '@/types/api.types';
import { Plus, Search } from 'lucide-react';
import { catLabel } from './types';
import FoodList from './FoodList';
import FoodCreate from './FoodCreate';
import FoodEdit from './FoodEdit';
import FoodDelete from './FoodDelete';

export default function FoodsPage() {
  const { user, isSuperAdmin, isSppgAdmin } = useAuth();

  const [records, setRecords]           = useState<FoodItem[]>([]);
  const [total, setTotal]               = useState(0);
  const [page, setPage]                 = useState(1);
  const [categories, setCategories]     = useState<string[]>([]);
  const [search, setSearch]             = useState('');
  const [category, setCategory]         = useState('');
  const [scope, setScope]               = useState<'all' | 'sppg' | 'master'>('all');
  const [showInactive, setShowInactive] = useState(false);
  const [isLoading, setIsLoading]       = useState(true);
  const [error, setError]               = useState('');

  // Modal state
  const [showCreate, setShowCreate]     = useState(false);
  const [editItem, setEditItem]         = useState<FoodItem | null>(null);
  const [deleteItem, setDeleteItem]     = useState<FoodItem | null>(null);

  const LIMIT = 15;

  const load = useCallback(async () => {
    setIsLoading(true); setError('');
    try {
      const res = await foodsApi.list({
        search: search || undefined,
        category: category || undefined,
        scope: scope !== 'all' ? scope : undefined,
        isActive: showInactive ? undefined : 'true',
        page, limit: LIMIT,
      });
      setRecords(res.data.data.records);
      setTotal(res.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data makanan');
    } finally { setIsLoading(false); }
  }, [search, category, scope, showInactive, page]);

  useEffect(() => {
    foodsApi.categories().then((r) => setCategories(r.data.data)).catch(() => { });
  }, []);
  useEffect(() => { load(); }, [load]);

  const handleToggle = async (item: FoodItem) => {
    try { await foodsApi.toggle(item.id); load(); } catch { /* ignore */ }
  };

  const totalPages = Math.ceil(total / LIMIT);

  const pageTitle = isSppgAdmin
    ? 'Menu Makanan SPPG'
    : 'Manajemen Menu Makanan';

  const pageSubtitle = isSppgAdmin
    ? `Kelola menu makanan dan data gizi untuk ${user?.sppgName ?? 'SPPG Anda'}`
    : 'Kelola data makanan master MBG nasional dan menu SPPG daerah';

  const addBtnLabel = isSppgAdmin ? 'Tambah Menu SPPG' : 'Tambah Menu Master';

  return (
    <div className="page">
      {/* Header */}
      <div className="page__header">
        <div>
          <h1 className="page__title">{pageTitle}</h1>
          <p className="page__subtitle">{pageSubtitle}</p>
        </div>
        <button id="food-add-btn" className="btn btn--primary" onClick={() => setShowCreate(true)}>
          <Plus size={16} /> {addBtnLabel}
        </button>
      </div>

      {/* Filter Bar */}
      <div className="filter-bar">
        <div className="filter-bar__group" style={{ flex: 1, minWidth: '180px' }}>
          <label className="filter-bar__label">Cari Menu</label>
          <div className="search-input-wrap">
            <Search size={15} className="search-icon" />
            <input className="form-input form-input--sm search-input" placeholder="Nama makanan..."
              value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} />
          </div>
        </div>

        {/* Filter Asal Menu */}
        <div className="filter-bar__group">
          <label className="filter-bar__label">Asal Menu</label>
          <select className="form-input form-input--sm" value={scope}
            onChange={(e) => { setScope(e.target.value as any); setPage(1); }}>
            <option value="all">Semua Menu</option>
            {isSppgAdmin ? (
              <>
                <option value="sppg">Menu SPPG Saya Saja</option>
                <option value="master">Menu Master MBG</option>
              </>
            ) : (
              <>
                <option value="master">Menu Master MBG (Nasional)</option>
                <option value="sppg">Menu SPPG Daerah</option>
              </>
            )}
          </select>
        </div>

        <div className="filter-bar__group">
          <label className="filter-bar__label">Kategori</label>
          <select className="form-input form-input--sm" value={category}
            onChange={(e) => { setCategory(e.target.value); setPage(1); }}>
            <option value="">Semua Kategori</option>
            {categories.map((c) => <option key={c} value={c}>{catLabel(c)}</option>)}
          </select>
        </div>

        <div className="filter-bar__group">
          <label className="filter-bar__label">Status</label>
          <label className="toggle-label toggle-label--row">
            <input type="checkbox" checked={showInactive}
              onChange={(e) => { setShowInactive(e.target.checked); setPage(1); }} />
            <span>Tampilkan nonaktif</span>
          </label>
        </div>

        {(search || category || scope !== 'all') && (
          <button className="btn btn--ghost btn--sm" onClick={() => { setSearch(''); setCategory(''); setScope('all'); setPage(1); }}>Reset</button>
        )}
      </div>

      {error && <div className="alert alert--error" role="alert">{error}</div>}

      {/* List */}
      {isLoading ? (
        <div className="loading-box"><div className="spinner" /><p>Memuat data makanan...</p></div>
      ) : (
        <FoodList
          records={records} total={total} page={page} totalPages={totalPages}
          onEdit={(f) => setEditItem(f)}
          onDelete={(f) => setDeleteItem(f)}
          onToggle={handleToggle}
          onPageChange={setPage}
        />
      )}

      {/* Create Modal */}
      {showCreate && (
        <FoodCreate
          categories={categories}
          onSuccess={() => { setShowCreate(false); load(); }}
          onClose={() => setShowCreate(false)}
        />
      )}

      {/* Edit Modal */}
      {editItem && (
        <FoodEdit
          food={editItem}
          categories={categories}
          onSuccess={() => { setEditItem(null); load(); }}
          onClose={() => setEditItem(null)}
        />
      )}

      {/* Delete Modal */}
      {deleteItem && (
        <FoodDelete
          food={deleteItem}
          onSuccess={() => { setDeleteItem(null); load(); }}
          onClose={() => setDeleteItem(null)}
        />
      )}
    </div>
  );
}
