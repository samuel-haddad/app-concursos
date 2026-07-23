// Modelos de domínio (espelham lib/domain/models/*.dart do app Flutter).

export type Bloco = "P1" | "P2" | "P3" | "P4" | "FORA";
export type TipoSessao = "REVISAO" | "ESTUDO" | "EXERCICIOS";
export type TipoMaterial = "PDF" | "AUDIO" | "VIDEO" | "OUTRO";

export interface Modulo {
  moduloId: string;
  ordem: number;
  nome: string;
  bloco: Bloco;
  weight: number;
  nLicoes: number;
  totalEstudoMin: number;
}

export interface Licao {
  licaoId: string;
  moduloId: string;
  modulo: string;
  nLicao: number;
  titulo: string;
  docMin: number;
  videoMin: number;
  estudoMin: number;
  bloco: Bloco;
  weight: number;
}

export interface PlanoDia {
  data: string; // ISO yyyy-MM-dd
  diaSemana: string;
  totalMin: number;
  revisaoMin: number;
  estudoMin: number;
  exerciciosMin: number;
  nConteudos: number;
  moduloDia: string;
  conteudoEstudo: string;
  licaoPrincipal: string;
  revisaoRef: string;
  exerciciosRef: string;
}

export interface Sessao {
  data: string;
  tipo: TipoSessao;
  minutos: number;
  licaoRef: string;
  moduloRef: string;
  /** Posição entre sessões do mesmo tipo no mesmo dia (0, 1, ...) — usada
   * para formar o id estável em `sessao_realizada` (ver sessaoId em
   * lib/data/queries.ts). */
  idx: number;
}

export interface Concurso {
  banca: string;
  cargo: string;
  orgao: string;
  vagas: string;
  escolaridade: string;
  salario: number;
  inscricaoIni: string;
  inscricaoFim: string;
  taxa: number;
  dataProva: string;
}

export interface MaterialItem {
  tipo: TipoMaterial;
  titulo: string;
  key: string;
}

export interface AppUser {
  id: string;
  nome: string;
  email: string;
  avatarUrl?: string | null;
}

export function iniciais(nome: string): string {
  const partes = nome.trim().split(/\s+/);
  if (!partes.length || !partes[0]) return "?";
  if (partes.length === 1) return partes[0][0]?.toUpperCase() ?? "?";
  return (partes[0][0] + partes[partes.length - 1][0]).toUpperCase();
}

/** Data da prova (contagem regressiva) — mesma constante do app Flutter. */
export const DATA_PROVA = "2026-11-22";
