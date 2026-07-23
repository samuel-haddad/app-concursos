import type { Bloco, TipoSessao } from "./types";

// Cores por bloco de prova — usar via var(--bloco-xx) no CSS/inline style
// para respeitar automaticamente o tema claro/escuro ativo.
const blocoVar: Record<Bloco, string> = {
  P1: "var(--bloco-p1)",
  P2: "var(--bloco-p2)",
  P3: "var(--bloco-p3)",
  P4: "var(--bloco-p4)",
  FORA: "var(--bloco-fora)",
};

const blocoLabel: Record<Bloco, string> = {
  P1: "Básicos",
  P2: "Específicos",
  P3: "Especializados",
  P4: "Discursiva",
  FORA: "Fora do edital",
};

export function corBloco(bloco: string): string {
  return blocoVar[(bloco as Bloco)] ?? blocoVar.FORA;
}

export function rotuloBloco(bloco: string): string {
  return blocoLabel[(bloco as Bloco)] ?? blocoLabel.FORA;
}

const sessaoVar: Record<TipoSessao, string> = {
  REVISAO: "var(--sessao-revisao)",
  ESTUDO: "var(--sessao-estudo)",
  EXERCICIOS: "var(--sessao-exercicios)",
};

const sessaoLabel: Record<TipoSessao, string> = {
  REVISAO: "Revisão",
  ESTUDO: "Estudo",
  EXERCICIOS: "Exercícios",
};

export function corSessao(tipo: string): string {
  return sessaoVar[(tipo as TipoSessao)] ?? "var(--text-weaker)";
}

export function rotuloSessao(tipo: string): string {
  return sessaoLabel[(tipo as TipoSessao)] ?? tipo;
}
