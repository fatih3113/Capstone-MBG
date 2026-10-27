import type { School, FoodOption } from '@/types/api.types';

export interface FormItem {
  foodId: string;
  portionGram: number;
}

export interface ScheduleForm {
  schoolId: string;
  date: string;
  items: FormItem[];
}

export const emptyScheduleForm = (): ScheduleForm => ({
  schoolId: '',
  date: '',
  items: [{ foodId: '', portionGram: 100 }],
});

export function fmtDate(d: string | null | undefined) {
  if (!d) return '—';
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });
}

export const LEVEL_COLOR: Record<string, string> = {
  SD: 'badge--blue',
  SMP: 'badge--green',
  SMA: 'badge--yellow',
  SMK: 'badge--purple',
};
