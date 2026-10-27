import { useEffect, useState, useCallback } from 'react';
import { distributionApi } from '@/api/endpoints';
import { downloadCsv } from '@/api/client';
import type {
  DistributionSummary, SchoolDistribution, DistributionRecord,
  School, FoodOption,
} from '@/types/api.types';
import StatCard from '@/components/ui/StatCard';
import {
  Building2, Calendar, Download, Package, School as SchoolIcon, Plus,
} from 'lucide-react';
import { fmtDate } from './types';
import DistributionList from './DistributionList';
import ScheduleCreate from './ScheduleCreate';
import ScheduleEdit from './ScheduleEdit';
import ScheduleDelete from './ScheduleDelete';

export default function DistributionPage() {
  // Data
  const [summary, setSummary]             = useState<DistributionSummary | null>(null);
  const [schools, setSchools]             = useState<SchoolDistribution[]>([]);
  const [timeline, setTimeline]           = useState<DistributionRecord[]>([]);
  const [timelineTotal, setTimelineTotal] = useState(0);
  const [timelinePage, setTimelinePage]   = useState(1);
  // CRUD options
  const [allSchools, setAllSchools]       = useState<School[]>([]);
  const [allFoods, setAllFoods]           = useState<FoodOption[]>([]);
  // UI
  const [startDate, setStartDate]         = useState('');
  const [endDate, setEndDate]             = useState('');
  const [activeTab, setActiveTab]         = useState<'schools' | 'timeline'>('schools');
  const [isLoading, setIsLoading]         = useState(true);
  const [error, setError]                 = useState('');
  // Modal state
  const [showCreate, setShowCreate]       = useState(false);
  const [editRecord, setEditRecord]       = useState<DistributionRecord | null>(null);
  const [deleteRecord, setDeleteRecord]   = useState<DistributionRecord | null>(null);
  const LIMIT = 15;

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

  useEffect(() => {
    distributionApi.getSchools().then((r) => setAllSchools(r.data.data)).catch(() => {});
    distributionApi.getFoods().then((r) => setAllFoods(r.data.data)).catch(() => {});
  }, []);
  useEffect(() => { load(); }, [load]);

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
          <button id="distribution-add-btn" className="btn btn--primary" onClick={() => setShowCreate(true)}>
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
          <button className="btn btn--ghost btn--sm" onClick={() => { setStartDate(''); setEndDate(''); setTimelinePage(1); }}>Reset</button>
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

      {/* List */}
      {isLoading ? (
        <div className="loading-box"><div className="spinner" /><p>Memuat data distribusi...</p></div>
      ) : (
        <DistributionList
          activeTab={activeTab}
          schools={schools}
          timeline={timeline}
          timelineTotal={timelineTotal}
          timelinePage={timelinePage}
          totalPages={totalPages}
          onEdit={(rec) => setEditRecord(rec)}
          onDelete={(rec) => setDeleteRecord(rec)}
          onPageChange={setTimelinePage}
        />
      )}

      {/* Create */}
      {showCreate && (
        <ScheduleCreate
          schools={allSchools} foods={allFoods}
          onSuccess={() => { setShowCreate(false); load(); }}
          onClose={() => setShowCreate(false)}
        />
      )}

      {/* Edit */}
      {editRecord && (
        <ScheduleEdit
          record={editRecord} schools={allSchools} foods={allFoods}
          onSuccess={() => { setEditRecord(null); load(); }}
          onClose={() => setEditRecord(null)}
        />
      )}

      {/* Delete */}
      {deleteRecord && (
        <ScheduleDelete
          record={deleteRecord}
          onSuccess={() => { setDeleteRecord(null); load(); }}
          onClose={() => setDeleteRecord(null)}
        />
      )}
    </div>
  );
}
