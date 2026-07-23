"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/supabase/auth-context";
import { LogoIcon } from "@/components/Logo";
import { GoogleG } from "@/components/Icons";

export default function LoginPage() {
  const auth = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (auth.logado && !auth.pendenteAprovacao) router.replace("/hoje");
    else if (auth.pendenteAprovacao) router.replace("/aguardando-aprovacao");
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
          <LogoIcon size={52} />
        </div>
        <h1 className="font-extrabold" style={{ fontSize: 26 }}>
          Concursos
        </h1>
        <p className="text-weak mt-1.5">Seu plano de estudo para o concurso</p>

        <button
          onClick={() => auth.entrarComGoogle()}
          disabled={auth.carregando}
          className="w-full mt-10 flex items-center justify-center gap-3 font-semibold"
          style={{
            height: 52,
            borderRadius: 12,
            background: "var(--surface-neutral-2)",
            color: "var(--text)",
            opacity: auth.carregando ? 0.6 : 1,
          }}
        >
          {auth.carregando ? (
            <Spinner />
          ) : (
            <>
              <GoogleG size={20} />
              Entrar com Google
            </>
          )}
        </button>

        <p className="text-weaker mt-4" style={{ fontSize: 11 }}>
          Seu acesso precisa ser autorizado previamente. Depois do login, se
          ainda não tiver liberação, você verá uma tela de acesso pendente.
        </p>
      </div>
    </main>
  );
}

function Spinner() {
  return (
    <span
      className="inline-block animate-spin rounded-full border-2"
      style={{
        width: 20,
        height: 20,
        borderColor: "var(--text-weaker)",
        borderTopColor: "transparent",
      }}
    />
  );
}
