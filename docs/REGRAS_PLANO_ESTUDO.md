# Regras do Plano de Estudo

Fonte da verdade sobre como o plano em [`../data/`](../data/) foi gerado. Algoritmo em
[`../scripts/gerar_plano.py`](../scripts/gerar_plano.py), reprodutível.

## 1. Janela de tempo
- **Início:** 15/07/2026 (D+1). **Fim:** 15/11/2026 (1 semana antes da prova). **Total:** 124 dias.

## 2. Disponibilidade (aluno)

| Período | Tempo |
|---|---|
| Segunda a sexta | 60 min/dia |
| Fim de semana | 240 min → **120 sábado + 120 domingo** |

## 3. Composição das sessões por dia

| Dia | Revisão | Estudo | Exercícios |
|---|---|---|---|
| **Segunda** | 0% | 70% | 30% |
| **Terça a sexta** | 20% | 50% | 30% |
| **Fim de semana** | 5% | 50% | 45% |

- **Estudo** = conteúdo novo (avança a fila do módulo escolhido no dia).
- **Revisão** = retoma o **módulo estudado no dia anterior** (que, pelo interleaving, é diferente do de hoje).
- **Exercícios** = prática sobre o módulo estudado no dia.

**Segundas-feiras não têm revisão:** geram apenas sessões de **Estudo** e **Exercícios** (nenhuma
sessão `REVISAO` é criada, `revisao_ref` fica vazio).

**Fim de semana — dois conteúdos:** sábado e domingo estudam os **dois módulos de maior peso
possível** (entre os elegíveis pelo cooldown), com o tempo de estudo **dividido meio a meio** (30 min
para cada). Nesses dias há duas sessões `ESTUDO` e `n_conteudos = 2`. Os dias úteis mantêm 1 módulo.

## 4. Prioridade por peso (agora vinda do CSV)

Os pesos são lidos **direto de `indice_curso.csv`** (coluna `weight`). Um peso nulo é preenchido com o
peso predominante do próprio módulo. Pesos atuais por módulo:

| Peso | Módulos |
|---|---|
| **5** | 01 Língua Portuguesa · 07 Direito Constitucional · 12 Direito Administrativo |
| **4** | 13 AFO · 14 Adm. Geral e Pública · 15 Regime Jurídico dos Servidores · 16 Gestão de Contratos |
| **3** | 11 Análise de Dados/Estatística/IA · 17 Técnicas de Discursiva |
| **2** | 05 Raciocínio Lógico · 08 Previdenciário · 09 Direito Civil · 10 Direito Tributário |
| **0** | 02 LODF · 03 Conhec. DF · 04 Primeiros Socorros · 06 LO TCDF · 18 Fora do edital |

Peso **0** = deixado de lado por falta de disponibilidade → vai inteiro para o **backlog**
(31 lições). O bloco de prova (P1/P2/P3/P4) é mantido só como referência para o dashboard.

## 5. Interleaving (alternância de módulos) — NOVO

Requisito: o mesmo assunto não deve se repetir nos **dois dias seguintes**. O gerador usa
**Smooth Weighted Round-Robin (SWRR) com cooldown de 2 dias**:

1. Cada módulo com conteúdo restante acumula crédito igual ao seu **peso** a cada dia.
2. Nos **dias úteis**, escolhe-se 1 módulo **elegível** (com conteúdo e que **não foi estudado nos
   últimos 2 dias**) de maior crédito. Nos **fins de semana**, escolhem-se os **2** módulos elegíveis
   de **maior peso** (crédito como desempate). Ao ser escolhido, o módulo "paga" o crédito.
3. Resultado: os módulos se **alternam** e o **tempo total de cada um fica proporcional ao peso**
   (peso 5 ≈ 15 dias; peso 4 ≈ 9–10; peso 3 ≈ 9; peso 2 ≈ 6). Uma lição longa é estudada em vários
   dias **não consecutivos**.

Verificado no plano gerado: **0 repetições** de módulo em dias consecutivos e **0** com um dia de
intervalo (gap sempre ≥ 3 dias). A revisão do dia aponta para o módulo do dia anterior — sempre
diferente do estudado hoje.

## 6. Realidade de cobertura

- Conteúdo total: **1.037 h**. Disponível na janela: **160 h**.
- Coberto para estudo: **~141 h (13,6%)**. O restante fica no **backlog**, por design — não há tempo
  para tudo, então o peso decide o que entra.
- Com o interleaving, **todos os blocos avançam em paralelo** (não há mais o risco de um bloco
  eliminatório ficar zerado, como ocorria na priorização estrita anterior).

## 7. Saídas geradas

| Arquivo | Conteúdo |
|---|---|
| `data/plano_estudo.(csv/json)` | 1 linha/dia: tempos por sessão, `modulo_dia`, conteúdo, lição, refs |
| `data/plano_sessoes.csv` | 1 linha por sessão (REVISAO/ESTUDO/EXERCICIOS) |
| `data/backlog.(csv/json)` | lições fora do plano (todo peso 0 + não alcançadas), por prioridade |
| `data/seed_modulos.(csv/json)`, `data/seed_licoes.(csv/json)` | módulos e lições com peso e durações |

## 8. Parâmetros ajustáveis (`gerar_plano.py`)
- `INICIO`, `FIM` — janela. `WD_MIN`, `SAT_MIN`, `SUN_MIN` — disponibilidade.
- `COOLDOWN` — dias mínimos entre repetições do mesmo módulo (atual: 2).
- Percentuais por dia (função `perc`).
- Para reordenar prioridades, **edite o `weight` no CSV** e rode `gerar_seed.py` + `gerar_plano.py`.
