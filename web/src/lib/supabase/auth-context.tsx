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
import { getSupabaseClient } from "./client";

interface AuthState {
  carregando: boolean;
  user: AppUser | null;
  aprovado: boolean;
}

interface AuthContextValue extends AuthState {
  logado: boolean;
  pendenteAprovacao: boolean;
  entrarComGoogle: () => Promise<void>;
  sair: () => Promise<void>;
  reverificarAprovacao: () => Promise<void>;
  atualizarNome: (nome: string) => Promise<void>;
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

  useEffect(() => {
    let ativo = true;
    (async () => {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      const user = mapUser(session?.user ?? null);
      const aprovado = user ? await checarAprovacao() : false;
      if (ativo) setState({ carregando: false, user, aprovado });
    })();

    const { data: sub } = supabase.auth.onAuthStateChange(async (_event, session) => {
      const user = mapUser(session?.user ?? null);
      const aprovado = user ? await checarAprovacao() : false;
      if (ativo) setState({ carregando: false, user, aprovado });
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
    setState({ carregando: false, user: null, aprovado: false });
  }, [supabase]);

  const reverificarAprovacao = useCallback(async () => {
    if (!state.user) return;
    const aprovado = await checarAprovacao();
    setState((s) => ({ ...s, aprovado }));
  }, [state.user, checarAprovacao]);

  const atualizarNome = useCallback(async (nome: string) => {
    const limpo = nome.trim();
    if (!limpo) return;
    const { data, error } = await supabase.auth.updateUser({ data: { display_name: limpo } });
    if (error) throw error;
    const user = mapUser(data.user);
    setState((s) => ({ ...s, user }));
  }, [supabase]);

  const value: AuthContextValue = {
    ...state,
    logado: state.user != null,
    pendenteAprovacao: state.user != null && !state.aprovado,
    entrarComGoogle,
    sair,
    reverificarAprovacao,
    atualizarNome,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth deve ser usado dentro de <AuthProvider>");
  return ctx;
}
