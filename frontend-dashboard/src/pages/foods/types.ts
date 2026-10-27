import type { FoodNutrition } from '@/types/api.types';

export type NutrForm = Omit<FoodNutrition, 'id' | 'foodId'>;

export interface FoodForm {
  name: string;
  category: string;
  description: string;
  isActive: boolean;
  nutrition: NutrForm;
}

export const emptyNutr = (): NutrForm => ({
  calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0,
  sugar: 0, sodium: 0, calcium: 0, iron: 0, vitaminC: 0, vitaminA: 0,
  portionGram: 100, cookingMethod: 'mentah', dataSource: 'TKPI 2017',
});

export const emptyFoodForm = (): FoodForm => ({
  name: '', category: '', description: '', isActive: true, nutrition: emptyNutr(),
});

export const COOKING_METHODS = ['goreng', 'rebus', 'kukus', 'bakar', 'mentah'];

export const NUTR_FIELDS: { key: keyof NutrForm; label: string; unit: string }[] = [
  { key: 'calories', label: 'Kalori', unit: 'kcal' },
  { key: 'protein', label: 'Protein', unit: 'g' },
  { key: 'carbs', label: 'Karbohidrat', unit: 'g' },
  { key: 'fat', label: 'Lemak', unit: 'g' },
  { key: 'fiber', label: 'Serat', unit: 'g' },
  { key: 'sugar', label: 'Gula', unit: 'g' },
  { key: 'sodium', label: 'Natrium', unit: 'mg' },
  { key: 'calcium', label: 'Kalsium', unit: 'mg' },
  { key: 'iron', label: 'Zat Besi', unit: 'mg' },
  { key: 'vitaminC', label: 'Vitamin C', unit: 'mg' },
  { key: 'vitaminA', label: 'Vitamin A', unit: 'µg' },
  { key: 'portionGram', label: 'Per Porsi', unit: 'g' },
];

// Tampilkan nama kategori tanpa kata "Protein" (nilai asli di database tidak berubah)
// "Protein Nabati" -> "Nabati", "Protein Hewani" -> "Hewani"
export const catLabel = (c: string) =>
  c.replace(/\bprotein\b/gi, '').replace(/\s{2,}/g, ' ').trim() || c;

// Kunci harus sama dengan nama kategori ASLI di database.
// Nama dengan dan tanpa kata "Protein" sama-sama dicantumkan agar aman.
export const CAT_BADGE: Record<string, string> = {
  'Sayuran': 'badge--yellow',
  'Buah': 'badge--orange',
  'Minuman': 'badge--teal',
  'Makanan Pokok': 'badge--blue',
  'Protein Nabati': 'badge--yellow',
  'Protein Hewani': 'badge--orange',
  'Nabati': 'badge--yellow',
  'Hewani': 'badge--orange',
};
