import { useState, useEffect, useCallback } from 'react';
import {
  MapPin, Building2, Users, Globe, ChevronDown, ChevronRight,
  Plus, Pencil, Trash2, RefreshCw, Search, X, Check, Star,
} from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Cell,
} from 'recharts';
import { sppgApi } from '@/api/endpoints';
import type { SppgItem, SppgRegionSummary, SppgProvinsi } from '@/types/api.types';

// ── Warna chart ────────────────────────────────────────────────────────────
const CHART_COLORS = [
  '#6366f1', '#8b5cf6', '#a855f7', '#ec4899', '#f43f5e',
  '#f97316', '#eab308', '#22c55e', '#14b8a6', '#0ea5e9',
];

// ── StatCard Component ─────────────────────────────────────────────────────
function StatCard({ label, value, icon: Icon, color }: {
  label: string; value: string | number;
  icon: React.FC<any>; color: string;
}) {
  return (
    <div className="stat-card">
      <div className="stat-card__icon" style={{ background: color }}>
        <Icon size={20} color="#fff" />
      </div>
      <div className="stat-card__body">
        <p className="stat-card__label">{label}</p>
        <p className="stat-card__value">{value.toLocaleString('id-ID')}</p>
      </div>
    </div>
  );
}

// ── Main Page ──────────────────────────────────────────────────────────────
export default function SppgRegionsPage() {
  const [summary, setSummary] = useState<SppgRegionSummary | null>(null);
  const [sppgList, setSppgList] = useState<SppgItem[]>([]);
  const [total, setTotal] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filter state
  const [search, setSearch] = useState('');
  const [filterProvinsi, setFilterProvinsi] = useState('');
  const [filterKabupaten, setFilterKabupaten] = useState('');
  const [filterActive, setFilterActive] = useState('');
  const [page, setPage] = useState(1);
  const LIMIT = 15;

  // Expanded rows in region tree
  const [expandedProvinsi, setExpandedProvinsi] = useState<Set<string>>(new Set());
  const [expandedKabupaten, setExpandedKabupaten] = useState<Set<string>>(new Set());

  // Modal state
  const [modal, setModal] = useState<'add' | 'edit' | 'delete' | null>(null);
  const [selected, setSelected] = useState<SppgItem | null>(null);

  // ── Load data ──────────────────────────────────────────────────────────
  const loadSummary = useCallback(async () => {
    try {
      const res = await sppgApi.regionsSummary();
      if (res.data.success) setSummary(res.data.data);
    } catch (_) {}
  }, []);

  const loadList = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params: any = { page, limit: LIMIT };
      if (search) params.search = search;
      if (filterProvinsi) params.provinsi = filterProvinsi;
      if (filterKabupaten) params.kabupatenKota = filterKabupaten;
      if (filterActive) params.isActive = filterActive;

      const res = await sppgApi.list(params);
      if (res.data.success) {
        setSppgList(res.data.data.records);
        setTotal(res.data.data.total);
        setTotalPages(res.data.data.totalPages);
      }
    } catch (e: any) {
      setError('Gagal memuat data SPPG. Coba lagi.');
    } finally {
      setLoading(false);
    }
  }, [search, filterProvinsi, filterKabupaten, filterActive, page]);

  useEffect(() => { loadSummary(); }, [loadSummary]);
  useEffect(() => { loadList(); }, [loadList]);

  const handleDelete = async () => {
    if (!selected) return;
    try {
      const res = await sppgApi.delete(selected.id);
      if (res.data.success) {
        setModal(null);
        setSelected(null);
        loadList();
        loadSummary();
      } else {
        alert(res.data.message || 'Gagal menghapus SPPG');
      }
    } catch (e: any) {
      alert(e?.response?.data?.message || 'Gagal menghapus SPPG');
    }
  };

  // Chart data: top provinces by SPPG count
  const chartData = (summary?.wilayah ?? [])
    .sort((a, b) => b.jumlahSppg - a.jumlahSppg)
    .slice(0, 8)
    .map((p) => ({
      name: p.provinsi.replace('Kepulauan ', 'Kep. '),
      sppg: p.jumlahSppg,
      siswa: p.jumlahSiswaTerdaftar,
    }));

  const allProvinces = [...new Set((summary?.wilayah ?? []).map((w) => w.provinsi))];

  return (
    <div className="page">
      {/* ── Header ────────────────────────────────────────────────── */}
      <div className="page__header">
        <div>
          <h1 className="page__title">
            <MapPin size={24} style={{ display: 'inline', marginRight: 8, verticalAlign: 'middle' }} />
            Wilayah SPPG
          </h1>
          <p className="page__subtitle">
            Satuan Pelayanan Pemenuhan Gizi — sebaran wilayah dan statistik
          </p>
        </div>
        <button className="btn btn--primary" onClick={() => { setSelected(null); setModal('add'); }}>
          <Plus size={16} /> Tambah SPPG
        </button>
      </div>

      {/* ── StatCards ─────────────────────────────────────────────── */}
      <div className="stats-grid stats-grid--4" style={{ marginBottom: 24 }}>
        <StatCard label="Total SPPG" value={summary?.summary.totalSppg ?? 0}
          icon={MapPin} color="hsl(251,89%,60%)" />
        <StatCard label="Provinsi Terjangkau" value={summary?.summary.totalProvinsi ?? 0}
          icon={Globe} color="hsl(210,89%,55%)" />
        <StatCard label="Kab/Kota Terjangkau" value={summary?.summary.totalKabupaten ?? 0}
          icon={Building2} color="hsl(142,71%,45%)" />
        <StatCard label="Total Siswa Terdaftar" value={summary?.summary.totalSiswa ?? 0}
          icon={Users} color="hsl(25,95%,55%)" />
      </div>

      {/* ── Charts ────────────────────────────────────────────────── */}
      {chartData.length > 0 && (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginBottom: 24 }}>
          {/* SPPG per Provinsi */}
          <div className="card">
            <div className="card__header">
              <h3 className="card__title">Jumlah SPPG per Provinsi</h3>
            </div>
            <div className="card__body">
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={chartData} margin={{ top: 5, right: 20, left: -10, bottom: 40 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(220,13%,91%)" />
                  <XAxis dataKey="name" tick={{ fontSize: 11 }} angle={-30} textAnchor="end" interval={0} />
                  <YAxis tick={{ fontSize: 12 }} allowDecimals={false} />
                  <Tooltip formatter={(v) => [v, 'SPPG']} />
                  <Bar dataKey="sppg" radius={[4, 4, 0, 0]}>
                    {chartData.map((_, i) => (
                      <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Siswa per Provinsi */}
          <div className="card">
            <div className="card__header">
              <h3 className="card__title">Siswa Terdaftar per Provinsi</h3>
            </div>
            <div className="card__body">
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={chartData} margin={{ top: 5, right: 20, left: -10, bottom: 40 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(220,13%,91%)" />
                  <XAxis dataKey="name" tick={{ fontSize: 11 }} angle={-30} textAnchor="end" interval={0} />
                  <YAxis tick={{ fontSize: 12 }} allowDecimals={false} />
                  <Tooltip formatter={(v) => [v, 'Siswa']} />
                  <Bar dataKey="siswa" radius={[4, 4, 0, 0]}>
                    {chartData.map((_, i) => (
                      <Cell key={i} fill={CHART_COLORS[(i + 5) % CHART_COLORS.length]} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      )}

      {/* ── Region Tree ───────────────────────────────────────────── */}
      {(summary?.wilayah ?? []).length > 0 && (
        <div className="card" style={{ marginBottom: 24 }}>
          <div className="card__header">
            <h3 className="card__title">Hierarki Wilayah</h3>
          </div>
          <div className="card__body" style={{ padding: 0 }}>
            {summary!.wilayah.map((prov) => (
              <RegionProvinsiRow
                key={prov.provinsi}
                prov={prov}
                expanded={expandedProvinsi.has(prov.provinsi)}
                expandedKab={expandedKabupaten}
                onToggleProv={() => {
                  setExpandedProvinsi((prev) => {
                    const next = new Set(prev);
                    next.has(prov.provinsi) ? next.delete(prov.provinsi) : next.add(prov.provinsi);
                    return next;
                  });
                }}
                onToggleKab={(kab) => {
                  setExpandedKabupaten((prev) => {
                    const next = new Set(prev);
                    next.has(kab) ? next.delete(kab) : next.add(kab);
                    return next;
                  });
                }}
              />
            ))}
          </div>
        </div>
      )}

      {/* ── SPPG Table dengan Filter ───────────────────────────────── */}
      <div className="card">
        <div className="card__header">
          <h3 className="card__title">Daftar SPPG ({total})</h3>
        </div>
        <div className="card__body">
          {/* Filter bar */}
          <div className="filter-bar" style={{ marginBottom: 16 }}>
            <div className="search-box">
              <Search size={16} className="search-box__icon" />
              <input
                className="search-box__input"
                placeholder="Cari nama/kode SPPG..."
                value={search}
                onChange={(e) => { setSearch(e.target.value); setPage(1); }}
              />
              {search && (
                <button className="search-box__clear" onClick={() => { setSearch(''); setPage(1); }}>
                  <X size={14} />
                </button>
              )}
            </div>
            <select
              className="filter-select"
              value={filterProvinsi}
              onChange={(e) => { setFilterProvinsi(e.target.value); setFilterKabupaten(''); setPage(1); }}
            >
              <option value="">Semua Provinsi</option>
              {allProvinces.map((p) => <option key={p} value={p}>{p}</option>)}
            </select>
            <select
              className="filter-select"
              value={filterActive}
              onChange={(e) => { setFilterActive(e.target.value); setPage(1); }}
            >
              <option value="">Semua Status</option>
              <option value="true">Aktif</option>
              <option value="false">Nonaktif</option>
            </select>
            <button className="btn btn--ghost btn--sm" onClick={loadList} title="Refresh">
              <RefreshCw size={15} />
            </button>
          </div>

          {/* Table */}
          {loading ? (
            <div className="loading-state"><RefreshCw size={20} className="spin" /> Memuat data...</div>
          ) : error ? (
            <div className="empty-state">
              <p>{error}</p>
              <button className="btn btn--primary btn--sm" onClick={loadList}>Coba Lagi</button>
            </div>
          ) : sppgList.length === 0 ? (
            <div className="empty-state"><MapPin size={32} /><p>Belum ada data SPPG</p></div>
          ) : (
            <>
              <div className="table-wrapper">
                <table className="table">
                  <thead>
                    <tr>
                      <th>Kode</th>
                      <th>Nama SPPG</th>
                      <th>Provinsi</th>
                      <th>Kab/Kota</th>
                      <th>Kecamatan</th>
                      <th>Siswa</th>
                      <th>Sekolah</th>
                      <th>Status</th>
                      <th>Aksi</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sppgList.map((s) => (
                      <tr key={s.id}>
                        <td><code style={{ fontSize: 12 }}>{s.kode ?? '-'}</code></td>
                        <td><strong>{s.nama}</strong></td>
                        <td>{s.provinsi}</td>
                        <td>{s.kabupatenKota}</td>
                        <td>{s.kecamatan}</td>
                        <td>
                          <span className="badge badge--info">{s._count.users}</span>
                        </td>
                        <td>
                          <span className="badge badge--neutral">{s._count.schools}</span>
                        </td>
                        <td>
                          <span className={`badge ${s.isActive ? 'badge--success' : 'badge--warning'}`}>
                            {s.isActive ? 'Aktif' : 'Nonaktif'}
                          </span>
                        </td>
                        <td>
                          <div className="action-buttons">
                            <button
                              className="btn btn--ghost btn--icon"
                              title="Edit"
                              onClick={() => { setSelected(s); setModal('edit'); }}
                            >
                              <Pencil size={14} />
                            </button>
                            <button
                              className="btn btn--ghost btn--icon btn--danger"
                              title="Hapus"
                              onClick={() => { setSelected(s); setModal('delete'); }}
                            >
                              <Trash2 size={14} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="pagination">
                  <button
                    className="btn btn--ghost btn--sm"
                    disabled={page === 1}
                    onClick={() => setPage((p) => p - 1)}
                  >
                    ← Sebelumnya
                  </button>
                  <span className="pagination__info">
                    Halaman {page} dari {totalPages} ({total} total)
                  </span>
                  <button
                    className="btn btn--ghost btn--sm"
                    disabled={page === totalPages}
                    onClick={() => setPage((p) => p + 1)}
                  >
                    Berikutnya →
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {/* ── Modal Tambah/Edit ──────────────────────────────────────── */}
      {(modal === 'add' || modal === 'edit') && (
        <SppgFormModal
          mode={modal}
          initial={selected}
          onClose={() => { setModal(null); setSelected(null); }}
          onSuccess={() => { setModal(null); setSelected(null); loadList(); loadSummary(); }}
        />
      )}

      {/* ── Modal Hapus ───────────────────────────────────────────── */}
      {modal === 'delete' && selected && (
        <div className="modal-overlay" onClick={() => setModal(null)}>
          <div className="modal modal--sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal__header">
              <h2 className="modal__title">Hapus SPPG</h2>
              <button className="modal__close" onClick={() => setModal(null)}><X size={18} /></button>
            </div>
            <div className="modal__body">
              <div className="delete-confirm">
                <Trash2 size={40} color="hsl(0,84%,60%)" />
                <p>Yakin ingin menghapus <strong>{selected.nama}</strong>?</p>
                {(selected._count.users > 0 || selected._count.schools > 0) && (
                  <div className="alert alert--warning" style={{ marginTop: 12 }}>
                    ⚠️ SPPG ini memiliki {selected._count.users} pengguna dan {selected._count.schools} sekolah.
                    Hapus tidak dapat dilakukan sampai semua relasi dilepas.
                  </div>
                )}
              </div>
            </div>
            <div className="modal__footer">
              <button className="btn btn--ghost" onClick={() => setModal(null)}>Batal</button>
              <button
                className="btn btn--danger"
                onClick={handleDelete}
                disabled={selected._count.users > 0 || selected._count.schools > 0}
              >
                Hapus
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Region Tree Row ─────────────────────────────────────────────────────────

function RegionProvinsiRow({ prov, expanded, expandedKab, onToggleProv, onToggleKab }: {
  prov: SppgProvinsi;
  expanded: boolean;
  expandedKab: Set<string>;
  onToggleProv: () => void;
  onToggleKab: (kab: string) => void;
}) {
  return (
    <>
      <div
        className="region-row region-row--provinsi"
        onClick={onToggleProv}
        style={{ cursor: 'pointer', padding: '12px 20px', display: 'flex', alignItems: 'center', gap: 10,
          borderBottom: '1px solid hsl(220,13%,91%)', background: 'hsl(251,89%,97%)' }}
      >
        {expanded ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
        <Globe size={16} color="hsl(251,89%,60%)" />
        <strong style={{ flex: 1 }}>{prov.provinsi}</strong>
        <span className="badge badge--info" style={{ marginRight: 8 }}>{prov.jumlahSppg} SPPG</span>
        <span className="badge badge--neutral">{prov.jumlahSekolah} Sekolah</span>
        <span className="badge badge--success" style={{ marginLeft: 8 }}>
          {prov.jumlahSiswaTerdaftar.toLocaleString('id-ID')} Siswa
        </span>
      </div>
      {expanded && prov.kabupatenList.map((kab) => (
        <div key={kab.kabupatenKota}>
          <div
            className="region-row region-row--kabupaten"
            onClick={() => onToggleKab(kab.kabupatenKota)}
            style={{ cursor: 'pointer', padding: '10px 20px 10px 48px', display: 'flex', alignItems: 'center',
              gap: 10, borderBottom: '1px solid hsl(220,13%,93%)', background: 'hsl(0,0%,98%)' }}
          >
            {expandedKab.has(kab.kabupatenKota) ? <ChevronDown size={14} /> : <ChevronRight size={14} />}
            <Building2 size={14} color="hsl(210,89%,55%)" />
            <span style={{ flex: 1 }}>{kab.kabupatenKota}</span>
            <span className="badge badge--info">{kab.jumlahSppg} SPPG</span>
          </div>
          {expandedKab.has(kab.kabupatenKota) && kab.kecamatanList.map((kec) => (
            <div key={kec.kecamatan}>
              <div style={{ padding: '8px 20px 8px 80px', borderBottom: '1px solid hsl(220,13%,95%)',
                background: 'hsl(0,0%,99%)', display: 'flex', alignItems: 'center', gap: 10 }}>
                <MapPin size={13} color="hsl(142,71%,45%)" />
                <span style={{ flex: 1, fontSize: 13 }}>{kec.kecamatan}</span>
                <span className="badge badge--neutral" style={{ fontSize: 11 }}>{kec.jumlahSppg} SPPG</span>
              </div>
              {kec.sppgList.map((s) => (
                <div key={s.id} style={{ padding: '6px 20px 6px 110px', borderBottom: '1px solid hsl(220,13%,96%)',
                  fontSize: 13, display: 'flex', alignItems: 'center', gap: 8, color: 'hsl(220,13%,46%)' }}>
                  <span style={{ flex: 1 }}>
                    {s.nama}
                    {s.kode && <code style={{ fontSize: 11, marginLeft: 8, color: 'hsl(251,89%,60%)' }}>
                      {s.kode}</code>}
                  </span>
                  <span title="Siswa"><Users size={12} /> {s.jumlahSiswaTerdaftar}</span>
                  {s.rataRataRating && (
                    <span title="Rata-rata rating">
                      <Star size={12} color="hsl(40,95%,55%)" fill="hsl(40,95%,55%)" /> {s.rataRataRating.toFixed(1)}
                    </span>
                  )}
                </div>
              ))}
            </div>
          ))}
        </div>
      ))}
    </>
  );
}

// ── SPPG Form Modal ─────────────────────────────────────────────────────────

const PROVINSI_OPTIONS = [
  'Aceh','Sumatera Utara','Sumatera Barat','Riau','Kepulauan Riau','Jambi',
  'Sumatera Selatan','Kepulauan Bangka Belitung','Bengkulu','Lampung',
  'DKI Jakarta','Jawa Barat','Banten','Jawa Tengah','DI Yogyakarta','Jawa Timur',
  'Bali','Nusa Tenggara Barat','Nusa Tenggara Timur',
  'Kalimantan Barat','Kalimantan Tengah','Kalimantan Selatan','Kalimantan Timur','Kalimantan Utara',
  'Sulawesi Utara','Sulawesi Tengah','Sulawesi Selatan','Sulawesi Tenggara','Gorontalo','Sulawesi Barat',
  'Maluku','Maluku Utara','Papua Barat','Papua Barat Daya','Papua','Papua Tengah','Papua Pegunungan','Papua Selatan',
];

interface FormState {
  nama: string; kode: string; provinsi: string;
  kabupatenKota: string; kecamatan: string; kelurahanDesa: string;
  alamat: string; latitude: string; longitude: string; isActive: boolean;
}

const EMPTY_FORM: FormState = {
  nama: '', kode: '', provinsi: '', kabupatenKota: '',
  kecamatan: '', kelurahanDesa: '', alamat: '',
  latitude: '', longitude: '', isActive: true,
};

function SppgFormModal({ mode, initial, onClose, onSuccess }: {
  mode: 'add' | 'edit';
  initial: SppgItem | null;
  onClose: () => void;
  onSuccess: () => void;
}) {
  const [form, setForm] = useState<FormState>(() =>
    initial
      ? {
          nama: initial.nama, kode: initial.kode ?? '',
          provinsi: initial.provinsi, kabupatenKota: initial.kabupatenKota,
          kecamatan: initial.kecamatan, kelurahanDesa: initial.kelurahanDesa,
          alamat: initial.alamat ?? '', latitude: String(initial.latitude ?? ''),
          longitude: String(initial.longitude ?? ''), isActive: initial.isActive,
        }
      : EMPTY_FORM
  );
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const set = (k: keyof FormState, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.nama || !form.provinsi || !form.kabupatenKota || !form.kecamatan || !form.kelurahanDesa) {
      setErr('Harap isi semua field yang wajib (*)');
      return;
    }
    setSaving(true);
    setErr(null);
    try {
      const payload: any = {
        nama: form.nama, provinsi: form.provinsi,
        kabupatenKota: form.kabupatenKota, kecamatan: form.kecamatan,
        kelurahanDesa: form.kelurahanDesa, isActive: form.isActive,
      };
      if (form.kode) payload.kode = form.kode;
      if (form.alamat) payload.alamat = form.alamat;
      if (form.latitude) payload.latitude = parseFloat(form.latitude);
      if (form.longitude) payload.longitude = parseFloat(form.longitude);

      if (mode === 'add') {
        const res = await sppgApi.create(payload);
        if (!res.data.success) { setErr(res.data.message); return; }
      } else {
        const res = await sppgApi.update(initial!.id, payload);
        if (!res.data.success) { setErr(res.data.message); return; }
      }
      onSuccess();
    } catch (e: any) {
      setErr(e?.response?.data?.message || 'Terjadi kesalahan, coba lagi.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--lg" onClick={(e) => e.stopPropagation()}>
        <div className="modal__header">
          <h2 className="modal__title">
            {mode === 'add' ? 'Tambah SPPG Baru' : `Edit SPPG — ${initial?.nama}`}
          </h2>
          <button className="modal__close" onClick={onClose}><X size={18} /></button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="modal__body">
            {err && <div className="alert alert--error" style={{ marginBottom: 16 }}>{err}</div>}
            <div className="form-grid form-grid--2">
              <div className="form-group">
                <label className="form-label">Nama SPPG *</label>
                <input className="form-input" value={form.nama}
                  onChange={(e) => set('nama', e.target.value)} placeholder="Nama SPPG" required />
              </div>
              <div className="form-group">
                <label className="form-label">Kode SPPG</label>
                <input className="form-input" value={form.kode}
                  onChange={(e) => set('kode', e.target.value)} placeholder="mis. SPPG-3374-001" />
              </div>
              <div className="form-group">
                <label className="form-label">Provinsi *</label>
                <select className="form-input" value={form.provinsi}
                  onChange={(e) => set('provinsi', e.target.value)} required>
                  <option value="">Pilih provinsi</option>
                  {PROVINSI_OPTIONS.map((p) => <option key={p} value={p}>{p}</option>)}
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Kabupaten / Kota *</label>
                <input className="form-input" value={form.kabupatenKota}
                  onChange={(e) => set('kabupatenKota', e.target.value)} placeholder="mis. Kota Semarang" required />
              </div>
              <div className="form-group">
                <label className="form-label">Kecamatan *</label>
                <input className="form-input" value={form.kecamatan}
                  onChange={(e) => set('kecamatan', e.target.value)} placeholder="mis. Banyumanik" required />
              </div>
              <div className="form-group">
                <label className="form-label">Kelurahan / Desa *</label>
                <input className="form-input" value={form.kelurahanDesa}
                  onChange={(e) => set('kelurahanDesa', e.target.value)} placeholder="mis. Ngesrep" required />
              </div>
              <div className="form-group form-group--full">
                <label className="form-label">Alamat Lengkap</label>
                <input className="form-input" value={form.alamat}
                  onChange={(e) => set('alamat', e.target.value)} placeholder="Jl. ..." />
              </div>
              <div className="form-group">
                <label className="form-label">Latitude</label>
                <input className="form-input" type="number" step="any" value={form.latitude}
                  onChange={(e) => set('latitude', e.target.value)} placeholder="-6.9932" />
              </div>
              <div className="form-group">
                <label className="form-label">Longitude</label>
                <input className="form-input" type="number" step="any" value={form.longitude}
                  onChange={(e) => set('longitude', e.target.value)} placeholder="110.4229" />
              </div>
              <div className="form-group form-group--full">
                <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
                  <input type="checkbox" checked={form.isActive}
                    onChange={(e) => set('isActive', e.target.checked)} />
                  <span className="form-label" style={{ margin: 0 }}>SPPG Aktif</span>
                </label>
              </div>
            </div>
          </div>
          <div className="modal__footer">
            <button type="button" className="btn btn--ghost" onClick={onClose}>Batal</button>
            <button type="submit" className="btn btn--primary" disabled={saving}>
              {saving ? 'Menyimpan...' : (mode === 'add' ? 'Tambah SPPG' : 'Simpan Perubahan')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
