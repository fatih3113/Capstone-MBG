import { useState, FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Eye, EyeOff, UserPlus, Truck, MessageSquare, BarChart3 } from 'lucide-react';
import { authApi } from '@/api/endpoints';
import type { RegisterSppgPayload } from '@/types/api.types';
import '@/styles/brand.css';
import '@/styles/sppg-access.css';

interface FormState {
  name: string; email: string; password: string; confirmPassword: string;
  sppgNama: string; provinsi: string; kabupatenKota: string; kecamatan: string;
  kelurahanDesa: string; alamat: string; penanggungJawab: string; kontak: string;
  kapasitasPorsi: string; is3t: boolean;
}

const INITIAL: FormState = {
  name: '', email: '', password: '', confirmPassword: '',
  sppgNama: '', provinsi: '', kabupatenKota: '', kecamatan: '',
  kelurahanDesa: '', alamat: '', penanggungJawab: '', kontak: '',
  kapasitasPorsi: '', is3t: false,
};

/** Validasi sisi klien (backend tetap memvalidasi ulang). Mengembalikan pesan error atau ''. */
function validate(f: FormState): string {
  if (f.name.trim().length < 3) return 'Nama minimal 3 karakter.';
  if (!/^\S+@\S+\.\S+$/.test(f.email.trim())) return 'Format email tidak valid.';
  if (f.password.length < 8) return 'Password minimal 8 karakter.';
  if (!/[A-Za-z]/.test(f.password) || !/\d/.test(f.password)) {
    return 'Password harus mengandung huruf dan angka.';
  }
  if (f.password !== f.confirmPassword) return 'Konfirmasi password tidak sama.';
  if (f.sppgNama.trim().length < 3) return 'Nama SPPG minimal 3 karakter.';
  if (!f.provinsi.trim() || !f.kabupatenKota.trim() || !f.kecamatan.trim() || !f.kelurahanDesa.trim()) {
    return 'Provinsi, kabupaten/kota, kecamatan, dan kelurahan/desa wajib diisi.';
  }
  if (f.penanggungJawab.trim().length < 3) return 'Nama penanggung jawab minimal 3 karakter.';
  if (!/^[0-9+\-\s]{8,20}$/.test(f.kontak.trim())) return 'Kontak harus berupa nomor telepon yang valid.';
  if (f.kapasitasPorsi && (!/^\d+$/.test(f.kapasitasPorsi) || +f.kapasitasPorsi < 1)) {
    return 'Kapasitas porsi harus berupa bilangan bulat positif.';
  }
  return '';
}

export default function RegisterPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState<FormState>(INITIAL);
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const set = <K extends keyof FormState>(key: K, value: FormState[K]) =>
    setForm((prev) => ({ ...prev, [key]: value }));

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');

    const problem = validate(form);
    if (problem) { setError(problem); return; }

    const payload: RegisterSppgPayload = {
      name: form.name.trim(),
      email: form.email.trim(),
      password: form.password,
      sppgNama: form.sppgNama.trim(),
      provinsi: form.provinsi.trim(),
      kabupatenKota: form.kabupatenKota.trim(),
      kecamatan: form.kecamatan.trim(),
      kelurahanDesa: form.kelurahanDesa.trim(),
      penanggungJawab: form.penanggungJawab.trim(),
      kontak: form.kontak.trim(),
      is3t: form.is3t,
      ...(form.alamat.trim() && { alamat: form.alamat.trim() }),
      ...(form.kapasitasPorsi && { kapasitasPorsi: Number(form.kapasitasPorsi) }),
    };

    setIsLoading(true);
    try {
      await authApi.registerSppg(payload);
      navigate('/login', { replace: true, state: { registered: true } });
    } catch (err: any) {
      const msg = err?.response?.data?.message;
      setError(
        Array.isArray(msg) ? msg.join('. ')
          : msg ?? 'Pendaftaran gagal. Periksa data Anda lalu coba lagi.',
      );
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
          <h2>Daftarkan SPPG Anda ke program Makan Bergizi Gratis</h2>
          <p>
            Setelah pendaftaran diperiksa dan disetujui Super Admin, Anda dapat memantau
            distribusi menu dan tanggapan siswa di wilayah SPPG Anda.
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
        <div className="login-v2__card login-v2__card--wide">
          <img className="login-v2__mobile-logo" src="/logo-mbg.png" alt="Logo MBG" />

          <h1 className="login-v2__title">Daftar Admin SPPG</h1>
          <p className="login-v2__subtitle">
            Isi data akun dan SPPG Anda. Akun baru dapat dipakai setelah disetujui Super Admin.
          </p>

          <form className="lv2-form" onSubmit={handleSubmit} noValidate>
            <p className="reg-section">Akun Admin</p>
            <div className="reg-grid">
              <div className="lv2-field reg-full">
                <label htmlFor="reg-name" className="lv2-label">Nama Lengkap</label>
                <input id="reg-name" className="lv2-input lv2-input--plain" value={form.name}
                  onChange={(e) => set('name', e.target.value)} autoComplete="name" required />
              </div>
              <div className="lv2-field reg-full">
                <label htmlFor="reg-email" className="lv2-label">Email</label>
                <input id="reg-email" type="email" className="lv2-input lv2-input--plain" value={form.email}
                  onChange={(e) => set('email', e.target.value)} autoComplete="email" required />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-password" className="lv2-label">Password</label>
                <div className="lv2-input-wrap">
                  <input id="reg-password" type={showPassword ? 'text' : 'password'}
                    className="lv2-input lv2-input--plain" value={form.password}
                    onChange={(e) => set('password', e.target.value)} autoComplete="new-password" required />
                  <button type="button" className="lv2-eye" onClick={() => setShowPassword((s) => !s)}
                    aria-label={showPassword ? 'Sembunyikan password' : 'Tampilkan password'}>
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                <span className="reg-hint">Minimal 8 karakter, kombinasi huruf dan angka.</span>
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-confirm" className="lv2-label">Konfirmasi Password</label>
                <input id="reg-confirm" type={showPassword ? 'text' : 'password'}
                  className="lv2-input lv2-input--plain" value={form.confirmPassword}
                  onChange={(e) => set('confirmPassword', e.target.value)} autoComplete="new-password" required />
              </div>
            </div>

            <p className="reg-section">Data SPPG</p>
            <div className="reg-grid">
              <div className="lv2-field reg-full">
                <label htmlFor="reg-sppg" className="lv2-label">Nama SPPG</label>
                <input id="reg-sppg" className="lv2-input lv2-input--plain" value={form.sppgNama}
                  onChange={(e) => set('sppgNama', e.target.value)} required />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-prov" className="lv2-label">Provinsi</label>
                <input id="reg-prov" className="lv2-input lv2-input--plain" value={form.provinsi}
                  onChange={(e) => set('provinsi', e.target.value)} required />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-kab" className="lv2-label">Kabupaten / Kota</label>
                <input id="reg-kab" className="lv2-input lv2-input--plain" value={form.kabupatenKota}
                  onChange={(e) => set('kabupatenKota', e.target.value)} required />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-kec" className="lv2-label">Kecamatan</label>
                <input id="reg-kec" className="lv2-input lv2-input--plain" value={form.kecamatan}
                  onChange={(e) => set('kecamatan', e.target.value)} required />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-kel" className="lv2-label">Kelurahan / Desa</label>
                <input id="reg-kel" className="lv2-input lv2-input--plain" value={form.kelurahanDesa}
                  onChange={(e) => set('kelurahanDesa', e.target.value)} required />
              </div>
              <div className="lv2-field reg-full">
                <label htmlFor="reg-alamat" className="lv2-label">Alamat Lengkap (opsional)</label>
                <textarea id="reg-alamat" className="lv2-input lv2-input--plain" value={form.alamat}
                  onChange={(e) => set('alamat', e.target.value)} />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-pj" className="lv2-label">Penanggung Jawab</label>
                <input id="reg-pj" className="lv2-input lv2-input--plain" value={form.penanggungJawab}
                  onChange={(e) => set('penanggungJawab', e.target.value)} required />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-kontak" className="lv2-label">Kontak (No. Telepon)</label>
                <input id="reg-kontak" type="tel" className="lv2-input lv2-input--plain" value={form.kontak}
                  onChange={(e) => set('kontak', e.target.value)} placeholder="08xxxxxxxxxx" required />
              </div>
              <div className="lv2-field">
                <label htmlFor="reg-kapasitas" className="lv2-label">Kapasitas Porsi / Hari (opsional)</label>
                <input id="reg-kapasitas" inputMode="numeric" className="lv2-input lv2-input--plain"
                  value={form.kapasitasPorsi}
                  onChange={(e) => set('kapasitasPorsi', e.target.value.replace(/\D/g, ''))} />
              </div>
              <div className="lv2-field" style={{ justifyContent: 'flex-end' }}>
                <label className="reg-check" htmlFor="reg-3t">
                  <input id="reg-3t" type="checkbox" checked={form.is3t}
                    onChange={(e) => set('is3t', e.target.checked)} />
                  Wilayah 3T (Terdepan, Terluar, Tertinggal)
                </label>
              </div>
            </div>

            {error && <div className="lv2-alert" role="alert">{error}</div>}

            <button type="submit" className="lv2-btn" disabled={isLoading}>
              {isLoading ? <span className="lv2-spinner" /> : (<><UserPlus size={18} /> Kirim Pendaftaran</>)}
            </button>
          </form>

          <p className="lv2-switch">
            Sudah punya akun? <Link to="/login">Masuk</Link>
          </p>
        </div>
      </main>
    </div>
  );
}
