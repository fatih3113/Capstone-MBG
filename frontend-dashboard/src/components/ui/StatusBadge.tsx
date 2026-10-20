const STATUS_CONFIG: Record<string, { label: string; className: string }> = {
  received:    { label: 'Diterima',         className: 'badge--received' },
  reviewing:   { label: 'Ditinjau',          className: 'badge--reviewing' },
  considered:  { label: 'Dipertimbangkan',   className: 'badge--considered' },
  approved:    { label: 'Disetujui ✅',      className: 'badge--approved' },
  rejected:    { label: 'Ditolak ❌',        className: 'badge--rejected' },
  habis:       { label: 'Habis 🍽',          className: 'badge--approved' },
  sebagian:    { label: 'Sebagian',          className: 'badge--reviewing' },
  hampir_tidak: { label: 'Hampir Tidak',    className: 'badge--rejected' },
  tidak_diisi: { label: 'Tidak Diisi',       className: 'badge--received' },
};

export default function StatusBadge({ status }: { status: string }) {
  const config = STATUS_CONFIG[status] ?? { label: status, className: 'badge--received' };
  return (
    <span className={`badge ${config.className}`}>
      {config.label}
    </span>
  );
}
