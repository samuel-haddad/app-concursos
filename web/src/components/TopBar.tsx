"use client";

import { useRouter } from "next/navigation";
import { LogoIcon } from "./Logo";
import { useDrawer } from "./DrawerContext";
import { IconMenu, IconChevronLeft } from "./Icons";

export function TopBar({
  title,
  actions,
  back,
}: {
  title: string;
  actions?: React.ReactNode;
  /** Mostra seta de voltar em vez do menu hambúrguer (ex.: módulo detalhe). */
  back?: boolean;
}) {
  const { setOpen } = useDrawer();
  const router = useRouter();
  return (
    <header
      className="sticky top-0 z-20 flex items-center gap-3 px-4"
      style={{
        height: 58,
        background: "var(--bg)",
      }}
    >
      {back ? (
        <button className="icon-btn" onClick={() => router.back()} aria-label="Voltar">
          <IconChevronLeft size={20} />
        </button>
      ) : (
        <button className="icon-btn" onClick={() => setOpen(true)} aria-label="Abrir menu">
          <IconMenu size={20} />
        </button>
      )}
      {!back && <LogoIcon size={26} />}
      <h1 className="flex-1 truncate font-extrabold" style={{ fontSize: 20 }}>
        {title}
      </h1>
      {actions ? <div className="flex items-center gap-1.5">{actions}</div> : null}
    </header>
  );
}
