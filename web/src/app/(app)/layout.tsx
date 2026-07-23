"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/supabase/auth-context";
import { DrawerProvider } from "@/components/DrawerContext";
import { AppDrawer } from "@/components/Drawer";
import { BottomNav } from "@/components/BottomNav";
import { LogoIcon } from "@/components/Logo";

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const auth = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (auth.carregando) return;
    if (!auth.logado) router.replace("/login");
    else if (auth.pendenteAprovacao) router.replace("/aguardando-aprovacao");
    else if (auth.precisaPrimeiroAcesso) router.replace("/primeiro-acesso");
  }, [auth.carregando, auth.logado, auth.pendenteAprovacao, auth.precisaPrimeiroAcesso, router]);

  if (auth.carregando || !auth.logado || auth.pendenteAprovacao || auth.precisaPrimeiroAcesso) {
    return (
      <main
        className="min-h-screen flex items-center justify-center"
        style={{ background: "var(--bg)" }}
      >
        <div className="animate-pulse">
          <LogoIcon size={48} />
        </div>
      </main>
    );
  }

  return (
    <DrawerProvider>
      <div className="min-h-screen" style={{ background: "var(--bg)", color: "var(--text)" }}>
        <AppDrawer />
        <div className="pb-[72px]">{children}</div>
        <BottomNav />
      </div>
    </DrawerProvider>
  );
}
