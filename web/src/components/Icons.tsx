// Conjunto mínimo de ícones outline (24x24, stroke=currentColor) — evita
// depender de um pacote de ícones externo só para ~20 símbolos fixos.
type IconProps = { size?: number; className?: string; filled?: boolean };
const base = {
  fill: "none" as const,
  strokeWidth: 1.8,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
};

export function IconHoje({ size = 22, className, filled }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <rect x="3.5" y="5" width="17" height="15" rx="3" {...base} fill={filled ? "currentColor" : "none"} fillOpacity={filled ? 0.15 : 0} />
      <path d="M3.5 9.5h17M8 3v3M16 3v3" {...base} />
      {filled && <circle cx="12" cy="14.5" r="2" fill="currentColor" stroke="none" />}
    </svg>
  );
}

export function IconPlano({ size = 22, className, filled }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <rect x="3.5" y="5" width="17" height="15" rx="3" {...base} fill={filled ? "currentColor" : "none"} fillOpacity={filled ? 0.15 : 0} />
      <path d="M3.5 9.5h17M8 3v3M16 3v3M8 13.5h.01M12 13.5h.01M16 13.5h.01M8 17h.01M12 17h.01" {...base} />
    </svg>
  );
}

export function IconModulos({ size = 22, className, filled }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path
        d="M4 5.5A2.5 2.5 0 016.5 3H19a1 1 0 011 1v14a1 1 0 01-1 1H6.5A2.5 2.5 0 004 16.5v-11z"
        {...base}
        fill={filled ? "currentColor" : "none"}
        fillOpacity={filled ? 0.15 : 0}
      />
      <path d="M4 16.5A2.5 2.5 0 006.5 19H20" {...base} />
    </svg>
  );
}

export function IconControle({ size = 22, className, filled }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M4 20V10M11 20V4M18 20v-7" {...base} fill="none" />
      {filled && (
        <path d="M2.5 20h19" stroke="currentColor" strokeWidth={1.8} strokeLinecap="round" />
      )}
    </svg>
  );
}

export function IconMateriais({ size = 22, className, filled }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path
        d="M3.5 7.5a2 2 0 012-2H9l2 2h7.5a2 2 0 012 2v7a2 2 0 01-2 2h-13a2 2 0 01-2-2v-9z"
        {...base}
        fill={filled ? "currentColor" : "none"}
        fillOpacity={filled ? 0.15 : 0}
      />
    </svg>
  );
}

export function IconBacklog({ size = 22, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M4 4h16l-2 8H6L4 4z" {...base} />
      <path d="M6 12l1.2 7h9.6L18 12" {...base} />
    </svg>
  );
}

export function IconConcurso({ size = 22, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="12" cy="8.5" r="5" {...base} />
      <path d="M8.5 12.8L7 21l5-2.5 5 2.5-1.5-8.2" {...base} />
    </svg>
  );
}

export function IconAluno({ size = 22, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="12" cy="8" r="3.5" {...base} />
      <path d="M4.5 20c1-4 4-5.5 7.5-5.5s6.5 1.5 7.5 5.5" {...base} />
    </svg>
  );
}

export function IconChevronLeft({ size = 20, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M15 5l-7 7 7 7" {...base} />
    </svg>
  );
}

export function IconChevronRight({ size = 20, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M9 5l7 7-7 7" {...base} />
    </svg>
  );
}

export function IconMenu({ size = 24, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M4 6h16M4 12h16M4 18h16" {...base} />
    </svg>
  );
}

export function IconClose({ size = 22, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M6 6l12 12M18 6L6 18" {...base} />
    </svg>
  );
}

export function IconCheck({ size = 16, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M5 13l4 4L19 7" {...base} />
    </svg>
  );
}

export function IconCheckCircle({ size = 20, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="12" cy="12" r="9" {...base} />
      <path d="M8 12.5l2.5 2.5L16 9" {...base} />
    </svg>
  );
}

export function IconTarget({ size = 20, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="12" cy="12" r="8" {...base} />
      <circle cx="12" cy="12" r="3" {...base} />
      <path d="M12 2v3M12 19v3M2 12h3M19 12h3" {...base} />
    </svg>
  );
}

export function IconTimer({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="12" cy="13" r="8" {...base} />
      <path d="M12 9v4l3 2M9 2h6" {...base} />
    </svg>
  );
}

export function IconFolder({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M3.5 7.5a2 2 0 012-2H9l2 2h7.5a2 2 0 012 2v7a2 2 0 01-2 2h-13a2 2 0 01-2-2v-9z" {...base} />
    </svg>
  );
}

export function IconPdf({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M6 3h9l5 5v13a1 1 0 01-1 1H6a1 1 0 01-1-1V4a1 1 0 011-1z" {...base} />
      <path d="M15 3v5h5" {...base} />
    </svg>
  );
}

export function IconAudio({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M9 18V5l10-2v13" {...base} />
      <circle cx="6.5" cy="18" r="2.5" {...base} />
      <circle cx="16.5" cy="16" r="2.5" {...base} />
    </svg>
  );
}

export function IconVideo({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <rect x="3" y="6" width="13" height="12" rx="2" {...base} />
      <path d="M16 10l5-3v10l-5-3" {...base} />
    </svg>
  );
}

export function IconOpenExternal({ size = 16, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M14 4h6v6M20 4l-9 9M6 5H5a1 1 0 00-1 1v13a1 1 0 001 1h13a1 1 0 001-1v-1" {...base} />
    </svg>
  );
}

export function IconPlus({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M12 5v14M5 12h14" {...base} />
    </svg>
  );
}

export function IconMinus({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M5 12h14" {...base} />
    </svg>
  );
}

export function IconRefresh({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M4 12a8 8 0 0113.66-5.66L20 8M4 12a8 8 0 0013.66 5.66L20 16M20 4v4h-4M4 20v-4h4" {...base} />
    </svg>
  );
}

export function IconLogout({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9" {...base} />
    </svg>
  );
}

export function IconSun({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="12" cy="12" r="4.5" {...base} />
      <path d="M12 2v2.5M12 19.5V22M4.2 4.2l1.8 1.8M18 18l1.8 1.8M2 12h2.5M19.5 12H22M4.2 19.8L6 18M18 6l1.8-1.8" {...base} />
    </svg>
  );
}

export function IconMoon({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M20 14.5A8.5 8.5 0 119.5 4a7 7 0 0010.5 10.5z" {...base} />
    </svg>
  );
}

export function IconWeekend({ size = 20, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M3 17v-4a5 5 0 015-5h8a5 5 0 015 5v4" {...base} />
      <path d="M2 17h20M4 17v2M20 17v2" {...base} />
    </svg>
  );
}

export function IconWeekday({ size = 20, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <rect x="3.5" y="5" width="17" height="15" rx="3" {...base} />
      <path d="M3.5 9.5h17M8 12.5h8" {...base} />
    </svg>
  );
}

export function IconInfo({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="12" cy="12" r="9" {...base} />
      <path d="M12 11v5.5M12 8v.01" {...base} />
    </svg>
  );
}

export function GoogleG({ size = 20 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48">
      <path
        fill="#FFC107"
        d="M43.6 20.5H42V20H24v8h11.3c-1.6 4.6-6 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.6 6.1 29.6 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.7-.4-3.5z"
      />
      <path
        fill="#FF3D00"
        d="M6.3 14.7l6.6 4.8C14.6 15.9 18.9 13 24 13c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.6 6.1 29.6 4 24 4c-7.4 0-13.8 4.2-17.7 10.7z"
      />
      <path
        fill="#4CAF50"
        d="M24 44c5.5 0 10.4-2.1 14.1-5.6l-6.5-5.5C29.6 34.6 26.9 35.5 24 35.5c-5.3 0-9.7-3.4-11.3-8l-6.6 5.1C9.7 39.6 16.3 44 24 44z"
      />
      <path
        fill="#1976D2"
        d="M43.6 20.5H42V20H24v8h11.3c-.8 2.3-2.2 4.2-4.1 5.5l6.5 5.5C41.5 35.9 44 30.4 44 24c0-1.3-.1-2.7-.4-3.5z"
      />
    </svg>
  );
}

export function IconEdit({ size = 16, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M4 20l.9-3.9L16.6 4.4a1.5 1.5 0 012.1 0l.9.9a1.5 1.5 0 010 2.1L7.9 19.1 4 20z" {...base} />
      <path d="M14.5 6.5l3 3" {...base} />
    </svg>
  );
}

export function IconSearch({ size = 18, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <circle cx="10.5" cy="10.5" r="6.5" {...base} />
      <path d="M20 20l-4.8-4.8" {...base} />
    </svg>
  );
}

export function IconHourglass({ size = 44, className }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" stroke="currentColor" className={className}>
      <path d="M6 3h12M6 21h12M6 3c0 5 4 6.5 6 9-2 2.5-6 4-6 9M18 3c0 5-4 6.5-6 9 2 2.5 6 4 6 9" {...base} />
    </svg>
  );
}
