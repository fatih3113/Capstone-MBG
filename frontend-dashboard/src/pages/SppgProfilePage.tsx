import { FormEvent, useEffect, useState } from 'react';
import { sppgApi } from '@/api/endpoints';
import type { SppgItem } from '@/types/api.types';

/** Profil SPPG milik Admin SPPG Daerah. Hanya kontak/alamat/kapasitas yang bisa diubah. */
export default function SppgProfilePage() {
  const [sppg, setSppg] = useState<SppgItem | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [saving, setSaving] = useState(false);

  const [alamat, setAlamat] = useState('');
  const [penanggungjawab, setPenanggungjawab] = useState('');
  const [kontak, setKontak] = useState('');
  const [kapasitasPorsi, setKapasitasPorsi] = useState('');

  const fill = (s: SppgItem) => {
    setSppg(s);
    setAlamat(s.alamat ?? '');
    setPenanggungjawab(s.penanggungjawab ?? '');
    setKontak(s.kontak ?? '');
    setKapasitasPorsi(s.kapasitasPorsi != null ? String(s.kapasitasPorsi) : '');
  };

  useEffect(() => {
    sppgApi.mine()
      .then((res) => {
        if (res.data.success) fill(res.data.data);
        else setError(res.data.message ?? 'Gagal memuat profil SPPG');
      })
      .catch((err) => setError(err?.response?.data?.message ?? 'Gagal memuat profil SPPG'))
      .finally(() => setIsLoading(false));
  }, []);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (!sppg) return;
    setError(''); setSuccess('');

    if (kapasitasPorsi && (!/^\d+$/.test(kapasitasPorsi) || +kapasitasPorsi < 1)) {
      setError('Kapasitas porsi harus berupa bilangan bulat positif.');
      return;
    }

    setSaving(true);
    try {
      const res = await sppgApi.updateProfile(sppg.id, {
        ...(alamat.trim() && { alamat: alamat.trim() }),
        ...(penanggungjawab.trim() && { penanggungjawab: penanggungjawab.trim() }),
        ...(kontak.trim() && { kontak: kontak.trim() }),
        ...(kapasitasPorsi && { kapasitasPorsi: Number(kapasitasPorsi) }),
      });
      fill({ ...sppg, ...res.data.data });
      setSuccess('Profil SPPG berhasil diperbarui.');
    } catch (err: any) {
      const msg = err?.response?.data?.message;
      setError(Array.isArray(msg) ? msg.join('. ') : msg ?? 'Gagal menyimpan perubahan');
    } finally {
      setSaving(false);
    }
  };

  if (isLoading) {
    return <div className="loading-state"><div className="spinner" /><p>Memuat...</p></div>;
  }

  return (
    <div className="page">
      <div className="page__header">
        <div>
          <h1 className="page__title">Profil SPPG</h1>
          <p className="page__subtitle">Data SPPG Anda. Nama dan wilayah hanya dapat diubah Super Admin.</p>
        </div>
      </div>

      {error && <div className="alert alert--error">{error}</div>}
      {success && <div className="alert alert--info">{success}</div>}

      {sppg && (
        <div className="table-card" style={{ padding: 24 }}>
          <dl className="verif-detail">
            <dt>Nama SPPG</dt><dd>{sppg.nama}</dd>
            <dt>Kode</dt><dd>{sppg.kode ?? '—'}</dd>
            <dt>Provinsi</dt><dd>{sppg.provinsi}</dd>
            <dt>Kabupaten / Kota</dt><dd>{sppg.kabupatenKota}</dd>
            <dt>Kecamatan</dt><dd>{sppg.kecamatan}</dd>
            <dt>Kelurahan / Desa</dt><dd>{sppg.kelurahanDesa}</dd>
            <dt>Sekolah binaan</dt><dd>{sppg._count.schools}</dd>
            <dt>Siswa terdaftar</dt><dd>{sppg._count.users}</dd>
          </dl>

          <form onSubmit={handleSubmit}>
            <div className="form-grid form-grid--2">
              <div className="form-group form-group--full">
                <label className="form-label" htmlFor="prof-alamat">Alamat</label>
                <textarea id="prof-alamat" className="form-input" rows={2} value={alamat}
                  onChange={(e) => setAlamat(e.target.value)} />
              </div>
              <div className="form-group">
                <label className="form-label" htmlFor="prof-pj">Penanggung Jawab</label>
                <input id="prof-pj" className="form-input" value={penanggungjawab}
                  onChange={(e) => setPenanggungjawab(e.target.value)} />
              </div>
              <div className="form-group">
                <label className="form-label" htmlFor="prof-kontak">Kontak</label>
                <input id="prof-kontak" className="form-input" value={kontak}
                  onChange={(e) => setKontak(e.target.value)} />
              </div>
              <div className="form-group">
                <label className="form-label" htmlFor="prof-kap">Kapasitas Porsi / Hari</label>
                <input id="prof-kap" className="form-input" inputMode="numeric" value={kapasitasPorsi}
                  onChange={(e) => setKapasitasPorsi(e.target.value.replace(/\D/g, ''))} />
              </div>
            </div>
            <div className="modal__actions">
              <button type="submit" className="btn btn--primary" disabled={saving}>
                {saving ? <span className="spinner spinner--sm" /> : 'Simpan Perubahan'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
