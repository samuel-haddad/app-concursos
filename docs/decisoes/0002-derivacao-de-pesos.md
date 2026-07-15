# ADR 0002 — Origem dos pesos de prioridade

- **Status:** Aceito (atualizado em 2026-07-14)
- **Data:** 2026-07-14

## Contexto
A regra de prioridade depende da coluna `weight` de `indice_curso.csv`.

## Histórico
- **v1 (primeira geração):** a coluna `weight` veio **vazia**. Os pesos foram provisoriamente
  derivados do edital (itens por bloco de prova).
- **v2 (atual):** o usuário **preencheu os pesos no CSV**. Agora os pesos são lidos **direto do
  arquivo**, não mais derivados.

## Decisão
Ler `weight` de `indice_curso.csv`. Um valor nulo é preenchido com o peso predominante do próprio
módulo (mode); se o módulo inteiro estiver sem peso, assume 0. O único nulo atual está no módulo 18
(fora do edital), que já é peso 0.

Pesos vigentes (por módulo): 5 → 01, 07, 12; 4 → 13, 14, 15, 16; 3 → 11, 17; 2 → 05, 08, 09, 10;
0 → 02, 03, 04, 06, 18. Peso 0 vai integralmente para o backlog.

## Consequências
- O usuário controla a priorização **editando o CSV** — o app poderá expor isso por lição.
- O bloco de prova (P1/P2/P3/P4) deixa de influenciar o peso; permanece apenas como rótulo de
  referência para o dashboard (mapeado do edital, seção 15.2).
