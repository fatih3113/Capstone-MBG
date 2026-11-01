import { useState, FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { Mail, Lock, Eye, EyeOff, LogIn, Truck, MessageSquare, BarChart3 } from 'lucide-react';
import '@/styles/brand.css';

export default function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      await login(email, password);
      navigate('/', { replace: true });
    } catch (err: any) {
      const msg = err?.response?.data?.message ?? 'Login gagal. Periksa email dan password.';
      setError(msg);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-v2">
      {/* ── Kiri: brand ─────────────────────────────────────── */}
      <section className="login-v2__brand" aria-hidden="true">
        <img className="login-v2__logo" src="/logo-mbg.png" alt="" />

        <div className="login-v2__headline">
          <h2>Pantau program Makan Bergizi Gratis dalam satu dashboard</h2>
          <p>
            Kelola jadwal distribusi menu, tanggapan siswa, dan laporan gizi
            sekolah dengan lebih mudah.
          </p>
        </div>

        <ul className="login-v2__features">
          <li><Truck size={16} /> Distribusi menu</li>
          <li><MessageSquare size={16} /> Feedback siswa</li>
          <li><BarChart3 size={16} /> Laporan gizi</li>
        </ul>
      </section>

      {/* ── Kanan: form ─────────────────────────────────────── */}
      <main className="login-v2__panel">
        <div className="login-v2__card">
          <img className="login-v2__mobile-logo" src="/logo-mbg.png" alt="Logo MBG" />

          <h1 className="login-v2__title">Selamat Datang!</h1>
          <p className="login-v2__subtitle">
            Masuk ke Foodler, dashboard pengelola program MBG.
          </p>

          <form className="lv2-form" onSubmit={handleSubmit} noValidate>
            <div className="lv2-field">
              <label htmlFor="login-email" className="lv2-label">Email Admin</label>
              <div className="lv2-input-wrap">
                <Mail size={18} className="lv2-input-icon" />
                <input
                  id="login-email"
                  type="email"
                  className="lv2-input"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@mbg.test"
                  required
                  autoFocus
                  autoComplete="username"
                />
              </div>
            </div>

            <div className="lv2-field">
              <label htmlFor="login-password" className="lv2-label">Password</label>
              <div className="lv2-input-wrap">
                <Lock size={18} className="lv2-input-icon" />
                <input
                  id="login-password"
                  type={showPassword ? 'text' : 'password'}
                  className="lv2-input"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  className="lv2-eye"
                  onClick={() => setShowPassword((s) => !s)}
                  aria-label={showPassword ? 'Sembunyikan password' : 'Tampilkan password'}
                  title={showPassword ? 'Sembunyikan password' : 'Tampilkan password'}
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {error && (
              <div className="lv2-alert" role="alert">
                {error}
              </div>
            )}

            <button
              id="login-submit-btn"
              type="submit"
              className="lv2-btn"
              disabled={isLoading}
            >
              {isLoading ? (
                <span className="lv2-spinner" />
              ) : (
                <>
                  <LogIn size={18} />
                  Masuk ke Dashboard
                </>
              )}
            </button>
          </form>

          <p className="lv2-note">
            Dashboard ini hanya untuk admin pengelola program Makan Bergizi Gratis (MBG).
            Akun siswa tidak dapat masuk ke halaman ini.
          </p>
        </div>
      </main>
    </div>
  );
}