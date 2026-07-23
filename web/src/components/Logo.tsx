// Monograma "C" desenhado como anel de progresso (ver README do handoff de
// design: arco com abertura à direita, ponta arredondada). Ícone sólido
// (tile azul) usado na app bar e na tela de login.
export function LogoIcon({ size = 34 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 96 96" fill="none" aria-hidden>
      <rect width="96" height="96" rx="24" fill="#0263e0" />
      <path
        d="M63 27 A26 26 0 1 0 63 69"
        fill="none"
        stroke="#fff"
        strokeWidth="11"
        strokeLinecap="round"
      />
    </svg>
  );
}

export function LogoLockup({ iconSize = 28 }: { iconSize?: number }) {
  return (
    <div className="flex items-center gap-2">
      <LogoIcon size={iconSize} />
      <span className="font-extrabold tracking-tight" style={{ fontSize: 18 }}>
        Concursos
      </span>
    </div>
  );
}
