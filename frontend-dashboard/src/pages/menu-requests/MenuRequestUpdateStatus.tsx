import { useState } from 'react';
import { menuRequestsApi } from '@/api/endpoints';
import type { MenuRequest, MenuRequestStatus } from '@/types/api.types';
import { STATUSES, STATUS_LABELS } from './types';

interface MenuRequestUpdateStatusProps {
  request: MenuRequest;
  onSuccess: () => void;
  onClose: () => void;
}

export default function MenuRequestUpdateStatus({ request, onSuccess, onClose }: MenuRequestUpdateStatusProps) {
  const [newStatus, setNewStatus] = useState<MenuRequestStatus>(request.status as MenuRequestStatus);
  const [adminNote, setAdminNote] = useState(request.adminNote ?? '');
  const [isSaving, setIsSaving] = useState(false);

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await menuRequestsApi.updateStatus(request.id, newStatus, adminNote);
      onSuccess();
    } catch (err: any) {
      alert(err?.response?.data?.message ?? 'Gagal menyimpan status');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <h3 className="modal__title">Update Status Usulan</h3>
        <div className="form-group">
          <label className="form-label">Status Baru</label>
          <select id="modal-status-select" className="form-input"
            value={newStatus} onChange={(e) => setNewStatus(e.target.value as MenuRequestStatus)}>
            {STATUSES.map((s) => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
          </select>
        </div>
        <div className="form-group">
          <label className="form-label">Catatan Admin (opsional)</label>
          <textarea id="modal-admin-note" className="form-input" rows={3}
            value={adminNote} onChange={(e) => setAdminNote(e.target.value)}
            placeholder="Contoh: Akan dipertimbangkan untuk menu bulan depan" />
        </div>
        <div className="modal__actions">
          <button className="btn btn--ghost" onClick={onClose}>Batal</button>
          <button id="modal-save-btn" className="btn btn--primary" onClick={handleSave} disabled={isSaving}>
            {isSaving ? <span className="spinner spinner--sm" /> : 'Simpan'}
          </button>
        </div>
      </div>
    </div>
  );
}
