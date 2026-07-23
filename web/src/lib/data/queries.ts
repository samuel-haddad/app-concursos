"use client";

// Camada de dados: espelha lib/data/supabase/supabase_plano_repository.dart
// e afins do app Flutter. Conteúdo (modulo/licao/plano_dia/concurso) vem do
// Supabase; backlog e materiais continuam em JSON estático (mesmos arquivos
// do repo original).
import { getSupabaseClient } from "@/lib/supabase/client";
import type {
  Concurso,
  Licao,
  MaterialItem,
  Modulo,
  PlanoDia,
  Sessao,
} from "@/lib/types";
import backlogRaw from "./backlog.json";
import materiaisRaw from "./materiais.json";

export async function carregarModulos(): Promise<Modulo[]> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.from("modulo").select().order("ordem");
  if (error) throw error;
  return (data ?? []).map((e: Record<string, unknown>) => ({
    moduloId: String(e.modulo_id),
    ordem: Number(e.ordem ?? 0),
    nome: String(e.nome ?? ""),
    bloco: String(e.bloco ?? "FORA") as Modulo["bloco"],
    weight: Number(e.weight ?? 0),
    nLicoes: Number(e.n_licoes ?? 0),
    totalEstudoMin: Number(e.total_estudo_min ?? 0),
  }));
}

export async function carregarLicoes(): Promise<Record<string, Licao>> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.from("licao").select();
  if (error) throw error;
  const out: Record<string, Licao> = {};
  for (const e of (data ?? []) as Record<string, unknown>[]) {
    const l: Licao = {
      licaoId: String(e.licao_id),
      moduloId: String(e.modulo_id),
      modulo: String(e.modulo ?? ""),
      nLicao: Number(e.n_licao ?? 0),
      titulo: String(e.titulo ?? ""),
      docMin: Number(e.doc_min ?? 0),
      videoMin: Number(e.video_min ?? 0),
      estudoMin: Number(e.estudo_min ?? 0),
      bloco: String(e.bloco ?? "FORA") as Licao["bloco"],
      weight: Number(e.weight ?? 0),
    };
    out[l.licaoId] = l;
  }
  return out;
}

export async function carregarPlano(): Promise<PlanoDia[]> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];
  const { data, error } = await supabase
    .from("plano_dia")
    .select()
    .eq("user_id", user.id)
    .order("data");
  if (error) throw error;
  return (data ?? []).map((e: Record<string, unknown>) => ({
    data: String(e.data),
    diaSemana: String(e.dia_semana ?? ""),
    totalMin: Number(e.total_min ?? 0),
    revisaoMin: Number(e.revisao_min ?? 0),
    estudoMin: Number(e.estudo_min ?? 0),
    exerciciosMin: Number(e.exercicios_min ?? 0),
    nConteudos: Number(e.n_conteudos ?? 0),
    moduloDia: String(e.modulo_dia ?? ""),
    conteudoEstudo: String(e.conteudo_estudo ?? ""),
    licaoPrincipal: String(e.licao_principal ?? ""),
    revisaoRef: String(e.revisao_ref ?? ""),
    exerciciosRef: String(e.exercicios_ref ?? ""),
  }));
}

export async function carregarConcurso(): Promise<Concurso> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.from("concurso").select().limit(1).single();
  if (error) throw error;
  const e = data as Record<string, unknown>;
  return {
    banca: String(e.banca ?? ""),
    cargo: String(e.cargo ?? ""),
    orgao: String(e.orgao ?? ""),
    vagas: String(e.vagas ?? ""),
    escolaridade: String(e.escolaridade ?? ""),
    salario: Number(e.salario ?? 0),
    inscricaoIni: String(e.inscricao_ini),
    inscricaoFim: String(e.inscricao_fim),
    taxa: Number(e.taxa ?? 0),
    dataProva: String(e.data_prova),
  };
}

/** Reconstrói as sessões (Revisão/Estudo/Exercícios) de cada dia do plano —
 * mesma lógica de SupabasePlanoRepository.carregarSessoes(). O `idx` (posição
 * entre sessões do mesmo tipo no dia) segue o mesmo esquema já gravado em
 * `sessao_realizada` por versões anteriores do app — não mude a ordem de
 * inserção aqui sem migrar os dados existentes. */
export function derivarSessoes(dias: PlanoDia[]): Sessao[] {
  const out: Sessao[] = [];
  for (const d of dias) {
    if (d.revisaoMin > 0) {
      out.push({
        data: d.data,
        tipo: "REVISAO",
        minutos: d.revisaoMin,
        licaoRef: "",
        moduloRef: d.revisaoRef,
        idx: 0,
      });
    }
    const modulos = d.moduloDia.split(" + ");
    if (d.nConteudos >= 2 && modulos.length === 2) {
      const metade = Math.floor(d.estudoMin / 2);
      out.push({
        data: d.data,
        tipo: "ESTUDO",
        minutos: metade,
        licaoRef: d.licaoPrincipal,
        moduloRef: modulos[0],
        idx: 0,
      });
      out.push({
        data: d.data,
        tipo: "ESTUDO",
        minutos: d.estudoMin - metade,
        licaoRef: "",
        moduloRef: modulos[1],
        idx: 1,
      });
    } else {
      out.push({
        data: d.data,
        tipo: "ESTUDO",
        minutos: d.estudoMin,
        licaoRef: d.licaoPrincipal,
        moduloRef: d.moduloDia,
        idx: 0,
      });
    }
    out.push({
      data: d.data,
      tipo: "EXERCICIOS",
      minutos: d.exerciciosMin,
      licaoRef: d.licaoPrincipal,
      moduloRef: d.exerciciosRef,
      idx: 0,
    });
  }
  return out;
}

const ORDEM_TIPO: Record<string, number> = { REVISAO: 0, ESTUDO: 1, EXERCICIOS: 2 };
export function ordenarSessoes(sessoes: Sessao[]): Sessao[] {
  return [...sessoes].sort((a, b) => (ORDEM_TIPO[a.tipo] ?? 3) - (ORDEM_TIPO[b.tipo] ?? 3));
}

/** Id estável de uma sessão derivada (não existe PK própria — é recalculada
 * a partir de plano_dia a cada carregamento). Mesmo esquema `data|TIPO|idx`
 * já usado em `sessao_realizada` desde antes deste redesign — precisa bater
 * exatamente, senão o app não reconhece sessões marcadas anteriormente. */
export function sessaoId(s: Sessao): string {
  return `${s.data}|${s.tipo}|${s.idx}`;
}

// Retorna array (não Set): o SWR compara dados novos/antigos com `dequal`
// para decidir se re-renderiza os componentes inscritos, e `dequal` não
// enxerga os elementos de um Set (não são propriedades enumeráveis) — dois
// Sets com conteúdo diferente sempre "empatavam", então telas abertas em
// outras rotas (ex.: Controle) só viam a mudança depois de desmontar e
// remontar. Array compara elemento a elemento corretamente.
export async function carregarSessoesRealizadas(): Promise<string[]> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];
  const { data, error } = await supabase.from("sessao_realizada").select("sessao_id");
  if (error) throw error;
  return (data ?? []).map((e: { sessao_id: string }) => e.sessao_id);
}

export async function marcarSessaoRealizada(s: Sessao, concluida: boolean): Promise<void> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;
  const id = sessaoId(s);
  if (concluida) {
    await supabase.from("sessao_realizada").upsert(
      {
        user_id: user.id,
        sessao_id: id,
        data: s.data,
        tipo: s.tipo,
        minutos: s.minutos,
      },
      { onConflict: "user_id,sessao_id" },
    );
  } else {
    await supabase
      .from("sessao_realizada")
      .delete()
      .eq("user_id", user.id)
      .eq("sessao_id", id);
  }
}

// Ver comentário em carregarSessoesRealizadas: array em vez de Set para o
// SWR detectar mudanças corretamente entre telas diferentes.
export async function carregarProgresso(): Promise<string[]> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];
  const { data, error } = await supabase.from("licao_concluida").select("licao_id");
  if (error) throw error;
  return (data ?? []).map((e: { licao_id: string }) => e.licao_id);
}

/** Marca/desmarca UMA lição. Escrita pontual (upsert/delete só da linha em
 * questão) — nunca mexe nas outras linhas do usuário. A versão anterior
 * fazia delete-all + insert-all do conjunto inteiro a cada clique, o que
 * perdia dados quando duas lições eram marcadas em sequência rápida (a
 * segunda gravação apagava o conjunto antes da primeira "assentar"). */
export async function marcarLicaoConcluida(licaoId: string, concluida: boolean): Promise<void> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;
  if (concluida) {
    await supabase
      .from("licao_concluida")
      .upsert({ user_id: user.id, licao_id: licaoId }, { onConflict: "user_id,licao_id" });
  } else {
    await supabase
      .from("licao_concluida")
      .delete()
      .eq("user_id", user.id)
      .eq("licao_id", licaoId);
  }
}

/** Marca/desmarca VÁRIAS lições de uma vez (botão "Concluir tudo"/"Limpar"
 * do módulo). Só toca nas linhas de `ids` — não apaga o progresso de outros
 * módulos. */
export async function definirLicoesConcluidas(ids: string[], concluir: boolean): Promise<void> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user || ids.length === 0) return;
  if (concluir) {
    await supabase
      .from("licao_concluida")
      .upsert(
        ids.map((licao_id) => ({ user_id: user.id, licao_id })),
        { onConflict: "user_id,licao_id" },
      );
  } else {
    await supabase.from("licao_concluida").delete().eq("user_id", user.id).in("licao_id", ids);
  }
}

export const disponibilidadePadrao = [120, 120, 120, 120, 120, 180, 180];

export async function carregarDisponibilidade(): Promise<number[]> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [...disponibilidadePadrao];
  const { data, error } = await supabase.from("disponibilidade").select("dia_semana,minutos");
  if (error) throw error;
  if (!data || data.length === 0) return [...disponibilidadePadrao];
  const arr = [...disponibilidadePadrao];
  for (const r of data as { dia_semana: number; minutos: number }[]) {
    if (r.dia_semana >= 0 && r.dia_semana < 7) arr[r.dia_semana] = r.minutos;
  }
  return arr;
}

export async function salvarDisponibilidade(minutosPorDia: number[]): Promise<void> {
  const supabase = getSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;
  const rows = minutosPorDia.map((minutos, dia_semana) => ({
    user_id: user.id,
    dia_semana,
    minutos,
  }));
  await supabase.from("disponibilidade").upsert(rows);
}

export interface RegenerarResultado {
  ok: boolean;
  inicio: string;
  fim: string;
  dias_gerados: number;
  backlog?: number;
  licoes_concluidas_preservadas?: number;
  aviso?: string;
}

/** Regenera o plano (plano_dia) a partir da disponibilidade atual via Edge
 * Function `regenerar-plano`. Só reescreve de amanhã em diante e preserva o
 * histórico de lições/sessões concluídas. */
export async function regenerarPlano(): Promise<RegenerarResultado> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.functions.invoke("regenerar-plano", { body: {} });
  if (error) throw error;
  if (data?.error) throw new Error(data.detail ? `${data.error}: ${data.detail}` : data.error);
  return data as RegenerarResultado;
}

interface BacklogRow {
  licao_id: string;
  modulo_id: string;
  modulo: string;
  n_licao: number;
  titulo: string;
  doc_min: number;
  video_min: number;
  estudo_min: number;
  bloco: string;
  weight: number;
}

export async function carregarBacklog(): Promise<Licao[]> {
  const rows = backlogRaw as BacklogRow[];
  const lista: Licao[] = rows.map((e) => ({
    licaoId: e.licao_id,
    moduloId: e.modulo_id,
    modulo: e.modulo,
    nLicao: e.n_licao,
    titulo: e.titulo,
    docMin: e.doc_min,
    videoMin: e.video_min,
    estudoMin: e.estudo_min,
    bloco: e.bloco as Licao["bloco"],
    weight: e.weight,
  }));
  lista.sort((a, b) => (b.weight - a.weight) || a.moduloId.localeCompare(b.moduloId));
  return lista;
}

export async function carregarMateriais(): Promise<Record<string, MaterialItem[]>> {
  return materiaisRaw as unknown as Record<string, MaterialItem[]>;
}

/** URL assinada temporária (Edge Function `assinar-material`, exige login). */
export async function urlAssinadaMaterial(key: string): Promise<string> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.functions.invoke("assinar-material", {
    body: { key },
  });
  if (error || !data?.url) {
    throw new Error("Não foi possível assinar o material.");
  }
  return data.url as string;
}
