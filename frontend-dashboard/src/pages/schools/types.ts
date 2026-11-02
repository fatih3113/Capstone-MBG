export interface SchoolForm {
  name: string;
  level: string;
  address: string;
  city: string;
  sppgId: string;
}

export const emptySchoolForm = (): SchoolForm => ({
  name: '',
  level: '',
  address: '',
  city: '',
  sppgId: '',
});

/** Jenjang di tab Sekolah */
export const SEKOLAH_LEVELS = ['SD', 'SMP', 'SMA', 'SMK', 'Puskesmas', 'Lainnya'];

/** Jenjang di tab Posyandu */
export const POSYANDU_LEVELS = ['Posyandu'];

/** Gabungan — dipakai SchoolEdit */
export const LEVELS = [...SEKOLAH_LEVELS, ...POSYANDU_LEVELS];

export const LEVEL_COLOR: Record<string, string> = {
  SD: 'badge--blue',
  SMP: 'badge--green',
  SMA: 'badge--yellow',
  SMK: 'badge--purple',
  Posyandu: 'badge--orange',
  Puskesmas: 'badge--teal',
  Lainnya: 'badge--default',
};