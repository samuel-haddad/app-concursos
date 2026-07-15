# Estrutura de Telas

As 7 áreas do app, com o que cada uma consome do banco.

## 1. Plano de estudo (macro)
Calendário mensal/semanal mostrando, por dia, o conteúdo e a carga (min). Fonte: `plano_dia`.
- Indicadores visuais: dia cumprido / pendente, tipo de dia (segunda vs. semana vs. fim de semana).
- Ação: tocar um dia → abre o **Plano diário**.

## 1.1 Plano diário (detalhe)
Padrão: **dia atual**. Mostra as sessões do dia com tempo e conteúdo. Fonte: `plano_sessao` + `licao`.
- REVISÃO (conteúdo anterior) · ESTUDO (lição do dia) · EXERCÍCIOS (módulo do dia).
- Ação: marcar sessão como cumprida; abrir a lição/materiais.

## 2. Módulos
Lista geral dos 18 módulos com bloco, peso, nº de lições e % concluído. Fonte: `vw_progresso_modulo`.
- Ação: abrir módulo → lista de lições.

## 2.1 Lições (detalhe do módulo)
Lições com duração de leitura (`doc_min`) e vídeo (`video_min`). Fonte: `licao`.
- Ação: **marcar lição como concluída** (dispara conclusão automática do módulo).

## 3. Controle (dashboard)
Percentuais de progresso: geral, por bloco (P1/P2/P3), por módulo; minutos estudados vs. totais;
aderência ao plano. Fontes: `vw_progresso_geral`, `vw_progresso_modulo`, `plano_sessao`.

## 4. Concurso
Tela-resumo com os dados do certame e contagem regressiva para 22/11/2026. Fonte: `concurso`.

## 5. Aluno
Edição da disponibilidade (min por dia da semana e fim de semana). Fonte: `disponibilidade`.
- Ação: salvar → oferecer **regenerar plano**.

## 6. Materiais complementares
Por módulo: lista de PDFs, vídeos e áudios (incl. resumos). Fonte: `material` + Supabase Storage.
- **Visualizador de PDF** embutido; **players** de vídeo e áudio.

## 7. Backlog
Lições/módulos fora do plano, ordenados por prioridade. Fonte: `backlog` + `licao`.
- Ação: promover manualmente uma lição ao plano.

## Navegação sugerida

Barra lateral (web) / bottom nav (mobile) com: **Hoje** (plano diário), **Plano**, **Módulos**,
**Controle**, **Materiais**, **Backlog**, e um menu para **Concurso** / **Aluno**.
