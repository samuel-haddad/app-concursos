"use client";

// Hooks de dados — espelham application/*_providers.dart (Riverpod) usando
// SWR para cache/revalidação client-side.
import useSWR, { useSWRConfig } from "swr";
import { useCallback, useMemo } from "react";
import { useAuth } from "@/lib/supabase/auth-context";
import type { Licao, Modulo } from "@/lib/types";
import type { Sessao } from "@/lib/types";
import {
  carregarBacklog,
  carregarConcurso,
  carregarDisponibilidade,
  carregarLicoes,
  carregarMateriais,
  carregarModulos,
  carregarPlano,
  carregarProgresso,
  carregarSessoesRealizadas,
  definirLicoesConcluidas,
  derivarSessoes,
  disponibilidadePadrao,
  marcarLicaoConcluida,
  marcarSessaoRealizada,
  ordenarSessoes,
  regenerarPlano,
  salvarDisponibilidade,
  sessaoId,
} from "./queries";

export function useModulos() {
  return useSWR("modulos", carregarModulos, { revalidateOnFocus: false });
}

export function useLicoes() {
  return useSWR("licoes", carregarLicoes, { revalidateOnFocus: false });
}

export function usePlano() {
  const { user } = useAuth();
  return useSWR(user ? ["plano", user.id] : null, carregarPlano, {
    revalidateOnFocus: false,
  });
}

export function useSessoes() {
  const { data: plano } = usePlano();
  return useMemo(() => (plano ? ordenarSessoes(derivarSessoes(plano)) : undefined), [plano]);
}

export function useConcurso() {
  return useSWR("concurso", carregarConcurso, { revalidateOnFocus: false });
}

export function useBacklog() {
  return useSWR("backlog", carregarBacklog, { revalidateOnFocus: false });
}

export function useMateriais() {
  return useSWR("materiais", carregarMateriais, { revalidateOnFocus: false });
}

export function useLicoesPorModulo() {
  const { data: licoesMap } = useLicoes();
  return useMemo(() => {
    if (!licoesMap) return undefined;
    const out: Record<string, Licao[]> = {};
    for (const l of Object.values(licoesMap)) {
      (out[l.moduloId] ??= []).push(l);
    }
    for (const lista of Object.values(out)) lista.sort((a, b) => a.nLicao - b.nLicao);
    return out;
  }, [licoesMap]);
}

export function useModulosPorNome() {
  const { data: mods } = useModulos();
  return useMemo(() => {
    if (!mods) return undefined;
    const out: Record<string, Modulo> = {};
    for (const m of mods) out[m.nome] = m;
    return out;
  }, [mods]);
}

export function useProgresso() {
  const { user } = useAuth();
  const key = user ? ["progresso", user.id] : null;
  const swr = useSWR(key, carregarProgresso, { revalidateOnFocus: false });

  // Escritas pontuais (upsert/delete só do que mudou) — nunca substitui o
  // conjunto inteiro, então cliques em lições diferentes não competem entre
  // si nem arriscam apagar progresso já salvo.
  const alternar = useCallback(
    async (licaoId: string) => {
      const atual = new Set(swr.data ?? []);
      const concluir = !atual.has(licaoId);
      if (concluir) atual.add(licaoId);
      else atual.delete(licaoId);
      // Guarda como array — ver comentário em carregarProgresso (queries.ts)
      // sobre por que o SWR precisa de array, não Set, pra notificar todos
      // os componentes inscritos na mesma chave (ex.: Módulo detalhe e
      // Controle abertos/montados ao mesmo tempo).
      await swr.mutate([...atual], { revalidate: false });
      await marcarLicaoConcluida(licaoId, concluir);
    },
    [swr],
  );

  const definirVarias = useCallback(
    async (ids: string[], concluir: boolean) => {
      const atual = new Set(swr.data ?? []);
      for (const id of ids) {
        if (concluir) atual.add(id);
        else atual.delete(id);
      }
      await swr.mutate([...atual], { revalidate: false });
      await definirLicoesConcluidas(ids, concluir);
    },
    [swr],
  );

  return { ...swr, alternar, definirVarias };
}

export function useSessoesRealizadas() {
  const { user } = useAuth();
  const key = user ? ["sessoes-realizadas", user.id] : null;
  const swr = useSWR(key, carregarSessoesRealizadas, { revalidateOnFocus: false });

  const alternar = useCallback(
    async (s: Sessao) => {
      const id = sessaoId(s);
      const atual = new Set(swr.data ?? []);
      const concluir = !atual.has(id);
      if (concluir) atual.add(id);
      else atual.delete(id);
      await swr.mutate([...atual], { revalidate: false });
      await marcarSessaoRealizada(s, concluir);
    },
    [swr],
  );

  return { ...swr, alternar };
}

export function useDisponibilidade() {
  const { user } = useAuth();
  const { mutate: mutateGlobal } = useSWRConfig();
  const key = user ? ["disponibilidade", user.id] : null;
  const swr = useSWR(key, carregarDisponibilidade, { revalidateOnFocus: false });

  /** Persiste a disponibilidade E regenera o plano numa única ação (chamada
   * pelo botão "Salvar e regenerar"). Nada é gravado antes disso — a edição na
   * tela fica só no rascunho local. Ao final, invalida o cache do plano para as
   * telas Hoje/Plano recarregarem. */
  const salvarERegenerar = useCallback(
    async (minutos: number[]) => {
      const limpo = minutos.map((m) => Math.max(0, Math.min(600, m)));
      await salvarDisponibilidade(limpo);
      await swr.mutate(limpo, { revalidate: false });
      const res = await regenerarPlano();
      if (user) {
        await mutateGlobal(["plano", user.id]);
        await mutateGlobal(["sessoes-realizadas", user.id]);
      }
      return res;
    },
    [swr, mutateGlobal, user],
  );

  return { ...swr, salvarERegenerar };
}
