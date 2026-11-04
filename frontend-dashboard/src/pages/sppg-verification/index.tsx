import { useCallback, useEffect, useState } from 'react';
import { Search, Check, X, Eye } from 'lucide-react';
import { sppgVerificationApi } from '@/api/endpoints';
import type { AccountStatus, SppgApplication } from '@/types/api.types';
import '@/styles/sppg-access.css';

const TABS: { key: AccountStatus; label: string }[] = [
  { key: 'PENDING', label: 'Menunggu' },
  { key: 'ACTIVE', label: 'Disetujui' },
  { key: 'REJECTED', label: 'Ditolak' },
];

const BADGE: Record<AccountStatus, { label: string; cls: string }> = {
  PENDING:  { label: 'Menunggu', cls: 'badge--considered' },
  ACTIVE:   { label: 'Disetujui', cls: 'badge--approved' },
  REJECTED: { label: 'Ditolak', cls: 'badge--rejected' },
};

const LIMIT = 15;

const fmtDate = (d: string) =>
  new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });

export default function SppgVerificationPage() {
  const [tab, setTab] = useState<AccountStatus>('PENDING');
  const [records, setRecords] = useState<SppgApplication[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  const [detail, setDetail] = useState<SppgApplication | null>(null);
  const [rejecting, setRejecting] = useState<SppgApplication | null>(null);
  const [reason, setReason] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);

  const load = useCallback(async () => {
    setIsLoading(true);
    setError('');
    try {
      const res = await sppgVerificationApi.list({
        status: tab, search: search || undefined, page, limit: LIMIT,
      });
      setRecords(res.data.data.records);
      setTotal(res.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data pendaftaran');
    } finally {
      setIsLoading(false);
    }
  }, [tab, search, page]);

  useEffect(() => { load(); }, [load]);

  const totalPages = Math.max(1, Math.ceil(total / LIMIT));

  const approve = async (app: SppgApplication) => {
    if (!window.confirm(`Setujui akun "${app.name}" untuk SPPG "${app.sppg?.nama ?? '-'}"?`)) return;
    setBusyId(app.id);
    try {
      await sppgVerificationApi.approve(app.id);
      setDetail(null);
      await load();
    } catch (err: any) {
      alert(err?.response?.data?.message ?? 'Gagal menyetujui akun');
    } finally {
      setBusyId(null);
    }
  };

  const submitReject = async () => {
    if (!rejecting) return;
    if (reason.trim().length < 5) { alert('Alasan penolakan minimal 5 karakter.'); return; }
    setBusyId(rejecting.id);
    try {
      await sppgVerificationApi.reject(rejecting.id, reason.trim());
      setRejecting(null);
      setReason('');
      setDetail(null);
      await load();
    } catch (err: any) {
      const msg = err?.response?.data?.message;
      alert(Array.isArray(msg) ? msg.join('. ') : msg ?? 'Gagal menolak pendaftaran');
    } finally {
      setBusyId(null);
    }
  };

  const changeTab = (key: AccountStatus) => { setTab(key); setPage(1); };

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Verifikasi Akun SPPG</h1>
          <p className="page__subtitle">
            Periksa dan setujui pendaftaran akun Admin SPPG dari tiap daerah
          </p>
        </div>
      </div>

      {/* Tab status */}
      <div className="tab-bar" role="tablist" aria-label="Status pendaftaran">
        {TABS.map((t) => (
          <button
            key={t.key}
            role="tab"
            aria-selected={tab === t.key}
            className={`tab-bar__tab ${tab === t.key ? 'tab-bar__tab--active' : ''}`}
            onClick={() => changeTab(t.key)}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* Pencarian */}
      <div className="filter-bar">
        <div className="search-input-wrap">
          <Search size={16} className="search-icon" />
          <input
            className="search-input"
            placeholder="Cari nama, email, SPPG, atau kabupaten/kota..."
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            onKeyDown={(e) => { if (e.key === 'Enter') { setSearch(searchInput); setPage(1); } }}
          />
        </div>
        <button className="btn btn--primary btn--sm" onClick={() => { setSearch(searchInput); setPage(1); }}>
          Cari
        </button>
      </div>

      {error && <div className="alert alert--error">{error}</div>}

      <div className="table-card">
        <div className="table-wrapper">
          <table className="data-table">
            <thead>
              <tr>
                <th>Tgl. Daftar</th><th>Pendaftar</th><th>SPPG</th>
                <th>Wilayah</th><th>Kontak</th><th>Status</th><th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr><td colSpan={7} style={{ textAlign: 'center', color: '#6b7280' }}>Memuat...</td></tr>
              ) : records.length === 0 ? (
                <tr><td colSpan={7} style={{ textAlign: 'center', color: '#6b7280' }}>
                  Tidak ada pendaftaran {BADGE[tab].label.toLowerCase()}
                </td></tr>
              ) : records.map((r) => (
                <tr key={r.id}>
                  <td>{fmtDate(r.createdAt)}</td>
                  <td>
                    <strong>{r.name}</strong>
                    <span className="verif-cell-sub">{r.email}</span>
                  </td>
                  <td>
                    <strong>{r.sppg?.nama ?? '—'}</strong>
                    {r.sppg?.kapasitasPorsi != null && (
                      <span className="verif-cell-sub">{r.sppg.kapasitasPorsi} porsi/hari</span>
                    )}
                  </td>
                  <td>
                    {r.sppg ? `${r.sppg.kabupatenKota}, ${r.sppg.provinsi}` : '—'}
                    {r.sppg && <span className="verif-cell-sub">Kec. {r.sppg.kecamatan}</span>}
                  </td>
                  <td>
                    {r.sppg?.penanggungjawab ?? '—'}
                    <span className="verif-cell-sub">{r.sppg?.kontak ?? ''}</span>
                  </td>
                  <td><span className={`badge ${BADGE[r.accountStatus].cls}`}>{BADGE[r.accountStatus].label}</span></td>
                  <td>
                    <div className="verif-actions">
                      <button className="btn btn--ghost btn--sm" onClick={() => setDetail(r)}>
                        <Eye size={14} /> Detail
                      </button>
                      {r.accountStatus !== 'ACTIVE' && (
                        <button className="btn btn--primary btn--sm" disabled={busyId === r.id}
                          onClick={() => approve(r)}>
                          <Check size={14} /> Setujui
                        </button>
                      )}
                      {r.accountStatus === 'PENDING' && (
                        <button className="btn btn--danger btn--sm" disabled={busyId === r.id}
                          onClick={() => { setRejecting(r); setReason(''); }}>
                          <X size={14} /> Tolak
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="pagination">
          <span>Total: {total} pendaftaran</span>
          <div className="pagination__controls">
            <button className="btn btn--ghost btn--sm" disabled={page <= 1} onClick={() => setPage(page - 1)}>‹</button>
            <span>{page} / {totalPages}</span>
            <button className="btn btn--ghost btn--sm" disabled={page >= totalPages} onClick={() => setPage(page + 1)}>›</button>
          </div>
        </div>
      </div>

      {/* ── Modal detail ─────────────────────────────────────── */}
      {detail && (
        <div className="modal-overlay" onClick={() => setDetail(null)}>
          <div className="modal modal--lg" onClick={(e) => e.stopPropagation()}>
            <h3 className="modal__title">Detail Pendaftaran</h3>

            {detail.accountStatus === 'REJECTED' && detail.sppg?.rejectionReason && (
              <p className="verif-reject-note">Alasan penolakan: {detail.sppg.rejectionReason}</p>
            )}

            <dl className="verif-detail">
              <dt>Nama pendaftar</dt><dd>{detail.name}</dd>
              <dt>Email</dt><dd>{detail.email}</dd>
              <dt>Tanggal daftar</dt><dd>{fmtDate(detail.createdAt)}</dd>
              <dt>Nama SPPG</dt><dd>{detail.sppg?.nama ?? '—'}</dd>
              <dt>Provinsi</dt><dd>{detail.sppg?.provinsi ?? '—'}</dd>
              <dt>Kabupaten / Kota</dt><dd>{detail.sppg?.kabupatenKota ?? '—'}</dd>
              <dt>Kecamatan</dt><dd>{detail.sppg?.kecamatan ?? '—'}</dd>
              <dt>Kelurahan / Desa</dt><dd>{detail.sppg?.kelurahanDesa ?? '—'}</dd>
              <dt>Alamat</dt><dd>{detail.sppg?.alamat ?? '—'}</dd>
              <dt>Penanggung jawab</dt><dd>{detail.sppg?.penanggungjawab ?? '—'}</dd>
              <dt>Kontak</dt><dd>{detail.sppg?.kontak ?? '—'}</dd>
              <dt>Kapasitas porsi / hari</dt><dd>{detail.sppg?.kapasitasPorsi ?? '—'}</dd>
              <dt>Wilayah 3T</dt><dd>{detail.sppg?.is3t ? 'Ya' : 'Tidak'}</dd>
              <dt>Status</dt>
              <dd><span className={`badge ${BADGE[detail.accountStatus].cls}`}>{BADGE[detail.accountStatus].label}</span></dd>
            </dl>

            <div className="modal__actions">
              <button className="btn btn--ghost" onClick={() => setDetail(null)}>Tutup</button>
              {detail.accountStatus === 'PENDING' && (
                <button className="btn btn--danger" disabled={busyId === detail.id}
                  onClick={() => { setRejecting(detail); setReason(''); }}>
                  Tolak
                </button>
              )}
              {detail.accountStatus !== 'ACTIVE' && (
                <button className="btn btn--primary" disabled={busyId === detail.id}
                  onClick={() => approve(detail)}>
                  Setujui
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ── Modal tolak ──────────────────────────────────────── */}
      {rejecting && (
        <div className="modal-overlay" onClick={() => setRejecting(null)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h3 className="modal__title">Tolak Pendaftaran</h3>
            <p style={{ margin: '0 0 12px', fontSize: 14, color: '#4b5563' }}>
              SPPG <strong>{rejecting.sppg?.nama ?? '-'}</strong> ({rejecting.name}). Alasan akan
              ditampilkan kepada pendaftar saat mencoba masuk.
            </p>
            <div className="form-group">
              <label className="form-label" htmlFor="reject-reason">Alasan penolakan</label>
              <textarea id="reject-reason" className="form-input" rows={4} value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="Contoh: Data SPPG tidak ditemukan pada daftar resmi BGN" />
            </div>
            <div className="modal__actions">
              <button className="btn btn--ghost" onClick={() => setRejecting(null)}>Batal</button>
              <button className="btn btn--danger" onClick={submitReject} disabled={busyId === rejecting.id}>
                {busyId === rejecting.id ? <span className="spinner spinner--sm" /> : 'Tolak Pendaftaran'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
