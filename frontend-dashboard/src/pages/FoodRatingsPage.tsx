import { useEffect, useState } from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Cell,
} from 'recharts';
import { foodRatingsApi } from '@/api/endpoints';
import type { FoodRanking, FoodRatingRecord } from '@/types/api.types';
import { downloadCsv } from '@/api/client';
import { Download } from 'lucide-react';

const COLORS = ['#6366f1', '#8b5cf6', '#06b6d4', '#10b981', '#f59e0b'];

function stars(n: number) { return '★'.repeat(Math.round(n)) + '☆'.repeat(5 - Math.round(n)); }
function fmt(d: string) { return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' }); }

export default function FoodRatingsPage() {
  const [ranking, setRanking] = useState<FoodRanking[]>([]);
  const [records, setRecords] = useState<FoodRatingRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const LIMIT = 15;

  const load = async () => {
    setIsLoading(true);
    setError('');
    try {
      const [rankRes, listRes] = await Promise.all([
        foodRatingsApi.ranking({ startDate: startDate || undefined, endDate: endDate || undefined, limit: 10 }),
        foodRatingsApi.list({ startDate: startDate || undefined, endDate: endDate || undefined, page, limit: LIMIT }),
      ]);
      setRanking(rankRes.data.data);
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
    downloadCsv('/food-ratings/export', 'food_ratings.csv', params);
  };

  const totalPages = Math.ceil(total / LIMIT);

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Makanan Favorit Siswa</h1>
          <p className="page__subtitle">Ranking dan riwayat rating makanan dari siswa</p>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input type="date" className="form-input form-input--sm" value={startDate}
            onChange={(e) => { setStartDate(e.target.value); setPage(1); }} />
          <span>s/d</span>
          <input type="date" className="form-input form-input--sm" value={endDate}
            onChange={(e) => { setEndDate(e.target.value); setPage(1); }} />
          <button id="food-ratings-export-btn" className="btn btn--secondary" onClick={handleExport}>
            <Download size={16} /> CSV
          </button>
        </div>
      </div>

      {error && <div className="alert alert--error">{error}</div>}

      {isLoading ? (
        <div className="loading-state"><div className="spinner" /></div>
      ) : (
        <>
          {/* Bar chart ranking */}
          {ranking.length > 0 && (
            <div className="chart-card chart-card--wide">
              <h2 className="chart-card__title">Top 10 Makanan Favorit (Rata-rata Rating)</h2>
              <ResponsiveContainer width="100%" height={280}>
                <BarChart data={ranking} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" domain={[0, 5]} />
                  <YAxis type="category" dataKey="foodName" width={110} tick={{ fontSize: 13 }} />
                  <Tooltip formatter={(v: number, _: string, entry: any) =>
                    [`${v} ⭐ (${entry.payload.voteCount} suara)`, 'Avg Rating']
                  } />
                  <Bar dataKey="avgRating" radius={[0, 6, 6, 0]}>
                    {ranking.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
              {/* Ranking table */}
              <div className="table-wrapper" style={{ marginTop: 16 }}>
                <table className="data-table">
                  <thead><tr><th>#</th><th>Makanan</th><th>Avg Rating</th><th>Jumlah Suara</th></tr></thead>
                  <tbody>
                    {ranking.map((r) => (
                      <tr key={r.rank}>
                        <td><strong>#{r.rank}</strong></td>
                        <td>{r.foodName}</td>
                        <td>{stars(r.avgRating)} ({r.avgRating})</td>
                        <td>{r.voteCount} siswa</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* All ratings table */}
          <div className="table-card">
            <h2 className="table-card__title">Semua Data Rating</h2>
            <div className="table-wrapper">
              <table className="data-table">
                <thead><tr><th>Tanggal</th><th>Siswa</th><th>Jenjang</th><th>Makanan</th><th>Rating</th><th>Alasan</th></tr></thead>
                <tbody>
                  {records.length === 0 ? (
                    <tr><td colSpan={6} style={{ textAlign: 'center', color: '#6b7280' }}>Tidak ada data</td></tr>
                  ) : records.map((r) => (
                    <tr key={r.id}>
                      <td>{fmt(r.ratedAt)}</td>
                      <td>{r.user.name}</td>
                      <td>{r.user.schoolLevel ?? '—'}</td>
                      <td>{r.foodName}</td>
                      <td>{stars(r.rating)} <small>({r.rating}/5)</small></td>
                      <td>{r.reason ?? '—'}</td>
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
      )}
    </div>
  );
}
