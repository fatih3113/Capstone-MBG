export interface SchoolForm {
  name: string;
  level: string;
  address: string;
  city: string;
}

export const emptySchoolForm = (): SchoolForm => ({
  name: '',
  level: '',
  address: '',
  city: '',
});

export const LEVELS = ['SD', 'SMP', 'SMA', 'SMK', 'Posyandu', 'Puskesmas', 'Lainnya'];

export const LEVEL_COLOR: Record<string, string> = {
  SD: 'badge--blue',
  SMP: 'badge--green',
  SMA: 'badge--yellow',
  SMK: 'badge--purple',
  Posyandu: 'badge--orange',
  Puskesmas: 'badge--teal',
  Lainnya: 'badge--default',
};
