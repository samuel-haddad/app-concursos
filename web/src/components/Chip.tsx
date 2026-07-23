export function Chip({
  children,
  color,
}: {
  children: React.ReactNode;
  color?: string;
}) {
  return (
    <span
      className="chip"
      style={
        color
          ? { color, background: `color-mix(in srgb, ${color} 12%, transparent)` }
          : { color: "var(--text)", background: "var(--surface-neutral-2)" }
      }
    >
      {children}
    </span>
  );
}

export function Checkbox({
  checked,
  onChange,
  size = 26,
}: {
  checked: boolean;
  onChange: () => void;
  size?: number;
}) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      onClick={onChange}
      className="tap-checkbox"
      data-checked={checked}
      style={{ width: size, height: size, minWidth: size }}
    >
      {checked ? (
        <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 24 24" fill="none">
          <path
            d="M5 13l4 4L19 7"
            stroke="#fff"
            strokeWidth="3"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      ) : null}
    </button>
  );
}
