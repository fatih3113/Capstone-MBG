import { useState } from 'react';
import { School, HeartPulse, Building2, Users } from 'lucide-react';
import type { InstitutionType } from '@/types/api.types';
import SchoolsPage from '@/pages/schools';
import UsersPage from '@/pages/users';
import '@/styles/institutions.css';

type SubTab = 'lembaga' | 'pengguna';

export default function InstitutionsPage() {
  const [type, setType] = useState<InstitutionType>('sekolah');
  const [sub, setSub] = useState<SubTab>('lembaga');

  const typeLabel = type === 'sekolah' ? 'Sekolah' : 'Posyandu';

  return (
    <div>
      {/* Tab utama: Sekolah | Posyandu */}
      <div className="inst-tabs" role="tablist" aria-label="Jenis lembaga">
        <button
          role="tab"
          aria-selected={type === 'sekolah'}
          className={`inst-tabs__item ${type === 'sekolah' ? 'inst-tabs__item--active' : ''}`}
          onClick={() => setType('sekolah')}
        >
          <School size={16} /> Sekolah
        </button>
        <button
          role="tab"
          aria-selected={type === 'posyandu'}
          className={`inst-tabs__item ${type === 'posyandu' ? 'inst-tabs__item--active' : ''}`}
          onClick={() => setType('posyandu')}
        >
          <HeartPulse size={16} /> Posyandu
        </button>
      </div>

      {/* Sub tab: Daftar Lembaga | Data Pengguna */}
      <div className="inst-tabs inst-tabs--sub" role="tablist" aria-label="Data lembaga">
        <button
          role="tab"
          aria-selected={sub === 'lembaga'}
          className={`inst-tabs__item ${sub === 'lembaga' ? 'inst-tabs__item--active' : ''}`}
          onClick={() => setSub('lembaga')}
        >
          <Building2 size={15} /> Daftar {typeLabel}
        </button>
        <button
          role="tab"
          aria-selected={sub === 'pengguna'}
          className={`inst-tabs__item ${sub === 'pengguna' ? 'inst-tabs__item--active' : ''}`}
          onClick={() => setSub('pengguna')}
        >
          <Users size={15} /> Pengguna {typeLabel}
        </button>
      </div>

      {/* key = reset state (filter, halaman) saat pindah tab */}
      {sub === 'lembaga'
        ? <SchoolsPage key={`lembaga-${type}`} type={type} />
        : <UsersPage key={`pengguna-${type}`} type={type} />}
    </div>
  );
}