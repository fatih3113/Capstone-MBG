import { useEffect, useState, useCallback } from 'react';
import { distributionApi } from '@/api/endpoints';
import { downloadCsv } from '@/api/client';
import type {
  DistributionSummary, SchoolDistribution, DistributionRecord,
  School, FoodOption,
} from '@/types/api.types';
import StatCard from '@/components/ui/StatCard';
import {
  Building2, Calendar, Download, Package, School as SchoolIcon,
  Plus, Pencil, Trash2, X, Check, AlertTriangle,
} from 'lucide-react';

// ── helpers ──────────────────────────────────────────────────────────
function fmtDate(d: string | null | undefined) {
  if (!d) return '—';
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });
}
const LEVEL_COLOR: Record<string, string> = {
  SD: 'badge--blue', SMP: 'badge--green', SMA: 'badge--yellow', SMK: 'badge--purple',
};

// ── sub-types ─────────────────────────────────────────────────────────
interface FormItem { foodId: string; portionGram: number }
interface ScheduleForm { schoolId: string; date: string; items: FormItem[] }
const emptyForm = (): ScheduleForm => ({ schoolId: '', date: '', items: [{ foodId: '', portionGram: 100 }] });

// ── Modal tambah/edit jadwal ──────────────────────────────────────────
function ScheduleModal({
  title, form, setForm, schools, foods, onSave, onClose, saving, error,
}: {
  title: string;
  form: ScheduleForm;
  setForm: (f: ScheduleForm) => void;
  schools: School[];
  foods: FoodOption[];
  onSave: () => void;
  onClose: () => void;
  saving: boolean;
  error: string;
}) {
  const groupedFoods = foods.reduce<Record<string, FoodOption[]>>((acc, f) => {
    (acc[f.category] ??= []).push(f);
    return acc;
  }, {});

  const setItem = (idx: number, key: keyof FormItem, val: string | number) => {
    const items = [...form.items];
    items[idx] = { ...items[idx], [key]: val };
    setForm({ ...form, items });
  };
  const addItem = () => setForm({ ...form, items: [...form.items, { foodId: '', portionGram: 100 }] });
  const removeItem = (idx: number) => setForm({ ...form, items: form.items.filter((_, i) => i !== idx) });

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()} role="dialog" aria-modal="true">
        <div className="modal__header">
          <h2 className="modal__title">{title}</h2>
          <button className="modal__close" onClick={onClose} aria-label="Tutup"><X size={20} /></button>
        </div>

        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '1rem' }}>{error}</div>}

          {/* Sekolah */}
          <div className="form-group">
            <label className="form-label" htmlFor="sched-school">Sekolah *</label>
            <select id="sched-school" className="form-input" value={form.schoolId}
              onChange={(e) => setForm({ ...form, schoolId: e.target.value })}>
              <option value="">— Pilih sekolah —</option>
              {schools.map((s) => (
                <option key={s.id} value={s.id}>{s.name} ({s.level})</option>
              ))}
            </select>
          </div>

          {/* Tanggal */}
          <div className="form-group">
            <label className="form-label" htmlFor="sched-date">Tanggal Distribusi *</label>
            <input id="sched-date" type="date" className="form-input" value={form.date}
              onChange={(e) => setForm({ ...form, date: e.target.value })} />
          </div>

          {/* Menu items */}
          <div className="form-group">
            <label className="form-label">Menu Makanan *</label>
            <div className="menu-items-list">
              {form.items.map((item, idx) => (
                <div key={idx} className="menu-item-row">
                  <select className="form-input flex-1" value={item.foodId}
                    onChange={(e) => setItem(idx, 'foodId', e.target.value)}>
                    <option value="">— Pilih makanan —</option>
                    {Object.entries(groupedFoods).map(([cat, fs]) => (
                      <optgroup key={cat} label={cat}>
                        {fs.map((f) => <option key={f.id} value={f.id}>{f.name}</option>)}
                      </optgroup>
                    ))}
                  </select>
                  <div className="portion-input">
                    <input type="number" className="form-input" value={item.portionGram} min={10} max={500}
                      onChange={(e) => setItem(idx, 'portionGram', +e.target.value)} style={{ width: '80px' }} />
                    <span className="unit-label">g</span>
                  </div>
                  <button className="icon-btn icon-btn--danger" onClick={() => removeItem(idx)}
                    disabled={form.items.length <= 1} title="Hapus item">
                    <Trash2 size={15} />
                  </button>
                </div>
              ))}
              <button className="btn btn--ghost btn--sm" type="button" onClick={addItem}>
                <Plus size={14} /> Tambah Makanan
              </button>
            </div>
          </div>
        </div>

        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={saving}>Batal</button>
          <button id="modal-save-btn" className="btn btn--primary" onClick={onSave} disabled={saving}>
            {saving ? 'Menyimpan...' : <><Check size={16} /> Simpan</>}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Modal konfirmasi hapus ────────────────────────────────────────────
function DeleteModal({ record, onConfirm, onClose, deleting }: {
  record: DistributionRecord; onConfirm: () => void; onClose: () => void; deleting: boolean;
}) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--sm" onClick={(e) => e.stopPropagation()}>
        <div className="modal__header">
          <h2 className="modal__title">Hapus Jadwal</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          <div className="delete-confirm">
            <AlertTriangle size={36} color="#ef4444" />
            <p>Hapus jadwal distribusi <strong>{record.school.name}</strong> pada <strong>{fmtDate(record.date)}</strong>?</p>
            <p className="delete-confirm__sub">Menu yang sudah dibuat tidak dapat dikembalikan.</p>
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={deleting}>Batal</button>
          <button id="modal-delete-confirm-btn" className="btn btn--danger" onClick={onConfirm} disabled={deleting}>
            {deleting ? 'Menghapus...' : <><Trash2 size={15} /> Ya, Hapus</>}
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Halaman utama ─────────────────────────────────────────────────────
export default function DistributionPage() {
  // Data
  const [summary, setSummary]           = useState<DistributionSummary | null>(null);
  const [schools, setSchools]           = useState<SchoolDistribution[]>([]);
  const [timeline, setTimeline]         = useState<DistributionRecord[]>([]);
  const [timelineTotal, setTimelineTotal] = useState(0);
  const [timelinePage, setTimelinePage] = useState(1);
  // CRUD options
  const [allSchools, setAllSchools]     = useState<School[]>([]);
  const [allFoods, setAllFoods]         = useState<FoodOption[]>([]);
  // UI
  const [startDate, setStartDate]       = useState('');
  const [endDate, setEndDate]           = useState('');
  const [activeTab, setActiveTab]       = useState<'schools' | 'timeline'>('schools');
  const [isLoading, setIsLoading]       = useState(true);
  const [error, setError]               = useState('');
  // Modal state
  const [showCreate, setShowCreate]     = useState(false);
  const [editRecord, setEditRecord]     = useState<DistributionRecord | null>(null);
  const [deleteRecord, setDeleteRecord] = useState<DistributionRecord | null>(null);
  const [form, setForm]                 = useState<ScheduleForm>(emptyForm());
  const [saving, setSaving]             = useState(false);
  const [deleting, setDeleting]         = useState(false);
  const [modalError, setModalError]     = useState('');
  const LIMIT = 15;

  // Muat data utama
  const load = useCallback(async () => {
    setIsLoading(true); setError('');
    const params = { startDate: startDate || undefined, endDate: endDate || undefined };
    try {
      const [sumRes, schoolRes, timeRes] = await Promise.all([
        distributionApi.summary(params),
        distributionApi.perSchool(params),
        distributionApi.timeline({ ...params, page: timelinePage, limit: LIMIT }),
      ]);
      setSummary(sumRes.data.data);
      setSchools(schoolRes.data.data);
      setTimeline(timeRes.data.data.records);
      setTimelineTotal(timeRes.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data distribusi');
    } finally { setIsLoading(false); }
  }, [startDate, endDate, timelinePage]);

  // Muat dropdown options (sekali saja)
  useEffect(() => {
    distributionApi.getSchools().then((r) => setAllSchools(r.data.data)).catch(() => {});
    distributionApi.getFoods().then((r) => setAllFoods(r.data.data)).catch(() => {});
  }, []);

  useEffect(() => { load(); }, [load]);

  // ── Handlers CRUD ────────────────────────────────────────────
  const openCreate = () => { setForm(emptyForm()); setModalError(''); setShowCreate(true); };

  const openEdit = (rec: DistributionRecord) => {
    setEditRecord(rec);
    setModalError('');
    // Cari schoolId dari allSchools berdasarkan nama
    const school = allSchools.find((s) => s.name === rec.school.name);
    setForm({
      schoolId: school?.id ?? '',
      date: rec.date,
      items: rec.foods.map((f) => {
        const food = allFoods.find((fd) => fd.name === f.name);
        return { foodId: food?.id ?? '', portionGram: f.portionGram };
      }),
    });
  };

  const handleSave = async () => {
    if (!form.schoolId || !form.date) { setModalError('Sekolah dan tanggal wajib diisi.'); return; }
    if (form.items.some((i) => !i.foodId)) { setModalError('Semua baris makanan harus dipilih.'); return; }
    setSaving(true); setModalError('');
    try {
      let res;
      if (editRecord) {
        res = await distributionApi.updateSchedule(editRecord.id, form);
      } else {
        res = await distributionApi.createSchedule(form);
      }
      if (!res.data.success) { setModalError(res.data.message); setSaving(false); return; }
      setShowCreate(false); setEditRecord(null);
      load();
    } catch (err: any) {
      setModalError(err?.response?.data?.message ?? 'Gagal menyimpan jadwal.');
    } finally { setSaving(false); }
  };

  const handleDelete = async () => {
    if (!deleteRecord) return;
    setDeleting(true);
    try {
      await distributionApi.deleteSchedule(deleteRecord.id);
      setDeleteRecord(null);
      load();
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal menghapus jadwal.');
      setDeleteRecord(null);
    } finally { setDeleting(false); }
  };

  const totalPages = Math.ceil(timelineTotal / LIMIT);

  return (
    <div className="page">
      {/* Header */}
      <div className="page__header">
        <div>
          <h1 className="page__title">Distribusi MBG ke Sekolah</h1>
          <p className="page__subtitle">Pantau & kelola pengiriman Makan Bergizi Gratis — siap audit</p>
        </div>
        <div style={{ display: 'flex', gap: '.75rem' }}>
          <button id="distribution-export-btn" className="btn btn--outline" onClick={() => {
            const p: Record<string, string> = {};
            if (startDate) p.startDate = startDate;
            if (endDate) p.endDate = endDate;
            downloadCsv('/distribution/export', 'distribusi_mbg.csv', p);
          }}>
            <Download size={16} /> Ekspor CSV
          </button>
          <button id="distribution-add-btn" className="btn btn--primary" onClick={openCreate}>
            <Plus size={16} /> Tambah Jadwal
          </button>
        </div>
      </div>

      {/* Filter */}
      <div className="filter-bar">
        <div className="filter-bar__group">
          <label htmlFor="dist-start" className="filter-bar__label">Dari</label>
          <input id="dist-start" type="date" className="form-input form-input--sm" value={startDate}
            onChange={(e) => { setStartDate(e.target.value); setTimelinePage(1); }} />
        </div>
        <div className="filter-bar__group">
          <label htmlFor="dist-end" className="filter-bar__label">Sampai</label>
          <input id="dist-end" type="date" className="form-input form-input--sm" value={endDate}
            onChange={(e) => { setEndDate(e.target.value); setTimelinePage(1); }} />
        </div>
        {(startDate || endDate) && (
          <button className="btn btn--ghost btn--sm" onClick={() => { setStartDate(''); setEndDate(''); setTimelinePage(1); }}>
            Reset
          </button>
        )}
      </div>

      {error && <div className="alert alert--error" role="alert">{error}</div>}

      {/* Stat cards */}
      {summary && (
        <div className="stat-grid">
          <StatCard label="Sekolah Tercakup" value={summary.totalSchoolsCovered} icon={<SchoolIcon size={22} />} color="blue" />
          <StatCard label="Total Jadwal Menu" value={summary.totalMenuSchedules} icon={<Calendar size={22} />} color="green" />
          <StatCard label="Total Item Makanan" value={summary.totalFoodItems} icon={<Package size={22} />} color="orange" />
          <StatCard
            label="Rentang Tanggal"
            value={`${fmtDate(summary.dateRange.earliest)} — ${fmtDate(summary.dateRange.latest)}`}
            icon={<Building2 size={22} />} color="purple"
          />
        </div>
      )}

      {/* Tabs */}
      <div className="tab-bar">
        <button id="tab-schools" className={`tab-bar__tab ${activeTab === 'schools' ? 'tab-bar__tab--active' : ''}`}
          onClick={() => setActiveTab('schools')}>
          <SchoolIcon size={16} /> Per Sekolah
        </button>
        <button id="tab-timeline" className={`tab-bar__tab ${activeTab === 'timeline' ? 'tab-bar__tab--active' : ''}`}
          onClick={() => setActiveTab('timeline')}>
          <Calendar size={16} /> Linimasa Distribusi
        </button>
      </div>

      {isLoading ? (
        <div className="loading-box"><div className="spinner" /><p>Memuat data distribusi...</p></div>
      ) : activeTab === 'schools' ? (
        // ── TAB Per Sekolah ──────────────────────────────────────
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
      ) : (
        // ── TAB Linimasa ─────────────────────────────────────────
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
                        <button className="icon-btn" title="Edit jadwal" onClick={() => openEdit(rec)}>
                          <Pencil size={15} />
                        </button>
                        <button className="icon-btn icon-btn--danger" title="Hapus jadwal" onClick={() => setDeleteRecord(rec)}>
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
                disabled={timelinePage === 1} onClick={() => setTimelinePage((p) => p - 1)}>
                ← Sebelumnya
              </button>
              <span className="pagination__info">Halaman {timelinePage} / {totalPages}</span>
              <button id="dist-next-page" className="btn btn--ghost btn--sm"
                disabled={timelinePage === totalPages} onClick={() => setTimelinePage((p) => p + 1)}>
                Berikutnya →
              </button>
            </div>
          )}
        </div>
      )}

      {/* Modal Tambah / Edit */}
      {(showCreate || editRecord !== null) && (
        <ScheduleModal
          title={editRecord ? 'Edit Jadwal Distribusi' : 'Tambah Jadwal Distribusi'}
          form={form} setForm={setForm}
          schools={allSchools} foods={allFoods}
          onSave={handleSave}
          onClose={() => { setShowCreate(false); setEditRecord(null); }}
          saving={saving} error={modalError}
        />
      )}

      {/* Modal Hapus */}
      {deleteRecord && (
        <DeleteModal
          record={deleteRecord}
          onConfirm={handleDelete}
          onClose={() => setDeleteRecord(null)}
          deleting={deleting}
        />
      )}
    </div>
  );
}
