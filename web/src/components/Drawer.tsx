"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useAuth } from "@/lib/supabase/auth-context";
import { useThemeMode } from "@/lib/theme-context";
import { useDrawer } from "./DrawerContext";
import { iniciais } from "@/lib/types";
import {
  IconHoje,
  IconPlano,
  IconModulos,
  IconControle,
  IconMateriais,
  IconBacklog,
  IconConcurso,
  IconAluno,
  IconSun,
  IconMoon,
  IconLogout,
} from "./Icons";

const itens = [
  { rota: "/hoje", titulo: "Hoje", icone: IconHoje },
  { rota: "/plano", titulo: "Plano", icone: IconPlano },
  { rota: "/modulos", titulo: "Módulos", icone: IconModulos },
  { rota: "/controle", titulo: "Controle", icone: IconControle },
  { rota: "/materiais", titulo: "Materiais", icone: IconMateriais },
  { rota: "/backlog", titulo: "Backlog", icone: IconBacklog },
  { rota: "/concurso", titulo: "Concurso", icone: IconConcurso },
  { rota: "/aluno", titulo: "Aluno", icone: IconAluno },
];

export function AppDrawer() {
  const { open, setOpen } = useDrawer();
  const pathname = usePathname();
  const router = useRouter();
  const { user, sair } = useAuth();
  const { tema, alternar } = useThemeMode();

  return (
    <>
      {open && (
        <div
          className="fixed inset-0 z-40"
          style={{ background: "rgba(0,0,0,0.4)" }}
          onClick={() => setOpen(false)}
        />
      )}
      <aside
        className="fixed top-0 left-0 z-50 h-full w-[280px] flex flex-col transition-transform duration-200"
        style={{
          background: "var(--card)",
          borderRight: "1px solid var(--card-border)",
          transform: open ? "translateX(0)" : "translateX(-100%)",
        }}
      >
        <div
          className="p-5"
          style={{ background: "var(--surface-tint-primary)" }}
        >
          <div
            className="rounded-full flex items-center justify-center font-bold mb-3"
            style={{
              width: 48,
              height: 48,
              background: "var(--primary)",
              color: "#fff",
            }}
          >
            {iniciais(user?.nome ?? "?")}
          </div>
          <div className="font-bold text-[15px]">{user?.nome ?? "Visitante"}</div>
          <div className="text-weak text-[12px]">{user?.email ?? ""}</div>
        </div>

        <nav className="flex-1 overflow-y-auto py-2">
          {itens.map((it) => {
            const ativo = pathname === it.rota || pathname.startsWith(it.rota + "/");
            const Icone = it.icone;
            return (
              <Link
                key={it.rota}
                href={it.rota}
                onClick={() => setOpen(false)}
                className="flex items-center gap-3 px-5 py-3 text-[14px] font-medium"
                style={{
                  background: ativo ? "var(--surface-tint-primary)" : "transparent",
                  color: ativo ? "var(--primary)" : "var(--text)",
                }}
              >
                <Icone size={20} filled={ativo} />
                {it.titulo}
              </Link>
            );
          })}
        </nav>

        <div style={{ borderTop: "1px solid var(--card-border)" }}>
          <button
            onClick={alternar}
            className="flex items-center gap-3 px-5 py-3 text-[14px] w-full text-left"
          >
            {tema === "dark" ? <IconMoon size={18} /> : <IconSun size={18} />}
            Tema {tema === "dark" ? "escuro" : "claro"}
          </button>
        </div>
        <div style={{ borderTop: "1px solid var(--card-border)" }}>
          <button
            onClick={async () => {
              setOpen(false);
              await sair();
              router.replace("/login");
            }}
            className="flex items-center gap-3 px-5 py-3 text-[14px] w-full text-left"
          >
            <IconLogout size={18} /> Sair
          </button>
        </div>
      </aside>
    </>
  );
}
