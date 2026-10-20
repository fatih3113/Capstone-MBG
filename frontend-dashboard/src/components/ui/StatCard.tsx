interface StatCardProps {
  label: string;
  value: string | number;
  sub?: string;
  color?: 'blue' | 'green' | 'orange' | 'purple' | 'red';
  icon?: React.ReactNode;
}

export default function StatCard({ label, value, sub, color = 'blue', icon }: StatCardProps) {
  return (
    <div className={`stat-card stat-card--${color}`} role="region" aria-label={label}>
      <div className="stat-card__header">
        <span className="stat-card__label">{label}</span>
        {icon && <span className="stat-card__icon">{icon}</span>}
      </div>
      <div className="stat-card__value">{value}</div>
      {sub && <div className="stat-card__sub">{sub}</div>}
    </div>
  );
}
