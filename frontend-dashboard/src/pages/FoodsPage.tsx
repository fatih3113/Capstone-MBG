import { useEffect, useState, useCallback } from 'react';
import { foodsApi } from '@/api/endpoints';
import type { FoodItem, FoodNutrition } from '@/types/api.types';
import {
  Plus, Pencil, Trash2, X, Check, AlertTriangle,
  Search, ToggleLeft, ToggleRight, Utensils,
} from 'lucide-react';

// ── Constants ─────────────────────────────────────────────────────────
const COOKING_METHODS = ['goreng', 'rebus', 'kukus', 'bakar', 'mentah'];

// Tampilkan nama kategori tanpa kata "Protein" (nilai asli di database tidak berubah)
// "Protein Nabati" -> "Nabati", "Protein Hewani" -> "Hewani"
const catLabel = (c: string) =>
  c.replace(/\bprotein\b/gi, '').replace(/\s{2,}/g, ' ').trim() || c;

type NutrForm = Omit<FoodNutrition, 'id' | 'foodId'>;
interface FoodForm {
  name: string; category: string; description: string; isActive: boolean;
  nutrition: NutrForm;
}

const emptyNutr = (): NutrForm => ({
  calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0,
  sugar: 0, sodium: 0, calcium: 0, iron: 0, vitaminC: 0, vitaminA: 0,
  portionGram: 100, cookingMethod: 'mentah', dataSource: 'TKPI 2017',
});
const emptyForm = (): FoodForm => ({
  name: '', category: '', description: '', isActive: true, nutrition: emptyNutr(),
});

const NUTR_FIELDS: { key: keyof NutrForm; label: string; unit: string }[] = [
  { key: 'calories', label: 'Kalori', unit: 'kcal' },
  { key: 'protein', label: 'Protein', unit: 'g' },
  { key: 'carbs', label: 'Karbohidrat', unit: 'g' },
  { key: 'fat', label: 'Lemak', unit: 'g' },
  { key: 'fiber', label: 'Serat', unit: 'g' },
  { key: 'sugar', label: 'Gula', unit: 'g' },
  { key: 'sodium', label: 'Natrium', unit: 'mg' },
  { key: 'calcium', label: 'Kalsium', unit: 'mg' },
  { key: 'iron', label: 'Zat Besi', unit: 'mg' },
  { key: 'vitaminC', label: 'Vitamin C', unit: 'mg' },
  { key: 'vitaminA', label: 'Vitamin A', unit: 'µg' },
  { key: 'portionGram', label: 'Per Porsi', unit: 'g' },
];

// Kunci harus sama dengan nama kategori ASLI di database.
// Nama dengan dan tanpa kata "Protein" sama-sama dicantumkan agar aman.
const CAT_BADGE: Record<string, string> = {
  'Sayuran': 'badge--yellow',
  'Buah': 'badge--orange',
  'Minuman': 'badge--teal',
  'Makanan Pokok': 'badge--blue',
  'Protein Nabati': 'badge--yellow',
  'Protein Hewani': 'badge--orange',
  'Nabati': 'badge--yellow',
  'Hewani': 'badge--orange',
};

// ── Modal Form Tambah / Edit ──────────────────────────────────────────
function FoodModal({ title, form, setForm, categories, onSave, onClose, saving, error }: {
  title: string; form: FoodForm; setForm: (f: FoodForm) => void;
  categories: string[]; onSave: () => void; onClose: () => void;
  saving: boolean; error: string;
}) {
  const setNutr = (key: keyof NutrForm, val: string | number) =>
    setForm({ ...form, nutrition: { ...form.nutrition, [key]: val } });

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--lg" onClick={(e) => e.stopPropagation()} role="dialog">
        <div className="modal__header">
          <h2 className="modal__title">{title}</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '.75rem' }}>{error}</div>}

          {/* Info dasar */}
          <p className="modal__section-title">Informasi Makanan</p>
          <div className="form-row-2">
            <div className="form-group">
              <label className="form-label" htmlFor="food-name">Nama Makanan *</label>
              <input id="food-name" className="form-input" value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                placeholder="cth. Nasi Putih" />
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="food-cat">Kategori *</label>
              <select id="food-cat" className="form-input" value={form.category}
                onChange={(e) => setForm({ ...form, category: e.target.value })}>
                <option value="">— Pilih —</option>
                {categories.map((c) => <option key={c} value={c}>{catLabel(c)}</option>)}
              </select>
            </div>
          </div>
          <div className="form-group">
            <label className="form-label" htmlFor="food-desc">Deskripsi</label>
            <textarea id="food-desc" className="form-input" rows={2} value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              placeholder="Opsional" style={{ resize: 'vertical' }} />
          </div>
          <div className="form-group">
            <label className="form-label">Status</label>
            <label className="toggle-label">
              <input type="checkbox" checked={form.isActive}
                onChange={(e) => setForm({ ...form, isActive: e.target.checked })} />
              <span>{form.isActive ? 'Aktif' : 'Nonaktif'}</span>
            </label>
          </div>

          {/* Data gizi */}
          <p className="modal__section-title" style={{ marginTop: '1rem' }}>
            Data Gizi <span style={{ fontWeight: 400, fontSize: '.78rem', color: 'var(--color-text-3)' }}>(per 100 g kecuali Per Porsi)</span>
          </p>
          <div className="nutr-grid">
            {NUTR_FIELDS.map(({ key, label, unit }) => (
              <div key={key} className="form-group">
                <label className="form-label">{label} <span className="unit-label">({unit})</span></label>
                <input type="number" className="form-input" min={0} step={0.1}
                  value={form.nutrition[key] as number}
                  onChange={(e) => setNutr(key, +e.target.value)} />
              </div>
            ))}
          </div>
          <div className="form-row-2">
            <div className="form-group">
              <label className="form-label" htmlFor="food-cook">Cara Masak</label>
              <select id="food-cook" className="form-input" value={form.nutrition.cookingMethod ?? ''}
                onChange={(e) => setNutr('cookingMethod', e.target.value)}>
                {COOKING_METHODS.map((m) => <option key={m} value={m}>{m}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="food-src">Sumber Data</label>
              <input id="food-src" className="form-input" value={form.nutrition.dataSource}
                onChange={(e) => setNutr('dataSource', e.target.value)} />
            </div>
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={saving}>Batal</button>
          <button id="food-modal-save" className="btn btn--primary" onClick={onSave} disabled={saving}>
            {saving ? 'Menyimpan...' : <><Check size={16} /> Simpan</>}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Modal Konfirmasi Hapus ────────────────────────────────────────────
function DeleteFoodModal({ food, onConfirm, onClose, deleting }: {
  food: FoodItem; onConfirm: () => void; onClose: () => void; deleting: boolean;
}) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--sm" onClick={(e) => e.stopPropagation()}>
        <div className="modal__header">
          <h2 className="modal__title">Hapus Makanan</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          <div className="delete-confirm">
            <AlertTriangle size={36} color="#ef4444" />
            <p>Hapus <strong>{food.name}</strong> secara permanen?</p>
            <p className="delete-confirm__sub">Jika sudah dipakai di jadwal atau scan, gunakan Nonaktifkan saja.</p>
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={deleting}>Batal</button>
          <button id="food-delete-confirm" className="btn btn--danger" onClick={onConfirm} disabled={deleting}>
            {deleting ? 'Menghapus...' : <><Trash2 size={15} /> Hapus Permanen</>}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Halaman Utama ─────────────────────────────────────────────────────
export default function FoodsPage() {
  const [records, setRecords] = useState<FoodItem[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [categories, setCategories] = useState<string[]>([]);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('');
  const [showInactive, setShowInactive] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  // Modal
  const [showCreate, setShowCreate] = useState(false);
  const [editItem, setEditItem] = useState<FoodItem | null>(null);
  const [deleteItem, setDeleteItem] = useState<FoodItem | null>(null);
  const [form, setForm] = useState<FoodForm>(emptyForm());
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [modalError, setModalError] = useState('');
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

  // ── Handlers ──────────────────────────────────────────────────
  const openCreate = () => { setForm(emptyForm()); setModalError(''); setShowCreate(true); };

  const openEdit = (item: FoodItem) => {
    setEditItem(item);
    setModalError('');
    setForm({
      name: item.name, category: item.category,
      description: item.description ?? '', isActive: item.isActive,
      nutrition: item.nutrition ? {
        calories: item.nutrition.calories, protein: item.nutrition.protein,
        carbs: item.nutrition.carbs, fat: item.nutrition.fat, fiber: item.nutrition.fiber,
        sugar: item.nutrition.sugar, sodium: item.nutrition.sodium,
        calcium: item.nutrition.calcium, iron: item.nutrition.iron,
        vitaminC: item.nutrition.vitaminC, vitaminA: item.nutrition.vitaminA,
        portionGram: item.nutrition.portionGram,
        cookingMethod: item.nutrition.cookingMethod ?? 'mentah',
        dataSource: item.nutrition.dataSource,
      } : emptyNutr(),
    });
  };

  const handleSave = async () => {
    if (!form.name.trim() || !form.category) { setModalError('Nama dan kategori wajib diisi.'); return; }
    setSaving(true); setModalError('');
    try {
      const body = {
        name: form.name, category: form.category, description: form.description || null,
        isActive: form.isActive, nutrition: form.nutrition
      };
      let res;
      if (editItem) {
        res = await foodsApi.update(editItem.id, body as Parameters<typeof foodsApi.update>[1]);
      } else {
        res = await foodsApi.create(body as Parameters<typeof foodsApi.create>[0]);
      }
      if (!res.data.success) { setModalError(res.data.message); setSaving(false); return; }
      setShowCreate(false); setEditItem(null);
      load();
    } catch (err: any) {
      setModalError(err?.response?.data?.message ?? 'Gagal menyimpan.');
    } finally { setSaving(false); }
  };

  const handleToggle = async (item: FoodItem) => {
    try {
      await foodsApi.toggle(item.id);
      load();
    } catch { /* ignore */ }
  };

  const handleDelete = async () => {
    if (!deleteItem) return;
    setDeleting(true);
    try {
      const res = await foodsApi.delete(deleteItem.id);
      if (!res.data.success) { setError(res.data.message); }
      setDeleteItem(null); load();
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal menghapus.');
      setDeleteItem(null);
    } finally { setDeleting(false); }
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
        <button id="food-add-btn" className="btn btn--primary" onClick={openCreate}>
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
          <button className="btn btn--ghost btn--sm" onClick={() => { setSearch(''); setCategory(''); setPage(1); }}>
            Reset
          </button>
        )}
      </div>

      {error && <div className="alert alert--error" role="alert">{error}</div>}

      {/* Tabel */}
      {isLoading ? (
        <div className="loading-box"><div className="spinner" /><p>Memuat data makanan...</p></div>
      ) : (
        <div>
          <div className="table-wrapper">
            <table className="data-table" id="foods-table">
              <thead>
                <tr>
                  <th>Nama Makanan</th>
                  <th>Kategori</th>
                  <th style={{ textAlign: 'right' }}>Kalori</th>
                  <th style={{ textAlign: 'right' }}>Protein</th>
                  <th style={{ textAlign: 'right' }}>Karbo</th>
                  <th style={{ textAlign: 'right' }}>Lemak</th>
                  <th>Sumber</th>
                  <th style={{ textAlign: 'center' }}>Status</th>
                  <th style={{ textAlign: 'center', width: '90px' }}>Aksi</th>
                </tr>
              </thead>
              <tbody>
                {records.length === 0 ? (
                  <tr><td colSpan={9} style={{ textAlign: 'center', padding: '3rem', color: 'var(--color-text-3)' }}>
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '.75rem' }}>
                      <Utensils size={32} /><span>Tidak ada makanan. Klik "Tambah Makanan".</span>
                    </div>
                  </td></tr>
                ) : records.map((food) => (
                  <tr key={food.id} style={{ opacity: food.isActive ? 1 : 0.5 }}>
                    <td>
                      <strong>{food.name}</strong>
                      {food.description && <div className="row-sub">{food.description}</div>}
                    </td>
                    <td>
                      <span className={`badge ${CAT_BADGE[food.category] ?? 'badge--default'}`}>
                        {catLabel(food.category)}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>{food.nutrition?.calories.toFixed(0) ?? '—'}</td>
                    <td style={{ textAlign: 'right' }}>{food.nutrition?.protein.toFixed(1) ?? '—'}</td>
                    <td style={{ textAlign: 'right' }}>{food.nutrition?.carbs.toFixed(1) ?? '—'}</td>
                    <td style={{ textAlign: 'right' }}>{food.nutrition?.fat.toFixed(1) ?? '—'}</td>
                    <td style={{ fontSize: '.78rem', color: 'var(--color-text-3)' }}>
                      {food.nutrition?.dataSource ?? '—'}
                    </td>
                    <td style={{ textAlign: 'center' }}>
                      <button
                        className={`toggle-btn ${food.isActive ? 'toggle-btn--on' : 'toggle-btn--off'}`}
                        onClick={() => handleToggle(food)}
                        title={food.isActive ? 'Nonaktifkan' : 'Aktifkan'}
                      >
                        {food.isActive ? <ToggleRight size={22} /> : <ToggleLeft size={22} />}
                      </button>
                    </td>
                    <td>
                      <div className="row-actions">
                        <button className="icon-btn" title="Edit" onClick={() => openEdit(food)}>
                          <Pencil size={15} />
                        </button>
                        <button className="icon-btn icon-btn--danger" title="Hapus" onClick={() => setDeleteItem(food)}>
                          <Trash2 size={15} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          <div className="table-footer">
            <p className="table-footer__count">
              Total <strong>{total}</strong> makanan
            </p>
            {totalPages > 1 && (
              <div className="pagination">
                <button id="food-prev-page" className="btn btn--ghost btn--sm"
                  disabled={page === 1} onClick={() => setPage((p) => p - 1)}>← Sebelumnya</button>
                <span className="pagination__info">{page} / {totalPages}</span>
                <button id="food-next-page" className="btn btn--ghost btn--sm"
                  disabled={page === totalPages} onClick={() => setPage((p) => p + 1)}>Berikutnya →</button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Modal Tambah/Edit */}
      {(showCreate || editItem !== null) && (
        <FoodModal
          title={editItem ? `Edit: ${editItem.name}` : 'Tambah Makanan Baru'}
          form={form} setForm={setForm} categories={categories}
          onSave={handleSave}
          onClose={() => { setShowCreate(false); setEditItem(null); }}
          saving={saving} error={modalError}
        />
      )}

      {/* Modal Hapus */}
      {deleteItem && (
        <DeleteFoodModal
          food={deleteItem} onConfirm={handleDelete}
          onClose={() => setDeleteItem(null)} deleting={deleting}
        />
      )}
    </div>
  );
}