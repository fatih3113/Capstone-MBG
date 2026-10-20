import { useEffect, useState } from 'react';
import {
  BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import { dashboardApi } from '@/api/endpoints';
import type { DashboardOverview } from '@/types/api.types';
import StatCard from '@/components/ui/StatCard';
import { ClipboardList, Star, MessageSquare, ScanLine, TrendingUp } from 'lucide-react';

const COLORS = ['#6366f1', '#22c55e', '#f59e0b', '#ef4444', '#8b5cf6'];
const STATUS_LABELS: Record<string, string> = {
  received: 'Diterima', reviewing: 'Ditinjau', considered: 'Dipertimbangkan',
  approved: 'Disetujui', rejected: 'Ditolak',
  habis: 'Habis', sebagian: 'Sebagian', hampir_tidak: 'Hampir Tidak',
  tidak_diisi: 'Tdk Diisi',
};

function fmt(d: string) {
  return new Date(d).toLocaleDateString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

export default function DashboardPage() {
  const [data, setData] = useState<DashboardOverview | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  const load = async () => {
    setIsLoading(true);
    setError('');
    try {
      const res = await dashboardApi.overview({ startDate: startDate || undefined, endDate: endDate || undefined });
      setData(res.data.data);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data dashboard');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Dashboard MBG</h1>
          <p className="page__subtitle">Ringkasan data program Makan Bergizi Gratis</p>
        </div>
        {/* Filter tanggal */}
        <div className="date-filter">
          <input id="dashboard-start-date" type="date" className="form-input form-input--sm"
            value={startDate} onChange={(e) => setStartDate(e.target.value)} />
          <span>s/d</span>
          <input id="dashboard-end-date" type="date" className="form-input form-input--sm"
            value={endDate} onChange={(e) => setEndDate(e.target.value)} />
          <button id="dashboard-filter-btn" className="btn btn--secondary btn--sm" onClick={load}>
            Filter
          </button>
          {(startDate || endDate) && (
            <button className="btn btn--ghost btn--sm" onClick={() => { setStartDate(''); setEndDate(''); }}>
              Reset
            </button>
          )}
        </div>
      </div>

      {error && <div className="alert alert--error">{error}</div>}

      {isLoading ? (
        <div className="loading-state"><div className="spinner" /><p>Memuat data...</p></div>
      ) : data ? (
        <>
          {/* Stat Cards */}
          <div className="stat-grid">
            <StatCard label="Usulan Menu" value={data.summary.totalMenuRequests} color="blue" icon={<ClipboardList size={20} />} />
            <StatCard label="Rating Makanan" value={data.summary.totalFoodRatings} color="green" icon={<Star size={20} />} />
            <StatCard label="Feedback Siswa" value={data.summary.totalFeedbacks} color="orange" icon={<MessageSquare size={20} />} />
            <StatCard label="Total Scan" value={data.summary.totalScans} color="purple" icon={<ScanLine size={20} />} />
            <StatCard
              label="Rata-rata Rating"
              value={data.summary.avgFoodRating ? `${data.summary.avgFoodRating} ⭐` : '—'}
              color="red"
              icon={<TrendingUp size={20} />}
            />
          </div>

          {/* Charts row */}
          <div className="chart-grid">
            {/* Status Usulan Menu */}
            <div className="chart-card">
              <h2 className="chart-card__title">Status Usulan Menu</h2>
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie
                    data={data.menuRequestsByStatus.map((s) => ({ name: STATUS_LABELS[s.status] ?? s.status, value: s.count }))}
                    cx="50%" cy="50%" outerRadius={80}
                    dataKey="value" label={({ name, value }) => `${name}: ${value}`}
                  >
                    {data.menuRequestsByStatus.map((_, i) => (
                      <Cell key={i} fill={COLORS[i % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>

            {/* Status Konsumsi */}
            <div className="chart-card">
              <h2 className="chart-card__title">Status Konsumsi Siswa *</h2>
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie
                    data={data.consumptionSummary.map((s) => ({ name: STATUS_LABELS[s.status] ?? s.status, value: s.count }))}
                    cx="50%" cy="50%" outerRadius={80}
                    dataKey="value"
                  >
                    {data.consumptionSummary.map((_, i) => (
                      <Cell key={i} fill={COLORS[i % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
              <p className="chart-card__note">* Pilihan siswa, bukan pengukuran berat aktual</p>
            </div>

            {/* Top Makanan Favorit */}
            <div className="chart-card chart-card--wide">
              <h2 className="chart-card__title">Top Makanan Favorit</h2>
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={data.topFavorites} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" domain={[0, 5]} />
                  <YAxis type="category" dataKey="foodName" width={100} />
                  <Tooltip formatter={(v: number) => [`${v} ⭐`, 'Avg Rating']} />
                  <Bar dataKey="avgRating" fill="#6366f1" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Recent Scans */}
          <div className="table-card">
            <h2 className="table-card__title">10 Scan Gizi Terbaru</h2>
            <p className="table-card__note disclaimer">
              ⚠ Nilai gizi adalah estimasi berdasarkan data komposisi pangan, bukan analisis laboratorium.
            </p>
            <div className="table-wrapper">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Waktu</th><th>Siswa</th><th>Jenjang</th>
                    <th>Kalori*</th><th>Protein*</th><th>Makanan</th>
                  </tr>
                </thead>
                <tbody>
                  {data.recentScans.map((s) => (
                    <tr key={s.id}>
                      <td>{fmt(s.scannedAt)}</td>
                      <td>{s.user.name}</td>
                      <td>{s.user.schoolLevel ?? '—'}</td>
                      <td>{s.nutrition.calories.toFixed(0)} kcal</td>
                      <td>{s.nutrition.protein.toFixed(1)} g</td>
                      <td>{s.foods.join(', ') || '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      ) : null}
    </div>
  );
}
