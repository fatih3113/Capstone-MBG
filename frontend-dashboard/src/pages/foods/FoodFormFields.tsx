import { X, Check } from 'lucide-react';
import type { FoodForm, NutrForm } from './types';
import { NUTR_FIELDS, COOKING_METHODS, catLabel } from './types';

interface FoodFormFieldsProps {
  form: FoodForm;
  setForm: (f: FoodForm) => void;
  categories: string[];
}

export default function FoodFormFields({ form, setForm, categories }: FoodFormFieldsProps) {
  const setNutr = (key: keyof NutrForm, val: string | number) =>
    setForm({ ...form, nutrition: { ...form.nutrition, [key]: val } });

  return (
    <>
      {/* Info dasar */}
      <p className="modal__section-title">Informasi Makanan</p>
      <div className="form-row-2">
        <div className="form-group">
          <label className="form-label" htmlFor="food-name">Nama Makanan *</label>
          <input id="food-name" className="form-input" value={form.name}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            placeholder="cth. Nasi Putih" />
        </div>
        <div className="form-group">
          <label className="form-label" htmlFor="food-cat">Kategori *</label>
          <select id="food-cat" className="form-input" value={form.category}
            onChange={(e) => setForm({ ...form, category: e.target.value })}>
            <option value="">— Pilih —</option>
            {categories.map((c) => <option key={c} value={c}>{catLabel(c)}</option>)}
          </select>
        </div>
      </div>
      <div className="form-group">
        <label className="form-label" htmlFor="food-desc">Deskripsi</label>
        <textarea id="food-desc" className="form-input" rows={2} value={form.description}
          onChange={(e) => setForm({ ...form, description: e.target.value })}
          placeholder="Opsional" style={{ resize: 'vertical' }} />
      </div>
      <div className="form-group">
        <label className="form-label">Status</label>
        <label className="toggle-label">
          <input type="checkbox" checked={form.isActive}
            onChange={(e) => setForm({ ...form, isActive: e.target.checked })} />
          <span>{form.isActive ? 'Aktif' : 'Nonaktif'}</span>
        </label>
      </div>

      {/* Data gizi */}
      <p className="modal__section-title" style={{ marginTop: '1rem' }}>
        Data Gizi <span style={{ fontWeight: 400, fontSize: '.78rem', color: 'var(--color-text-3)' }}>(per 100 g kecuali Per Porsi)</span>
      </p>
      <div className="nutr-grid">
        {NUTR_FIELDS.map(({ key, label, unit }) => (
          <div key={key} className="form-group">
            <label className="form-label">{label} <span className="unit-label">({unit})</span></label>
            <input type="number" className="form-input" min={0} step={0.1}
              value={form.nutrition[key] as number}
              onChange={(e) => setNutr(key, +e.target.value)} />
          </div>
        ))}
      </div>
      <div className="form-row-2">
        <div className="form-group">
          <label className="form-label" htmlFor="food-cook">Cara Masak</label>
          <select id="food-cook" className="form-input" value={form.nutrition.cookingMethod ?? ''}
            onChange={(e) => setNutr('cookingMethod', e.target.value)}>
            {COOKING_METHODS.map((m) => <option key={m} value={m}>{m}</option>)}
          </select>
        </div>
        <div className="form-group">
          <label className="form-label" htmlFor="food-src">Sumber Data</label>
          <input id="food-src" className="form-input" value={form.nutrition.dataSource}
            onChange={(e) => setNutr('dataSource', e.target.value)} />
        </div>
      </div>
    </>
  );
}
