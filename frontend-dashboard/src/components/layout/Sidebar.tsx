import { useEffect, useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { sppgVerificationApi } from '@/api/endpoints';
import {
  LayoutDashboard, ClipboardList, Star,
  MessageSquare, BarChart3, LogOut, Menu, X, Truck, UtensilsCrossed, Building2, MapPin,
  UserCheck, Landmark,
} from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import '@/styles/brand.css';
import '@/styles/sppg-access.css';

interface NavItem {
  to: string;
  label: string;
  icon: LucideIcon;
  /** 'super' = hanya Super Admin, 'sppg' = hanya Admin SPPG, kosong = semua */
  only?: 'super' | 'sppg';
  badge?: 'pending';
}

const navItems: NavItem[] = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/menu-requests', label: 'Usulan Menu', icon: ClipboardList },
  { to: '/food-ratings', label: 'Makanan Favorit', icon: Star },
  { to: '/feedback', label: 'Feedback Siswa', icon: MessageSquare },
  { to: '/nutrition', label: 'Laporan Gizi', icon: BarChart3 },
  { to: '/distribution', label: 'Distribusi MBG', icon: Truck },
  { to: '/foods', label: 'Data Makanan', icon: UtensilsCrossed, only: 'super' },
  { to: '/institutions', label: 'Data Lembaga', icon: Building2 },
  { to: '/sppg', label: 'Wilayah SPPG', icon: MapPin, only: 'super' },
  { to: '/sppg-verification', label: 'Verifikasi Akun SPPG', icon: UserCheck, only: 'super', badge: 'pending' },
  { to: '/profile', label: 'Profil SPPG', icon: Landmark, only: 'sppg' },
];

export default function Sidebar() {
  const { user, logout, isSuperAdmin, isSppgAdmin } = useAuth();
  const navigate = useNavigate();
  const [collapsed, setCollapsed] = useState(false);
  const [pendingCount, setPendingCount] = useState(0);

  // Super Admin: badge jumlah pendaftaran SPPG yang menunggu persetujuan
  useEffect(() => {
    if (!isSuperAdmin) return;
    let active = true;
    const load = () =>
      sppgVerificationApi.pendingCount()
        .then((r) => { if (active) setPendingCount(r.data.data.count); })
        .catch(() => { /* badge bersifat tambahan, abaikan error */ });
    load();
    const timer = window.setInterval(load, 60_000);
    return () => { active = false; window.clearInterval(timer); };
  }, [isSuperAdmin]);

  const visibleItems = navItems.filter((item) => {
    if (item.only === 'super') return isSuperAdmin;
    if (item.only === 'sppg') return isSppgAdmin;
    return true;
  });

  const roleLabel = isSuperAdmin ? 'Super Admin' : 'Admin SPPG Daerah';

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <aside
      className={`sidebar ${collapsed ? 'sidebar--collapsed' : ''}`}
      aria-label="Navigasi utama"
    >
      {/* Header */}
      <div className="sidebar__header">
        <div className="sidebar__brand">
          <img className="sidebar__brand-img" src="/logo-mbg.png" alt="Logo MBG" />
          {!collapsed && (
            <div className="sidebar__brand-text">
              <span className="sidebar__brand-name">Foodler</span>
              <span className="sidebar__brand-sub">{isSuperAdmin ? 'Admin MBG' : 'Admin SPPG'}</span>
            </div>
          )}
        </div>
        <button
          className="sidebar__toggle"
          onClick={() => setCollapsed(!collapsed)}
          aria-label={collapsed ? 'Perluas sidebar' : 'Ciutkan sidebar'}
        >
          {collapsed ? <Menu size={20} /> : <X size={20} />}
        </button>
      </div>

      {/* Navigation */}
      <nav className="sidebar__nav">
        {visibleItems.map(({ to, label, icon: Icon, badge }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) =>
              `sidebar__link ${isActive ? 'sidebar__link--active' : ''}`
            }
            title={collapsed ? label : undefined}
          >
            <Icon size={20} className="sidebar__icon" />
            {!collapsed && <span>{label}</span>}
            {badge === 'pending' && pendingCount > 0 && (
              <span className="sidebar__badge" aria-label={`${pendingCount} menunggu persetujuan`}>
                {pendingCount > 99 ? '99+' : pendingCount}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      {/* User & logout */}
      <div className="sidebar__footer">
        {!collapsed && user && (
          <div className="sidebar__user">
            <div className="sidebar__avatar">{user.name.charAt(0).toUpperCase()}</div>
            <div className="sidebar__user-info">
              <p className="sidebar__user-name">{user.name}</p>
              <p className="sidebar__user-role">
                {roleLabel}{isSppgAdmin && user.sppgName ? ` · ${user.sppgName}` : ''}
              </p>
            </div>
          </div>
        )}
        <button
          className="sidebar__logout"
          onClick={handleLogout}
          title="Keluar"
          aria-label="Keluar dari dashboard"
        >
          <LogOut size={18} />
          {!collapsed && <span>Keluar</span>}
        </button>
      </div>
    </aside>
  );
}
