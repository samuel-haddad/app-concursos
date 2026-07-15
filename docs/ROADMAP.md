# Roadmap

Entrega incremental. Cada fase gera algo utilizável.

## Fase 0 — Fundação (feito)
- [x] Processar índice do curso e edital.
- [x] Derivar pesos e gerar seeds (`data/seed_*`).
- [x] Gerar plano de estudo e backlog (`data/plano_*`, `data/backlog`).
- [x] Documentação (PRD, regras, modelo de dados, arquitetura, ADRs).
- [x] Schema Supabase (`supabase/migrations/0001`).

## Fase 1 — MVP de leitura (somente consulta)
- [x] App Flutter: navegação (go_router) + tema Material 3 pt_BR + **menu lateral (drawer)**.
- [x] **Login** com "Entrar com Google" (stub local; OAuth real virá com o Supabase) e guarda de rota.
- [x] Tela **Hoje** (plano diário) lendo os assets do plano.
- [x] Tela **Plano** (calendário macro, cores por bloco, toque → Hoje).
- [x] Tela **Módulos/Lições** com marcação de concluído (conclusão de módulo derivada).
- [x] Tela **Concurso** com contagem regressiva.
- [x] Criar projeto Supabase, aplicar migration, carregar seeds; app lê o conteúdo do banco.
- [ ] Ativar login com Google (Supabase Auth) — depende de config no Google Cloud (ver docs/SUPABASE.md).

## Fase 2 — Progresso e controle
- [x] Marcar lição concluída (persistência local via SharedPreferences) + módulo concluído automático.
- [x] Tela **Controle** (dashboard: geral, por bloco, por módulo, minutos concluídos).
- [ ] Marcar sessão cumprida.
- [ ] Aderência ao plano (dias cumpridos) no dashboard.

## Fase 3 — Materiais
- [x] Visualizador de **PDF** em tela cheia (`syncfusion_flutter_pdfviewer`, Dart puro).
- [x] Players de **vídeo** (MP4 embutido) e **áudio** (M4A) via `media_kit`.
- [x] Manifesto `materiais.json` mapeando lição → arquivos reais do curso.
- [ ] Bucket de Storage (Supabase) para servir a mídia (hoje lê arquivos locais por caminho).

## Fase 4 — Dinâmica do plano
- [x] Tela **Aluno** editável (disponibilidade por dia, persistida localmente).
- [x] Tela **Backlog** (lista por prioridade). Falta: promoção manual ao plano.
- [ ] **Regeneração** do plano (Edge Function) ao mudar disponibilidade/pesos.

## Fase 5 — Refino
- [ ] Modos alternativos de priorização (interleaving por bloco).
- [ ] Cache offline (Isar/Hive).
- [ ] Ajustes de UX e responsividade.

## Ideias futuras (fora do escopo v1)
- Repetição espaçada (SRS) para a revisão.
- Registro de desempenho em exercícios (acertos por assunto) realimentando os pesos.
