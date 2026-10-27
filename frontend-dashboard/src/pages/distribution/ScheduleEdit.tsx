import { useState } from 'react';
import { distributionApi } from '@/api/endpoints';
import type { DistributionRecord, School, FoodOption } from '@/types/api.types';
import { X, Check, Plus, Trash2 } from 'lucide-react';
import type { ScheduleForm, FormItem } from './types';

interface ScheduleEditProps {
  record: DistributionRecord;
  schools: School[];
  foods: FoodOption[];
  onSuccess: () => void;
  onClose: () => void;
}

export default function ScheduleEdit({ record, schools, foods, onSuccess, onClose }: ScheduleEditProps) {
  const school = schools.find((s) => s.name === record.school.name);
  const [form, setForm] = useState<ScheduleForm>({
    schoolId: school?.id ?? '',
    date: record.date,
    items: record.foods.map((f) => {
      const food = foods.find((fd) => fd.name === f.name);
      return { foodId: food?.id ?? '', portionGram: f.portionGram };
    }),
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const groupedFoods = foods.reduce<Record<string, FoodOption[]>>((acc, f) => {
    (acc[f.category] ??= []).push(f);
    return acc;
  }, {});

  const setItem = (idx: number, key: keyof FormItem, val: string | number) => {
    const items = [...form.items];
    items[idx] = { ...items[idx], [key]: val };
    setForm({ ...form, items });
  };
  const addItem = () => setForm({ ...form, items: [...form.items, { foodId: '', portionGram: 100 }] });
  const removeItem = (idx: number) => setForm({ ...form, items: form.items.filter((_, i) => i !== idx) });

  const handleSave = async () => {
    if (!form.schoolId || !form.date) { setError('Sekolah dan tanggal wajib diisi.'); return; }
    if (form.items.some((i) => !i.foodId)) { setError('Semua baris makanan harus dipilih.'); return; }
    setSaving(true); setError('');
    try {
      const res = await distributionApi.updateSchedule(record.id, form);
      if (!res.data.success) { setError(res.data.message); setSaving(false); return; }
      onSuccess();
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal menyimpan jadwal.');
    } finally { setSaving(false); }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()} role="dialog" aria-modal="true">
        <div className="modal__header">
          <h2 className="modal__title">Edit Jadwal Distribusi</h2>
          <button className="modal__close" onClick={onClose} aria-label="Tutup"><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '1rem' }}>{error}</div>}
          <div className="form-group">
            <label className="form-label" htmlFor="sched-school">Sekolah *</label>
            <select id="sched-school" className="form-input" value={form.schoolId}
              onChange={(e) => setForm({ ...form, schoolId: e.target.value })}>
              <option value="">— Pilih sekolah —</option>
              {schools.map((s) => <option key={s.id} value={s.id}>{s.name} ({s.level})</option>)}
            </select>
          </div>
          <div className="form-group">
            <label className="form-label" htmlFor="sched-date">Tanggal Distribusi *</label>
            <input id="sched-date" type="date" className="form-input" value={form.date}
              onChange={(e) => setForm({ ...form, date: e.target.value })} />
          </div>
          <div className="form-group">
            <label className="form-label">Menu Makanan *</label>
            <div className="menu-items-list">
              {form.items.map((item, idx) => (
                <div key={idx} className="menu-item-row">
                  <select className="form-input flex-1" value={item.foodId}
                    onChange={(e) => setItem(idx, 'foodId', e.target.value)}>
                    <option value="">— Pilih makanan —</option>
                    {Object.entries(groupedFoods).map(([cat, fs]) => (
                      <optgroup key={cat} label={cat}>
                        {fs.map((f) => <option key={f.id} value={f.id}>{f.name}</option>)}
                      </optgroup>
                    ))}
                  </select>
                  <div className="portion-input">
                    <input type="number" className="form-input" value={item.portionGram} min={10} max={500}
                      onChange={(e) => setItem(idx, 'portionGram', +e.target.value)} style={{ width: '80px' }} />
                    <span className="unit-label">g</span>
                  </div>
                  <button className="icon-btn icon-btn--danger" onClick={() => removeItem(idx)}
                    disabled={form.items.length <= 1} title="Hapus item"><Trash2 size={15} /></button>
                </div>
              ))}
              <button className="btn btn--ghost btn--sm" type="button" onClick={addItem}>
                <Plus size={14} /> Tambah Makanan
              </button>
            </div>
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={saving}>Batal</button>
          <button id="modal-save-btn" className="btn btn--primary" onClick={handleSave} disabled={saving}>
            {saving ? 'Menyimpan...' : <><Check size={16} /> Simpan</>}
          </button>
        </div>
      </div>
    </div>
  );
}
