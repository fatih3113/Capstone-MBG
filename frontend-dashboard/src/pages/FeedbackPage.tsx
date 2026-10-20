import { useEffect, useState } from 'react';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { foodFeedbacksApi } from '@/api/endpoints';
import type { FeedbackSummary, FeedbackRecord } from '@/types/api.types';
import StatusBadge from '@/components/ui/StatusBadge';
import { downloadCsv } from '@/api/client';
import { Download } from 'lucide-react';

const COLORS = ['#22c55e', '#f59e0b', '#ef4444', '#6b7280'];
function fmt(d: string) { return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' }); }

export default function FeedbackPage() {
  const [summary, setSummary] = useState<FeedbackSummary | null>(null);
  const [records, setRecords] = useState<FeedbackRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const LIMIT = 15;

  const CONSUMPTION_LABELS: Record<string, string> = {
    habis: 'Habis', sebagian: 'Sebagian', hampir_tidak: 'Hampir Tidak', tidak_diisi: 'Tdk Diisi',
  };

  const load = async () => {
    setIsLoading(true);
    setError('');
    try {
      const [sumRes, listRes] = await Promise.all([
        foodFeedbacksApi.summary({ startDate: startDate || undefined, endDate: endDate || undefined }),
        foodFeedbacksApi.list({ startDate: startDate || undefined, endDate: endDate || undefined, page, limit: LIMIT }),
      ]);
      setSummary(sumRes.data.data);
      setRecords(listRes.data.data.records);
      setTotal(listRes.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { load(); }, [startDate, endDate, page]);

  const handleExport = () => {
    const params: Record<string, string> = {};
    if (startDate) params.startDate = startDate;
    if (endDate) params.endDate = endDate;
    downloadCsv('/food-feedbacks/export', 'food_feedbacks.csv', params);
  };

  const totalPages = Math.ceil(total / LIMIT);

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Feedback Siswa</h1>
          <p className="page__subtitle">Penilaian sensorik dan status konsumsi siswa *</p>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input type="date" className="form-input form-input--sm" value={startDate}
            onChange={(e) => { setStartDate(e.target.value); setPage(1); }} />
          <span>s/d</span>
          <input type="date" className="form-input form-input--sm" value={endDate}
            onChange={(e) => { setEndDate(e.target.value); setPage(1); }} />
          <button id="feedback-export-btn" className="btn btn--secondary" onClick={handleExport}>
            <Download size={16} /> CSV
          </button>
        </div>
      </div>

      <div className="alert alert--warning">
        ⚠ Status konsumsi merupakan <strong>pilihan siswa</strong> (habis / sebagian / hampir tidak),
        bukan pengukuran berat sisa makanan yang sebenarnya.
      </div>

      {error && <div className="alert alert--error">{error}</div>}

      {isLoading ? (
        <div className="loading-state"><div className="spinner" /></div>
      ) : summary ? (
        <>
          <div className="chart-grid">
            {/* Donut konsumsi */}
            <div className="chart-card">
              <h2 className="chart-card__title">Distribusi Status Konsumsi *</h2>
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie
                    data={summary.consumptionDistribution.map((c) => ({
                      name: CONSUMPTION_LABELS[c.status] ?? c.status, value: c.count,
                    }))}
                    cx="50%" cy="50%" innerRadius={55} outerRadius={80}
                    dataKey="value" paddingAngle={3}
                  >
                    {summary.consumptionDistribution.map((_, i) => (
                      <Cell key={i} fill={COLORS[i % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
              <p className="chart-card__note">* Pilihan siswa, bukan pengukuran aktual</p>
            </div>

            {/* Bar sentimen per makanan */}
            <div className="chart-card chart-card--wide">
              <h2 className="chart-card__title">Tingkat Kepuasan per Makanan (Avg)</h2>
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={summary.foodSentiment.slice(0, 8)} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" domain={[0, 5]} />
                  <YAxis type="category" dataKey="foodName" width={100} tick={{ fontSize: 12 }} />
                  <Tooltip />
                  <Bar dataKey="avgSatisfaction" name="Kepuasan" fill="#6366f1" radius={[0, 4, 4, 0]} />
                  <Bar dataKey="avgTaste" name="Rasa" fill="#22c55e" radius={[0, 4, 4, 0]} />
                  <Legend />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Makanan sering dilaporkan hampir tidak dimakan */}
          {summary.mostLeftoverReported.length > 0 && (
            <div className="table-card">
              <h2 className="table-card__title">Makanan Paling Sering Dilaporkan "Hampir Tidak Dimakan" *</h2>
              <p className="table-card__note disclaimer">* Berdasarkan pilihan siswa, bukan pengukuran berat sisa aktual</p>
              <div className="table-wrapper">
                <table className="data-table">
                  <thead><tr><th>#</th><th>Makanan</th><th>Jumlah Laporan</th></tr></thead>
                  <tbody>
                    {summary.mostLeftoverReported.map((r, i) => (
                      <tr key={r.foodName}>
                        <td>{i + 1}</td>
                        <td>{r.foodName}</td>
                        <td>{r.reportCount} laporan</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* All feedbacks */}
          <div className="table-card">
            <h2 className="table-card__title">Semua Data Feedback</h2>
            <div className="table-wrapper">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Tanggal</th><th>Siswa</th><th>Makanan</th>
                    <th>Rasa</th><th>Kepuasan</th><th>Status Konsumsi*</th><th>Saran</th>
                  </tr>
                </thead>
                <tbody>
                  {records.length === 0 ? (
                    <tr><td colSpan={7} style={{ textAlign: 'center', color: '#6b7280' }}>Tidak ada data</td></tr>
                  ) : records.map((r) => (
                    <tr key={r.id}>
                      <td>{fmt(r.submittedAt)}</td>
                      <td>{r.user.name}</td>
                      <td>{r.foodName}</td>
                      <td>{r.tastRating ?? '—'}/5</td>
                      <td>{r.satisfactionRating ?? '—'}/5</td>
                      <td><StatusBadge status={r.consumptionStatus ?? 'tidak_diisi'} /></td>
                      <td>{r.suggestion ?? '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="pagination">
              <span>Total: {total} data</span>
              <div className="pagination__controls">
                <button className="btn btn--ghost btn--sm" disabled={page <= 1} onClick={() => setPage(p => p - 1)}>‹</button>
                <span>{page} / {totalPages || 1}</span>
                <button className="btn btn--ghost btn--sm" disabled={page >= totalPages} onClick={() => setPage(p => p + 1)}>›</button>
              </div>
            </div>
          </div>
        </>
      ) : null}
    </div>
  );
}
