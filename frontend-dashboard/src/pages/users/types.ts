export const ALLERGY_LABEL: Record<string, string> = {
  kacang: 'Kacang', telur: 'Telur', susu: 'Susu', ikan: 'Ikan',
  udang: 'Udang', gandum: 'Gandum', kedelai: 'Kedelai', lainnya: 'Lainnya',
};

/** Jenjang untuk filter pengguna di tab Sekolah */
export const LEVELS = ['SD', 'SMP', 'SMA', 'SMK'];

export const LEVEL_COLOR: Record<string, string> = {
  SD: 'badge--blue', SMP: 'badge--green', SMA: 'badge--yellow', SMK: 'badge--purple',
  Posyandu: 'badge--orange',
};

export const genderLabel = (g: string | null) =>
  g === 'L' ? 'Laki-laki' : g === 'P' ? 'Perempuan' : '—';

export const fmtDate = (iso: string) =>
  new Date(iso).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });