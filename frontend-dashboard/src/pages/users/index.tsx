import { useEffect, useState, useCallback } from 'react';
import { usersApi } from '@/api/endpoints';
import type { UserItem, UserSummary, InstitutionType } from '@/types/api.types';
import StatCard from '@/components/ui/StatCard';
import { Search, Users, UserPlus, AlertTriangle, School as SchoolIcon } from 'lucide-react';
import { LEVELS } from './types';
import UserList from './UserList';

interface UsersPageProps {
  type: InstitutionType;
}

export default function UsersPage({ type }: UsersPageProps) {
  const isPosyandu = type === 'posyandu';

  const [records, setRecords]     = useState<UserItem[]>([]);
  const [total, setTotal]         = useState(0);
  const [page, setPage]           = useState(1);
  const [search, setSearch]       = useState('');
  const [level, setLevel]         = useState('');
  const [gender, setGender]       = useState('');
  const [allergy, setAllergy]     = useState('');
  const [summary, setSummary]     = useState<UserSummary | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError]         = useState('');

  const LIMIT = 15;

  const loadSummary = useCallback(async () => {
    try {
      const res = await usersApi.summary(type);
      if (res.data.success) setSummary(res.data.data);
    } catch { /* ringkasan opsional, abaikan error */ }
  }, [type]);

  const load = useCallback(async () => {
    setIsLoading(true); setError('');
    try {
      const res = await usersApi.list({
        search: search || undefined, level: level || undefined,
        gender: gender || undefined, allergy: allergy || undefined,
        type, page, limit: LIMIT,
      });
      setRecords(res.data.data.records);
      setTotal(res.data.data.total);
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal memuat data pengguna');
    } finally { setIsLoading(false); }
  }, [search, level, gender, allergy, page, type]);

  useEffect(() => { loadSummary(); }, [loadSummary]);
  useEffect(() => { load(); }, [load]);

  const hasFilter = !!(search || level || gender || allergy);
  const reset = () => { setSearch(''); setLevel(''); setGender(''); setAllergy(''); setPage(1); };
  const totalPages = Math.ceil(total / LIMIT);

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Pengguna {isPosyandu ? 'Posyandu' : 'Sekolah'}</h1>
          <p className="page__subtitle">
            {isPosyandu ? 'Peserta Posyandu' : 'Siswa'} yang terdaftar di aplikasi mobile MBG
          </p>
        </div>
      </div>

      {summary && (
        <div className="stat-grid">
          <StatCard label="Total Pengguna" value={summary.total}
            sub={`${summary.male} laki-laki • ${summary.female} perempuan`}
            icon={<Users size={22} />} color="blue" />
          <StatCard label="Daftar Bulan Ini" value={summary.newThisMonth}
            icon={<UserPlus size={22} />} color="green" />
          <StatCard label="Punya Alergi" value={summary.withAllergy}
            icon={<AlertTriangle size={22} />} color="orange" />
          <StatCard label={isPosyandu ? 'Belum Pilih Posyandu' : 'Belum Pilih Sekolah'}
            value={summary.withoutSchool}
            sub="Tidak menerima notifikasi per lembaga"
            icon={<SchoolIcon size={22} />} color="purple" />
        </div>
      )}

      <div className="filter-bar">
        <div className="filter-bar__group" style={{ flex: 1, minWidth: '180px' }}>
          <label className="filter-bar__label">Cari Pengguna</label>
          <div className="search-input-wrap">
            <Search size={15} className="search-icon" />
            <input className="form-input form-input--sm search-input" placeholder="Nama atau email..."
              value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} />
          </div>
        </div>
        {!isPosyandu && (
          <div className="filter-bar__group">
            <label className="filter-bar__label">Jenjang</label>
            <select className="form-input form-input--sm" value={level}
              onChange={(e) => { setLevel(e.target.value); setPage(1); }}>
              <option value="">Semua</option>
              {LEVELS.map((l) => <option key={l} value={l}>{l}</option>)}
            </select>
          </div>
        )}
        <div className="filter-bar__group">
          <label className="filter-bar__label">Jenis Kelamin</label>
          <select className="form-input form-input--sm" value={gender}
            onChange={(e) => { setGender(e.target.value); setPage(1); }}>
            <option value="">Semua</option>
            <option value="L">Laki-laki</option>
            <option value="P">Perempuan</option>
          </select>
        </div>
        <div className="filter-bar__group">
          <label className="filter-bar__label">Alergi</label>
          <select className="form-input form-input--sm" value={allergy}
            onChange={(e) => { setAllergy(e.target.value); setPage(1); }}>
            <option value="">Semua</option>
            <option value="ada">Punya alergi</option>
            <option value="tidak">Tidak ada alergi</option>
            <option value="belum">Belum diisi</option>
          </select>
        </div>
        {hasFilter && <button className="btn btn--ghost btn--sm" onClick={reset}>Reset</button>}
      </div>

      {error && <div className="alert alert--error" role="alert">{error}</div>}

      {isLoading ? (
        <div className="loading-box"><div className="spinner" /><p>Memuat data pengguna...</p></div>
      ) : (
        <UserList
          type={type}
          records={records} total={total} page={page} totalPages={totalPages}
          onPageChange={setPage}
        />
      )}
    </div>
  );
}