import { useState } from 'react';
import { schoolsApi } from '@/api/endpoints';
import type { SchoolItem } from '@/types/api.types';
import { X, Trash2, AlertTriangle } from 'lucide-react';

interface SchoolDeleteProps {
  school: SchoolItem;
  onSuccess: () => void;
  onClose: () => void;
}

export default function SchoolDelete({ school, onSuccess, onClose }: SchoolDeleteProps) {
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState('');

  const handleDelete = async () => {
    setDeleting(true); setError('');
    try {
      const res = await schoolsApi.delete(school.id);
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
          <h2 className="modal__title">Hapus Sekolah</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '.75rem' }}>{error}</div>}
          <div className="delete-confirm">
            <AlertTriangle size={36} color="#ef4444" />
            <p>Hapus <strong>{school.name}</strong>?</p>
            {school._count.mbgMenus > 0 && (
              <p className="delete-confirm__sub" style={{ color: '#ef4444' }}>
                ⚠️ Sekolah ini memiliki {school._count.mbgMenus} jadwal distribusi dan tidak bisa dihapus.
              </p>
            )}
            {school._count.mbgMenus === 0 && (
              <p className="delete-confirm__sub">Data ini akan dihapus permanen.</p>
            )}
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={deleting}>Batal</button>
          <button id="school-delete-confirm" className="btn btn--danger"
            onClick={handleDelete} disabled={deleting || school._count.mbgMenus > 0}>
            {deleting ? 'Menghapus...' : <><Trash2 size={15} /> Hapus</>}
          </button>
        </div>
      </div>
    </div>
  );
}
