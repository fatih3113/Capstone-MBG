import { useState } from 'react';
import { foodsApi } from '@/api/endpoints';
import type { FoodItem } from '@/types/api.types';
import { X, Check } from 'lucide-react';
import { emptyNutr } from './types';
import type { FoodForm } from './types';
import FoodFormFields from './FoodFormFields';

interface FoodEditProps {
  food: FoodItem;
  categories: string[];
  onSuccess: () => void;
  onClose: () => void;
}

export default function FoodEdit({ food, categories, onSuccess, onClose }: FoodEditProps) {
  const [form, setForm] = useState<FoodForm>({
    name: food.name,
    category: food.category,
    description: food.description ?? '',
    isActive: food.isActive,
    nutrition: food.nutrition ? {
      calories: food.nutrition.calories, protein: food.nutrition.protein,
      carbs: food.nutrition.carbs, fat: food.nutrition.fat, fiber: food.nutrition.fiber,
      sugar: food.nutrition.sugar, sodium: food.nutrition.sodium,
      calcium: food.nutrition.calcium, iron: food.nutrition.iron,
      vitaminC: food.nutrition.vitaminC, vitaminA: food.nutrition.vitaminA,
      portionGram: food.nutrition.portionGram,
      cookingMethod: food.nutrition.cookingMethod ?? 'mentah',
      dataSource: food.nutrition.dataSource,
    } : emptyNutr(),
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const handleSave = async () => {
    if (!form.name.trim() || !form.category) { setError('Nama dan kategori wajib diisi.'); return; }
    setSaving(true); setError('');
    try {
      const body = {
        name: form.name, category: form.category, description: form.description || null,
        isActive: form.isActive, nutrition: form.nutrition,
      };
      const res = await foodsApi.update(food.id, body as Parameters<typeof foodsApi.update>[1]);
      if (!res.data.success) { setError(res.data.message); setSaving(false); return; }
      onSuccess();
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal menyimpan.');
    } finally { setSaving(false); }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--lg" onClick={(e) => e.stopPropagation()} role="dialog">
        <div className="modal__header">
          <h2 className="modal__title">Edit: {food.name}</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '.75rem' }}>{error}</div>}
          <FoodFormFields form={form} setForm={setForm} categories={categories} />
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={saving}>Batal</button>
          <button id="food-modal-save" className="btn btn--primary" onClick={handleSave} disabled={saving}>
            {saving ? 'Menyimpan...' : <><Check size={16} /> Simpan</>}
          </button>
        </div>
      </div>
    </div>
  );
}
