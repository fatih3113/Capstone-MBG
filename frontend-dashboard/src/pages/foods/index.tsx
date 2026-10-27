import { useEffect, useState, useCallback } from 'react';
import { foodsApi } from '@/api/endpoints';
import type { FoodItem } from '@/types/api.types';
import { Plus, Search } from 'lucide-react';
import { catLabel } from './types';
import FoodList from './FoodList';
import FoodCreate from './FoodCreate';
import FoodEdit from './FoodEdit';
import FoodDelete from './FoodDelete';

export default function FoodsPage() {
  const [records, setRecords]       = useState<FoodItem[]>([]);
  const [total, setTotal]           = useState(0);
  const [page, setPage]             = useState(1);
  const [categories, setCategories] = useState<string[]>([]);
  const [search, setSearch]         = useState('');
  const [category, setCategory]     = useState('');
  const [showInactive, setShowInactive] = useState(false);
  const [isLoading, setIsLoading]   = useState(true);
  const [error, setError]           = useState('');

  // Modal state
  const [showCreate, setShowCreate] = useState(false);
  const [editItem, setEditItem]     = useState<FoodItem | null>(null);
  const [deleteItem, setDeleteItem] = useState<FoodItem | null>(null);

  const LIMIT = 15;

  const load = useCallback(async () => {
    setIsLoading(true); setError('');
    try {
      const res = await foodsApi.list({
        search: search || undefined,
        category: category || undefined,
        isActive: showInactive ? undefined : 'true',
        page, limit: LIMIT,
      });
      setRecords(res.data.data.records);
      setTotal(res.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data makanan');
    } finally { setIsLoading(false); }
  }, [search, category, showInactive, page]);

  useEffect(() => {
    foodsApi.categories().then((r) => setCategories(r.data.data)).catch(() => { });
  }, []);
  useEffect(() => { load(); }, [load]);

  const handleToggle = async (item: FoodItem) => {
    try { await foodsApi.toggle(item.id); load(); } catch { /* ignore */ }
  };

  const totalPages = Math.ceil(total / LIMIT);

  return (
    <div className="page">
      {/* Header */}
      <div className="page__header">
        <div>
          <h1 className="page__title">Manajemen Makanan</h1>
          <p className="page__subtitle">Kelola data makanan dan informasi gizi untuk program MBG</p>
        </div>
        <button id="food-add-btn" className="btn btn--primary" onClick={() => setShowCreate(true)}>
          <Plus size={16} /> Tambah Makanan
        </button>
      </div>

      {/* Filter */}
      <div className="filter-bar">
        <div className="filter-bar__group" style={{ flex: 1, minWidth: '180px' }}>
          <label className="filter-bar__label">Cari Makanan</label>
          <div className="search-input-wrap">
            <Search size={15} className="search-icon" />
            <input className="form-input form-input--sm search-input" placeholder="Nama makanan..."
              value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} />
          </div>
        </div>
        <div className="filter-bar__group">
          <label className="filter-bar__label">Kategori</label>
          <select className="form-input form-input--sm" value={category}
            onChange={(e) => { setCategory(e.target.value); setPage(1); }}>
            <option value="">Semua</option>
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
        {(search || category) && (
          <button className="btn btn--ghost btn--sm" onClick={() => { setSearch(''); setCategory(''); setPage(1); }}>Reset</button>
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

      {/* Create */}
      {showCreate && (
        <FoodCreate
          categories={categories}
          onSuccess={() => { setShowCreate(false); load(); }}
          onClose={() => setShowCreate(false)}
        />
      )}

      {/* Edit */}
      {editItem && (
        <FoodEdit
          food={editItem}
          categories={categories}
          onSuccess={() => { setEditItem(null); load(); }}
          onClose={() => setEditItem(null)}
        />
      )}

      {/* Delete */}
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
