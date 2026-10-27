import { useState } from 'react';
import { schoolsApi } from '@/api/endpoints';
import type { SchoolItem } from '@/types/api.types';
import { X, Check } from 'lucide-react';
import { LEVELS } from './types';
import type { SchoolForm } from './types';

interface SchoolEditProps {
  school: SchoolItem;
  onSuccess: () => void;
  onClose: () => void;
}

export default function SchoolEdit({ school, onSuccess, onClose }: SchoolEditProps) {
  const [form, setForm] = useState<SchoolForm>({
    name: school.name,
    level: school.level,
    address: school.address ?? '',
    city: school.city ?? '',
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const handleSave = async () => {
    if (!form.name.trim() || !form.level) { setError('Nama dan jenjang wajib diisi.'); return; }
    setSaving(true); setError('');
    try {
      const body = { name: form.name, level: form.level, address: form.address || undefined, city: form.city || undefined };
      const res = await schoolsApi.update(school.id, body);
      if (!res.data.success) { setError(res.data.message); setSaving(false); return; }
      onSuccess();
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal menyimpan.');
    } finally { setSaving(false); }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()} role="dialog">
        <div className="modal__header">
          <h2 className="modal__title">Edit: {school.name}</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '.75rem' }}>{error}</div>}

          <div className="form-row-2">
            <div className="form-group">
              <label className="form-label" htmlFor="sch-name">Nama Sekolah / Lembaga *</label>
              <input id="sch-name" className="form-input" value={form.name} placeholder="cth. SDN 01 Jakarta"
                onChange={(e) => setForm({ ...form, name: e.target.value })} />
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="sch-level">Jenjang / Tipe *</label>
              <select id="sch-level" className="form-input" value={form.level}
                onChange={(e) => setForm({ ...form, level: e.target.value })}>
                <option value="">— Pilih —</option>
                {LEVELS.map((l) => <option key={l} value={l}>{l}</option>)}
              </select>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="sch-addr">Alamat</label>
            <textarea id="sch-addr" className="form-input" rows={2} value={form.address}
              placeholder="Opsional" style={{ resize: 'vertical' }}
              onChange={(e) => setForm({ ...form, address: e.target.value })} />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="sch-city">Kota / Kabupaten</label>
            <input id="sch-city" className="form-input" value={form.city} placeholder="cth. Jakarta Selatan"
              onChange={(e) => setForm({ ...form, city: e.target.value })} />
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={saving}>Batal</button>
          <button id="school-modal-save" className="btn btn--primary" onClick={handleSave} disabled={saving}>
            {saving ? 'Menyimpan...' : <><Check size={16} /> Simpan</>}
          </button>
        </div>
      </div>
    </div>
  );
}
