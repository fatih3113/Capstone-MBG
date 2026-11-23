import type { FoodItem } from '@/types/api.types';
import { useAuth } from '@/hooks/useAuth';
import { Pencil, Trash2, ToggleLeft, ToggleRight, Utensils, Lock } from 'lucide-react';
import { CAT_BADGE, catLabel } from './types';

interface FoodListProps {
  records: FoodItem[];
  total: number;
  page: number;
  totalPages: number;
  onEdit: (food: FoodItem) => void;
  onDelete: (food: FoodItem) => void;
  onToggle: (food: FoodItem) => void;
  onPageChange: (page: number) => void;
}

export default function FoodList({
  records, total, page, totalPages, onEdit, onDelete, onToggle, onPageChange,
}: FoodListProps) {
  const { user, isSuperAdmin } = useAuth();

  return (
    <div>
      <div className="table-wrapper">
        <table className="data-table" id="foods-table">
          <thead>
            <tr>
              <th>Nama Makanan</th>
              <th>Kategori</th>
              <th style={{ textAlign: 'right' }}>Kalori</th>
              <th style={{ textAlign: 'right' }}>Protein</th>
              <th style={{ textAlign: 'right' }}>Karbo</th>
              <th style={{ textAlign: 'right' }}>Lemak</th>
              <th>Sumber</th>
              <th style={{ textAlign: 'center' }}>Status</th>
              <th style={{ textAlign: 'center', width: '90px' }}>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {records.length === 0 ? (
              <tr><td colSpan={9} style={{ textAlign: 'center', padding: '3rem', color: 'var(--color-text-3)' }}>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '.75rem' }}>
                  <Utensils size={32} /><span>Tidak ada makanan. Klik "Tambah Makanan".</span>
                </div>
              </td></tr>
            ) : records.map((food) => {
              // Admin SPPG hanya bisa mengubah/menghapus menu milik SPPG-nya sendiri
              const isOwner = Boolean(user?.sppgId) && food.sppgId === user?.sppgId;
              const canManage = isSuperAdmin || isOwner;

              return (
                <tr key={food.id} style={{ opacity: food.isActive ? 1 : 0.5 }}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap' }}>
                      <strong>{food.name}</strong>
                      {!food.sppgId ? (
                        <span className="badge badge--default" style={{ fontSize: '0.72rem', padding: '0.15rem 0.45rem' }}>
                          Master MBG
                        </span>
                      ) : isOwner ? (
                        <span className="badge badge--primary" style={{ fontSize: '0.72rem', padding: '0.15rem 0.45rem' }}>
                          SPPG Saya
                        </span>
                      ) : (
                        <span className="badge badge--info" style={{ fontSize: '0.72rem', padding: '0.15rem 0.45rem' }}>
                          {food.sppg?.nama ?? 'SPPG Lain'}
                        </span>
                      )}
                    </div>
                    {food.description && <div className="row-sub">{food.description}</div>}
                  </td>
                  <td>
                    <span className={`badge ${CAT_BADGE[food.category] ?? 'badge--default'}`}>
                      {catLabel(food.category)}
                    </span>
                  </td>
                  <td style={{ textAlign: 'right' }}>{food.nutrition?.calories.toFixed(0) ?? '—'}</td>
                  <td style={{ textAlign: 'right' }}>{food.nutrition?.protein.toFixed(1) ?? '—'}</td>
                  <td style={{ textAlign: 'right' }}>{food.nutrition?.carbs.toFixed(1) ?? '—'}</td>
                  <td style={{ textAlign: 'right' }}>{food.nutrition?.fat.toFixed(1) ?? '—'}</td>
                  <td style={{ fontSize: '.78rem', color: 'var(--color-text-3)' }}>
                    {food.nutrition?.dataSource ?? '—'}
                  </td>
                  <td style={{ textAlign: 'center' }}>
                    {canManage ? (
                      <button
                        className={`toggle-btn ${food.isActive ? 'toggle-btn--on' : 'toggle-btn--off'}`}
                        onClick={() => onToggle(food)}
                        title={food.isActive ? 'Nonaktifkan' : 'Aktifkan'}
                      >
                        {food.isActive ? <ToggleRight size={22} /> : <ToggleLeft size={22} />}
                      </button>
                    ) : (
                      <span className={`badge ${food.isActive ? 'badge--success' : 'badge--default'}`} style={{ fontSize: '0.75rem' }}>
                        {food.isActive ? 'Aktif' : 'Nonaktif'}
                      </span>
                    )}
                  </td>
                  <td style={{ textAlign: 'center' }}>
                    {canManage ? (
                      <div className="row-actions">
                        <button className="icon-btn" title="Edit" onClick={() => onEdit(food)}>
                          <Pencil size={15} />
                        </button>
                        <button className="icon-btn icon-btn--danger" title="Hapus" onClick={() => onDelete(food)}>
                          <Trash2 size={15} />
                        </button>
                      </div>
                    ) : (
                      <span
                        style={{ fontSize: '0.75rem', color: 'var(--color-text-3)', display: 'inline-flex', alignItems: 'center', gap: '0.2rem' }}
                        title="Menu Master MBG bersifat umum dan hanya dapat diubah oleh Super Admin"
                      >
                        <Lock size={12} /> Master
                      </span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="table-footer">
        <p className="table-footer__count">Total <strong>{total}</strong> makanan</p>
        {totalPages > 1 && (
          <div className="pagination">
            <button id="food-prev-page" className="btn btn--ghost btn--sm"
              disabled={page === 1} onClick={() => onPageChange(page - 1)}>← Sebelumnya</button>
            <span className="pagination__info">{page} / {totalPages}</span>
            <button id="food-next-page" className="btn btn--ghost btn--sm"
              disabled={page === totalPages} onClick={() => onPageChange(page + 1)}>Berikutnya →</button>
          </div>
        )}
      </div>
    </div>
  );
}
