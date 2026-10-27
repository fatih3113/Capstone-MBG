import { useState } from 'react';
import { distributionApi } from '@/api/endpoints';
import type { DistributionRecord } from '@/types/api.types';
import { X, Trash2, AlertTriangle } from 'lucide-react';
import { fmtDate } from './types';

interface ScheduleDeleteProps {
  record: DistributionRecord;
  onSuccess: () => void;
  onClose: () => void;
}

export default function ScheduleDelete({ record, onSuccess, onClose }: ScheduleDeleteProps) {
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState('');

  const handleDelete = async () => {
    setDeleting(true); setError('');
    try {
      await distributionApi.deleteSchedule(record.id);
      onSuccess();
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Gagal menghapus jadwal.');
    } finally { setDeleting(false); }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal--sm" onClick={(e) => e.stopPropagation()}>
        <div className="modal__header">
          <h2 className="modal__title">Hapus Jadwal</h2>
          <button className="modal__close" onClick={onClose}><X size={20} /></button>
        </div>
        <div className="modal__body">
          {error && <div className="alert alert--error" style={{ marginBottom: '.75rem' }}>{error}</div>}
          <div className="delete-confirm">
            <AlertTriangle size={36} color="#ef4444" />
            <p>Hapus jadwal distribusi <strong>{record.school.name}</strong> pada <strong>{fmtDate(record.date)}</strong>?</p>
            <p className="delete-confirm__sub">Menu yang sudah dibuat tidak dapat dikembalikan.</p>
          </div>
        </div>
        <div className="modal__footer">
          <button className="btn btn--ghost" onClick={onClose} disabled={deleting}>Batal</button>
          <button id="modal-delete-confirm-btn" className="btn btn--danger" onClick={handleDelete} disabled={deleting}>
            {deleting ? 'Menghapus...' : <><Trash2 size={15} /> Ya, Hapus</>}
          </button>
        </div>
      </div>
    </div>
  );
}
