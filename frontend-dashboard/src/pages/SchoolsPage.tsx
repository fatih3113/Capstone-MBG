import { useEffect, useState, useCallback } from 'react';
import { schoolsApi } from '@/api/endpoints';
import type { SchoolItem } from '@/types/api.types';
import { Plus, Pencil, Trash2, X, Check, AlertTriangle, Search, Building2 } from 'lucide-react';

const LEVELS = ['SD', 'SMP', 'SMA', 'SMK', 'Posyandu', 'Puskesmas', 'Lainnya'];
const LEVEL_COLOR: Record<string, string> = {
  SD: 'badge--blue', SMP: 'badge--green', SMA: 'badge--yellow', SMK: 'badge--purple',
  Posyandu: 'badge--orange', Puskesmas: 'badge--teal', Lainnya: 'badge--default',
};

interface SchoolForm {
  name: string; level: string; address: string; city: string;
}
const emptyForm = (): SchoolForm => ({ name: '', level: '', address: '', city: '' });

// ── Modal Tambah/Edit ─────────────────────────────────────────────────
function SchoolModal({ title, form, setForm, onSave, onClose, saving, error }: {
  title: string; form: SchoolForm; setForm: (f: SchoolForm) => void;
  onSave: () => void; onClose: () => void; saving: boolean; error: string;
}) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()} role="dialog">
        <div className="modal__header">
          <h2 className="modal__title">{title}</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '.75rem' }}>{error}</div>}

          <div className="form-row-2">
            <div className="form-group">
              <label className="form-label" htmlFor="sch-name">Nama Sekolah / Lembaga *</label>
              <input id="sch-name" className="form-input" value={form.name} placeholder="cth. SDN 01 Jakarta"
                onChange={(e) => setForm({ ...form, name: e.target.value })} />
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="sch-level">Jenjang / Tipe *</label>
              <select id="sch-level" className="form-input" value={form.level}
                onChange={(e) => setForm({ ...form, level: e.target.value })}>
                <option value="">— Pilih —</option>
                {LEVELS.map((l) => <option key={l} value={l}>{l}</option>)}
              </select>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="sch-addr">Alamat</label>
            <textarea id="sch-addr" className="form-input" rows={2} value={form.address}
              placeholder="Opsional" style={{ resize: 'vertical' }}
              onChange={(e) => setForm({ ...form, address: e.target.value })} />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="sch-city">Kota / Kabupaten</label>
            <input id="sch-city" className="form-input" value={form.city} placeholder="cth. Jakarta Selatan"
              onChange={(e) => setForm({ ...form, city: e.target.value })} />
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={saving}>Batal</button>
          <button id="school-modal-save" className="btn btn--primary" onClick={onSave} disabled={saving}>
            {saving ? 'Menyimpan...' : <><Check size={16} /> Simpan</>}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Modal Konfirmasi Hapus ────────────────────────────────────────────
function DeleteSchoolModal({ school, onConfirm, onClose, deleting }: {
  school: SchoolItem; onConfirm: () => void; onClose: () => void; deleting: boolean;
}) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--sm" onClick={(e) => e.stopPropagation()}>
        <div className="modal__header">
          <h2 className="modal__title">Hapus Sekolah</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          <div className="delete-confirm">
            <AlertTriangle size={36} color="#ef4444" />
            <p>Hapus <strong>{school.name}</strong>?</p>
            {school._count.mbgMenus > 0 && (
              <p className="delete-confirm__sub" style={{ color: '#ef4444' }}>
                ⚠️ Sekolah ini memiliki {school._count.mbgMenus} jadwal distribusi dan tidak bisa dihapus.
              </p>
            )}
            {school._count.mbgMenus === 0 && (
              <p className="delete-confirm__sub">Data ini akan dihapus permanen.</p>
            )}
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={deleting}>Batal</button>
          <button id="school-delete-confirm" className="btn btn--danger"
            onClick={onConfirm} disabled={deleting || school._count.mbgMenus > 0}>
            {deleting ? 'Menghapus...' : <><Trash2 size={15} /> Hapus</>}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Halaman Utama ─────────────────────────────────────────────────────
export default function SchoolsPage() {
  const [records, setRecords]           = useState<SchoolItem[]>([]);
  const [total, setTotal]               = useState(0);
  const [page, setPage]                 = useState(1);
  const [search, setSearch]             = useState('');
  const [level, setLevel]               = useState('');
  const [isLoading, setIsLoading]       = useState(true);
  const [error, setError]               = useState('');
  const [showCreate, setShowCreate]     = useState(false);
  const [editItem, setEditItem]         = useState<SchoolItem | null>(null);
  const [deleteItem, setDeleteItem]     = useState<SchoolItem | null>(null);
  const [form, setForm]                 = useState<SchoolForm>(emptyForm());
  const [saving, setSaving]             = useState(false);
  const [deleting, setDeleting]         = useState(false);
  const [modalError, setModalError]     = useState('');
  const LIMIT = 15;

  const load = useCallback(async () => {
    setIsLoading(true); setError('');
    try {
      const res = await schoolsApi.list({ search: search || undefined, level: level || undefined, page, limit: LIMIT });
      setRecords(res.data.data.records);
      setTotal(res.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data sekolah');
    } finally { setIsLoading(false); }
  }, [search, level, page]);

  useEffect(() => { load(); }, [load]);

  const openCreate = () => { setForm(emptyForm()); setModalError(''); setShowCreate(true); };
  const openEdit = (s: SchoolItem) => {
    setEditItem(s); setModalError('');
    setForm({ name: s.name, level: s.level, address: s.address ?? '', city: s.city ?? '' });
  };

  const handleSave = async () => {
    if (!form.name.trim() || !form.level) { setModalError('Nama dan jenjang wajib diisi.'); return; }
    setSaving(true); setModalError('');
    try {
      const body = { name: form.name, level: form.level, address: form.address || undefined, city: form.city || undefined };
      const res = editItem
        ? await schoolsApi.update(editItem.id, body)
        : await schoolsApi.create(body);
      if (!res.data.success) { setModalError(res.data.message); setSaving(false); return; }
      setShowCreate(false); setEditItem(null); load();
    } catch (err: any) {
      setModalError(err?.response?.data?.message ?? 'Gagal menyimpan.');
    } finally { setSaving(false); }
  };

  const handleDelete = async () => {
    if (!deleteItem) return;
    setDeleting(true);
    try {
      const res = await schoolsApi.delete(deleteItem.id);
      if (!res.data.success) setError(res.data.message);
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
          <h1 className="page__title">Data Sekolah & Lembaga</h1>
          <p className="page__subtitle">Kelola daftar sekolah dan posyandu penerima distribusi MBG</p>
        </div>
        <button id="school-add-btn" className="btn btn--primary" onClick={openCreate}>
          <Plus size={16} /> Tambah Sekolah
        </button>
      </div>

      {/* Filter */}
      <div className="filter-bar">
        <div className="filter-bar__group" style={{ flex: 1, minWidth: '180px' }}>
          <label className="filter-bar__label">Cari Sekolah</label>
          <div className="search-input-wrap">
            <Search size={15} className="search-icon" />
            <input className="form-input form-input--sm search-input" placeholder="Nama sekolah..."
              value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} />
          </div>
        </div>
        <div className="filter-bar__group">
          <label className="filter-bar__label">Jenjang</label>
          <select className="form-input form-input--sm" value={level}
            onChange={(e) => { setLevel(e.target.value); setPage(1); }}>
            <option value="">Semua</option>
            {LEVELS.map((l) => <option key={l} value={l}>{l}</option>)}
          </select>
        </div>
        {(search || level) && (
          <button className="btn btn--ghost btn--sm" onClick={() => { setSearch(''); setLevel(''); setPage(1); }}>Reset</button>
        )}
      </div>

      {error && <div className="alert alert--error" role="alert">{error}</div>}

      {isLoading ? (
        <div className="loading-box"><div className="spinner" /><p>Memuat data sekolah...</p></div>
      ) : (
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
                        <button className="icon-btn" title="Edit" onClick={() => openEdit(s)}>
                          <Pencil size={15} />
                        </button>
                        <button className="icon-btn icon-btn--danger" title="Hapus" onClick={() => setDeleteItem(s)}>
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
                  disabled={page === 1} onClick={() => setPage((p) => p - 1)}>← Sebelumnya</button>
                <span className="pagination__info">{page} / {totalPages}</span>
                <button id="school-next-page" className="btn btn--ghost btn--sm"
                  disabled={page === totalPages} onClick={() => setPage((p) => p + 1)}>Berikutnya →</button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Modal Tambah/Edit */}
      {(showCreate || editItem !== null) && (
        <SchoolModal
          title={editItem ? `Edit: ${editItem.name}` : 'Tambah Sekolah / Lembaga'}
          form={form} setForm={setForm}
          onSave={handleSave}
          onClose={() => { setShowCreate(false); setEditItem(null); }}
          saving={saving} error={modalError}
        />
      )}

      {/* Modal Hapus */}
      {deleteItem && (
        <DeleteSchoolModal
          school={deleteItem} onConfirm={handleDelete}
          onClose={() => setDeleteItem(null)} deleting={deleting}
        />
      )}
    </div>
  );
}
