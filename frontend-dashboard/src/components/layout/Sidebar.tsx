import { useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import {
  LayoutDashboard, ClipboardList, Star,
  MessageSquare, BarChart3, LogOut, Menu, X, Utensils,
} from 'lucide-react';

const navItems = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/menu-requests', label: 'Usulan Menu', icon: ClipboardList },
  { to: '/food-ratings', label: 'Makanan Favorit', icon: Star },
  { to: '/feedback', label: 'Feedback Siswa', icon: MessageSquare },
  { to: '/nutrition', label: 'Laporan Gizi', icon: BarChart3 },
];

export default function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [collapsed, setCollapsed] = useState(false);

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
        {!collapsed && (
          <div className="sidebar__logo">
            <Utensils size={22} />
            <span>Foodler Admin</span>
          </div>
        )}
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
        {navItems.map(({ to, label, icon: Icon }) => (
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
              <p className="sidebar__user-role">Admin MBG</p>
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
