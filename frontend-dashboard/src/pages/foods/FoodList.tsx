import type { FoodItem } from '@/types/api.types';
import { Pencil, Trash2, ToggleLeft, ToggleRight, Utensils } from 'lucide-react';
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
            ) : records.map((food) => (
              <tr key={food.id} style={{ opacity: food.isActive ? 1 : 0.5 }}>
                <td>
                  <strong>{food.name}</strong>
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
                  <button
                    className={`toggle-btn ${food.isActive ? 'toggle-btn--on' : 'toggle-btn--off'}`}
                    onClick={() => onToggle(food)}
                    title={food.isActive ? 'Nonaktifkan' : 'Aktifkan'}
                  >
                    {food.isActive ? <ToggleRight size={22} /> : <ToggleLeft size={22} />}
                  </button>
                </td>
                <td>
                  <div className="row-actions">
                    <button className="icon-btn" title="Edit" onClick={() => onEdit(food)}>
                      <Pencil size={15} />
                    </button>
                    <button className="icon-btn icon-btn--danger" title="Hapus" onClick={() => onDelete(food)}>
                      <Trash2 size={15} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
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
