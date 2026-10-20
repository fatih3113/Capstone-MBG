import { useEffect, useState } from 'react';
import { nutritionReportsApi } from '@/api/endpoints';
import type { NutritionReport, NutritionStats } from '@/types/api.types';
import StatCard from '@/components/ui/StatCard';
import { downloadCsv } from '@/api/client';
import { Download, AlertTriangle } from 'lucide-react';

function fmt(d: string) {
  return new Date(d).toLocaleDateString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

export default function NutritionPage() {
  const [stats, setStats] = useState<NutritionStats | null>(null);
  const [records, setRecords] = useState<NutritionReport[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [akgTarget, setAkgTarget] = useState('');
  const LIMIT = 15;

  const load = async () => {
    setIsLoading(true);
    setError('');
    try {
      const [statsRes, listRes] = await Promise.all([
        nutritionReportsApi.stats({ startDate: startDate || undefined, endDate: endDate || undefined }),
        nutritionReportsApi.list({
          startDate: startDate || undefined,
          endDate: endDate || undefined,
          akgTarget: akgTarget || undefined,
          page,
          limit: LIMIT,
        }),
      ]);
      setStats(statsRes.data.data);
      setRecords(listRes.data.data.records);
      setTotal(listRes.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { load(); }, [startDate, endDate, akgTarget, page]);

  const handleExport = () => {
    const params: Record<string, string> = {};
    if (startDate) params.startDate = startDate;
    if (endDate) params.endDate = endDate;
    downloadCsv('/nutrition-reports/export', 'nutrition_reports.csv', params);
  };

  const totalPages = Math.ceil(total / LIMIT);

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Laporan Analisis Gizi</h1>
          <p className="page__subtitle">Data hasil scan gizi makanan MBG siswa</p>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input
            id="nutrition-start-date" type="date"
            className="form-input form-input--sm" value={startDate}
            onChange={(e) => { setStartDate(e.target.value); setPage(1); }}
          />
          <span>s/d</span>
          <input
            id="nutrition-end-date" type="date"
            className="form-input form-input--sm" value={endDate}
            onChange={(e) => { setEndDate(e.target.value); setPage(1); }}
          />
          <button id="nutrition-export-btn" className="btn btn--secondary" onClick={handleExport}>
            <Download size={16} /> CSV
          </button>
        </div>
      </div>

      {/* Disclaimer */}
      <div className="alert alert--warning" style={{ display: 'flex', gap: 10, alignItems: 'flex-start' }}>
        <AlertTriangle size={18} style={{ marginTop: 2, flexShrink: 0 }} />
        <span>
          <strong>Disclaimer:</strong> Semua nilai gizi di bawah adalah <strong>estimasi</strong> berdasarkan
          data komposisi pangan (TKPI/referensi internal), bukan hasil analisis laboratorium.
          Nilai aktual dapat berbeda tergantung cara pengolahan, ukuran porsi, dan kondisi bahan makanan.
        </span>
      </div>

      {error && <div className="alert alert--error">{error}</div>}

      {/* Stats cards */}
      {stats && (
        <div className="stat-grid">
          <StatCard label="Total Scan" value={stats.totalScans} color="blue" />
          <StatCard label="Avg Kalori*" value={`${stats.avgCalories} kcal`} color="orange" />
          <StatCard label="Avg Protein*" value={`${stats.avgProtein} g`} color="green" />
          <StatCard label="Avg Karbo*" value={`${stats.avgCarbs} g`} color="purple" />
          <StatCard label="Avg Lemak*" value={`${stats.avgFat} g`} color="red" />
        </div>
      )}

      {/* Filter AKG */}
      <div className="filter-bar">
        <select
          id="nutrition-akg-filter"
          className="form-input form-input--sm"
          value={akgTarget}
          onChange={(e) => { setAkgTarget(e.target.value); setPage(1); }}
        >
          <option value="">Semua Sasaran AKG</option>
          <option value="SD 1-3">SD Kelas 1–3</option>
          <option value="SD 4-6">SD Kelas 4–6</option>
          <option value="SMP">SMP</option>
          <option value="SMA">SMA/SMK</option>
          <option value="TK/PAUD">TK/PAUD</option>
          <option value="Balita">Balita</option>
          <option value="Ibu Hamil">Ibu Hamil/Menyusui</option>
        </select>
      </div>

      {/* Table */}
      <div className="table-card">
        {isLoading ? (
          <div className="loading-state"><div className="spinner" /></div>
        ) : (
          <>
            <div className="table-wrapper">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Waktu Scan</th>
                    <th>Siswa</th>
                    <th>Jenjang</th>
                    <th>Sasaran AKG</th>
                    <th>Kalori* (kcal)</th>
                    <th>Protein* (g)</th>
                    <th>Karbo* (g)</th>
                    <th>Lemak* (g)</th>
                    <th>Makanan Terdeteksi</th>
                  </tr>
                </thead>
                <tbody>
                  {records.length === 0 ? (
                    <tr>
                      <td colSpan={9} style={{ textAlign: 'center', color: '#6b7280' }}>
                        Tidak ada data scan
                      </td>
                    </tr>
                  ) : records.map((r) => (
                    <tr key={r.id}>
                      <td>{fmt(r.scannedAt)}</td>
                      <td>{r.user.name}</td>
                      <td>{r.user.schoolLevel ?? '—'}</td>
                      <td>{r.akgTarget ?? '—'}</td>
                      <td>{r.estimatedNutrition.calories.toFixed(0)}</td>
                      <td>{r.estimatedNutrition.protein.toFixed(1)}</td>
                      <td>{r.estimatedNutrition.carbs.toFixed(1)}</td>
                      <td>{r.estimatedNutrition.fat.toFixed(1)}</td>
                      <td>
                        {r.foods.length > 0
                          ? r.foods.map((f) => f.name).join(', ')
                          : '—'
                        }
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="pagination">
              <span>Total: {total} scan · * Estimasi dari data komposisi pangan</span>
              <div className="pagination__controls">
                <button
                  className="btn btn--ghost btn--sm"
                  disabled={page <= 1}
                  onClick={() => setPage((p) => p - 1)}
                >‹</button>
                <span>{page} / {totalPages || 1}</span>
                <button
                  className="btn btn--ghost btn--sm"
                  disabled={page >= totalPages}
                  onClick={() => setPage((p) => p + 1)}
                >›</button>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
