"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/supabase/auth-context";
import { IconHourglass, IconLogout, IconRefresh } from "@/components/Icons";

export default function AguardandoAprovacaoPage() {
  const auth = useAuth();
  const router = useRouter();
  const [verificando, setVerificando] = useState(false);

  useEffect(() => {
    if (!auth.logado) router.replace("/login");
    else if (auth.logado && !auth.pendenteAprovacao) router.replace("/hoje");
  }, [auth.logado, auth.pendenteAprovacao, router]);

  return (
    <main
      className="min-h-screen flex items-center justify-center px-6"
      style={{ background: "var(--bg)" }}
    >
      <div className="w-full max-w-[380px] flex flex-col items-center text-center">
        <div
          className="rounded-[22px] flex items-center justify-center mb-5"
          style={{ width: 84, height: 84, background: "var(--surface-tint-primary)" }}
        >
          <IconHourglass size={44} className="text-[var(--primary)]" />
        </div>
        <h1 className="font-extrabold" style={{ fontSize: 22 }}>
          Acesso pendente
        </h1>
        <p className="text-weak mt-2 text-[14px]">
          Olá, {auth.user?.nome ?? ""}. Seu cadastro ({auth.user?.email ?? ""})
          ainda não foi autorizado a acessar o app. Peça a liberação ao
          administrador e tente novamente.
        </p>

        <button
          onClick={async () => {
            setVerificando(true);
            await auth.reverificarAprovacao();
            setVerificando(false);
          }}
          disabled={verificando}
          className="w-full mt-8 flex items-center justify-center gap-2 font-semibold text-white"
          style={{ height: 48, borderRadius: 12, background: "var(--primary)" }}
        >
          <IconRefresh size={18} />
          {verificando ? "Verificando…" : "Já fui liberado, verificar de novo"}
        </button>

        <button
          onClick={async () => {
            await auth.sair();
            router.replace("/login");
          }}
          className="mt-3 flex items-center justify-center gap-2 text-weak text-[14px] font-medium"
        >
          <IconLogout size={16} /> Sair
        </button>
      </div>
    </main>
  );
}
