import { useState } from 'react';
import { foodsApi } from '@/api/endpoints';
import type { FoodItem } from '@/types/api.types';
import { X, Trash2, AlertTriangle } from 'lucide-react';

interface FoodDeleteProps {
  food: FoodItem;
  onSuccess: () => void;
  onClose: () => void;
}

export default function FoodDelete({ food, onSuccess, onClose }: FoodDeleteProps) {
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState('');

  const handleDelete = async () => {
    setDeleting(true); setError('');
    try {
      const res = await foodsApi.delete(food.id);
      if (!res.data.success) { setError(res.data.message); setDeleting(false); return; }
      onSuccess();
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal menghapus.');
    } finally { setDeleting(false); }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--sm" onClick={(e) => e.stopPropagation()}>
        <div className="modal__header">
          <h2 className="modal__title">Hapus Makanan</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '.75rem' }}>{error}</div>}
          <div className="delete-confirm">
            <AlertTriangle size={36} color="#ef4444" />
            <p>Hapus <strong>{food.name}</strong> secara permanen?</p>
            <p className="delete-confirm__sub">Jika sudah dipakai di jadwal atau scan, gunakan Nonaktifkan saja.</p>
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={deleting}>Batal</button>
          <button id="food-delete-confirm" className="btn btn--danger" onClick={handleDelete} disabled={deleting}>
            {deleting ? 'Menghapus...' : <><Trash2 size={15} /> Hapus Permanen</>}
          </button>
        </div>
      </div>
    </div>
  );
}
