"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { IconHoje, IconPlano, IconModulos, IconControle, IconMateriais } from "./Icons";

const tabs = [
  { rota: "/hoje", titulo: "Hoje", icone: IconHoje },
  { rota: "/plano", titulo: "Plano", icone: IconPlano },
  { rota: "/modulos", titulo: "Módulos", icone: IconModulos },
  { rota: "/controle", titulo: "Controle", icone: IconControle },
  { rota: "/materiais", titulo: "Materiais", icone: IconMateriais },
];

export function BottomNav() {
  const pathname = usePathname();
  return (
    <nav
      className="fixed bottom-0 left-0 right-0 z-30 flex"
      style={{
        background: "var(--tabbar-bg)",
        borderTop: "1px solid var(--card-border)",
        paddingBottom: "env(safe-area-inset-bottom)",
      }}
    >
      {tabs.map((t) => {
        const ativo = pathname === t.rota || pathname.startsWith(t.rota + "/");
        const Icone = t.icone;
        return (
          <Link
            key={t.rota}
            href={t.rota}
            className="flex-1 flex flex-col items-center gap-0.5 py-2"
            style={{ color: ativo ? "var(--primary)" : "var(--text-weaker)" }}
          >
            <Icone size={22} filled={ativo} />
            <span className="text-[11px]" style={{ fontWeight: ativo ? 700 : 500 }}>
              {t.titulo}
            </span>
          </Link>
        );
      })}
    </nav>
  );
}
