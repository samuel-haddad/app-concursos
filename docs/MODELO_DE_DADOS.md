# Modelo de Dados

Banco: **PostgreSQL** (Supabase). Schema completo em
[`../supabase/migrations/0001_schema_inicial.sql`](../supabase/migrations/0001_schema_inicial.sql).
App pessoal → **RLS** restringe todas as tabelas ao `owner = auth.uid()`.

## Diagrama (entidades e relações)

```
concurso            disponibilidade
(dados do certame)  (minutos por dia_semana 0..6)

modulo 1 ───< licao
  │              │
  │              ├──< material   (PDF/VIDEO/AUDIO por lição ou módulo)
  │              ├──< plano_sessao (licao_ref)
  │              ├── plano_dia    (licao_principal)
  │              └── backlog      (1:1 lição fora do plano)
  └──< material

plano_dia 1 ───< plano_sessao   (por data)
```

## Entidades

### `concurso`
Uma linha com os dados fixos do certame (banca, cargo, vagas, salário, datas, taxa, `data_prova`).
Alimenta a tela **Concurso** e a contagem regressiva.

### `disponibilidade`
Uma linha por dia da semana (`0=segunda … 6=domingo`) com `minutos` disponíveis. Alimenta a tela
**Aluno** e é entrada do gerador de plano. Semente atual: seg–sex = 60, sáb = 120, dom = 120.

### `modulo`
18 módulos. Campos: `ordem`, `nome`, `bloco` (P1/P2/P3/P4/FORA), `weight`, contagens e durações
agregadas (`total_doc_min`, `total_video_min`, `total_estudo_min`) e `concluido` (mantido por trigger).

### `licao`
175 lições. Campos: `modulo_id`, `n_licao`, `titulo`, `doc_min`, `video_min`, `estudo_min`, `bloco`,
`weight`, `concluido`, `concluido_em`. **Marcar `concluido` aqui** é a ação central de progresso.

### `material`
Materiais complementares (`PDF`, `VIDEO`, `AUDIO`) ligados a um módulo (e opcionalmente a uma lição),
com `storage_path` no Supabase Storage e/ou `url`.

### `plano_dia`
Uma linha por dia da janela (15/07–15/11). Guarda os minutos de cada sessão e o conteúdo do dia.
Alimenta as telas **Plano macro** e **Plano diário**.

### `plano_sessao`
Uma linha por sessão (`REVISAO`/`ESTUDO`/`EXERCICIOS`) por dia — granularidade ideal para marcar
sessões cumpridas e calcular aderência.

### `backlog`
Lições não alcançadas na janela, com `ordem_prioridade` e `motivo`. Alimenta a tela **Backlog**.

## Regras de integridade importantes

- **Conclusão de módulo é automática:** trigger `trg_conclusao_modulo` marca `modulo.concluido = true`
  quando não há lição pendente naquele módulo (atende ao requisito RF4).
- **Views de dashboard:** `vw_progresso_modulo` (percentual por módulo) e `vw_progresso_geral`
  (percentual geral e minutos concluídos) prontas para a tela **Controle**.

## Convenção de IDs

- Módulo: `mod_NN` (ex.: `mod_12`).
- Lição: `mod_NN_lMM` (ex.: `mod_12_l01`).

Estáveis e legíveis — usados como chave nos seeds e no plano.

## Carga inicial (seed)

Os CSV/JSON em [`../data/`](../data/) são a carga inicial. Ver
[`../supabase/seed/README.md`](../supabase/seed/README.md) para o passo a passo de import.
