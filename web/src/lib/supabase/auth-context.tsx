"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";
import type { AppUser } from "@/lib/types";
import { BASE_PATH } from "@/lib/base-path";
import { temDisponibilidadeSalva } from "@/lib/data/queries";
import { getSupabaseClient } from "./client";

interface AuthState {
  carregando: boolean;
  user: AppUser | null;
  aprovado: boolean;
  precisaOnboarding: boolean;
}

interface AuthContextValue extends AuthState {
  logado: boolean;
  pendenteAprovacao: boolean;
  /** true quando o usuário está aprovado mas ainda não passou pelo fluxo de
   * primeiro acesso (nome + disponibilidade inicial). */
  precisaPrimeiroAcesso: boolean;
  entrarComGoogle: () => Promise<void>;
  sair: () => Promise<void>;
  reverificarAprovacao: () => Promise<void>;
  atualizarNome: (nome: string) => Promise<void>;
  /** Chamado ao final do wizard de primeiro acesso, depois que a
   * disponibilidade já foi salva — evita re-consultar o banco. */
  marcarPrimeiroAcessoConcluido: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function mapUser(u: {
  id: string;
  email?: string | null;
  user_metadata?: Record<string, unknown>;
} | null): AppUser | null {
  if (!u) return null;
  const m = u.user_metadata ?? {};
  // `display_name` é a nossa chave (editável pelo aluno em "Aluno"). Fica
  // separada de `full_name`/`name`, que o próprio Google reenvia a cada
  // login e sobrescreveria um nome customizado se usássemos a mesma chave.
  return {
    id: u.id,
    nome:
      (m.display_name as string) ||
      (m.full_name as string) ||
      (m.name as string) ||
      u.email ||
      "Usuário",
    email: u.email ?? "",
    avatarUrl: (m.avatar_url as string) ?? null,
  };
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const supabase = getSupabaseClient();
  const [state, setState] = useState<AuthState>({
    carregando: true,
    user: null,
    aprovado: false,
    precisaOnboarding: false,
  });

  const checarAprovacao = useCallback(async () => {
    try {
      const { data, error } = await supabase.rpc("is_estudo_tcdf_approved_user");
      if (error) return false;
      return data === true;
    } catch {
      return false;
    }
  }, [supabase]);

  // Só faz sentido perguntar "precisa de onboarding" depois de aprovado —
  // antes disso a RLS de `disponibilidade` bloquearia a consulta de qualquer
  // forma (dono + aprovado).
  const checarOnboarding = useCallback(async (aprovado: boolean) => {
    if (!aprovado) return false;
    try {
      const tem = await temDisponibilidadeSalva();
      return !tem;
    } catch {
      return false;
    }
  }, []);

  useEffect(() => {
    let ativo = true;
    (async () => {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      const user = mapUser(session?.user ?? null);
      const aprovado = user ? await checarAprovacao() : false;
      const precisaOnboarding = user ? await checarOnboarding(aprovado) : false;
      if (ativo) setState({ carregando: false, user, aprovado, precisaOnboarding });
    })();

    const { data: sub } = supabase.auth.onAuthStateChange(async (_event, session) => {
      const user = mapUser(session?.user ?? null);
      const aprovado = user ? await checarAprovacao() : false;
      const precisaOnboarding = user ? await checarOnboarding(aprovado) : false;
      if (ativo) setState({ carregando: false, user, aprovado, precisaOnboarding });
    });

    return () => {
      ativo = false;
      sub.subscription.unsubscribe();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const entrarComGoogle = useCallback(async () => {
    setState((s) => ({ ...s, carregando: true }));
    const origem = process.env.NEXT_PUBLIC_SITE_URL || window.location.origin;
    // Inclui o basePath (/app-concursos no GitHub Pages) para o OAuth
    // voltar para a página certa, não para a raiz do domínio.
    const redirectTo = `${origem}${BASE_PATH}/`;
    await supabase.auth.signInWithOAuth({
      provider: "google",
      options: { redirectTo },
    });
  }, [supabase]);

  const sair = useCallback(async () => {
    await supabase.auth.signOut();
    setState({ carregando: false, user: null, aprovado: false, precisaOnboarding: false });
  }, [supabase]);

  const reverificarAprovacao = useCallback(async () => {
    if (!state.user) return;
    const aprovado = await checarAprovacao();
    const precisaOnboarding = await checarOnboarding(aprovado);
    setState((s) => ({ ...s, aprovado, precisaOnboarding }));
  }, [state.user, checarAprovacao, checarOnboarding]);

  const atualizarNome = useCallback(async (nome: string) => {
    const limpo = nome.trim();
    if (!limpo) return;
    const { data, error } = await supabase.auth.updateUser({ data: { display_name: limpo } });
    if (error) throw error;
    const user = mapUser(data.user);
    setState((s) => ({ ...s, user }));
  }, [supabase]);

  const marcarPrimeiroAcessoConcluido = useCallback(() => {
    setState((s) => ({ ...s, precisaOnboarding: false }));
  }, []);

  const value: AuthContextValue = {
    ...state,
    logado: state.user != null,
    pendenteAprovacao: state.user != null && !state.aprovado,
    precisaPrimeiroAcesso: state.user != null && state.aprovado && state.precisaOnboarding,
    entrarComGoogle,
    sair,
    reverificarAprovacao,
    atualizarNome,
    marcarPrimeiroAcessoConcluido,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth deve ser usado dentro de <AuthProvider>");
  return ctx;
}
