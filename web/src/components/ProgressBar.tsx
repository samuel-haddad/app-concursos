export function ProgressBar({
  value,
  height = 6,
  color = "var(--primary)",
  track,
}: {
  /** 0..1 */
  value: number;
  height?: number;
  color?: string;
  track?: string;
}) {
  const pct = Math.max(0, Math.min(1, value)) * 100;
  return (
    <div
      className="progress-track"
      style={{ height, background: track }}
    >
      <div className="progress-fill" style={{ width: `${pct}%`, background: color }} />
    </div>
  );
}
