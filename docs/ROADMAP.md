# Roadmap

Entrega incremental. Cada fase gera algo utilizável.

## Fase 0 — Fundação (feito)
- [x] Processar índice do curso e edital.
- [x] Derivar pesos e gerar seeds (`data/seed_*`).
- [x] Gerar plano de estudo e backlog (`data/plano_*`, `data/backlog`).
- [x] Documentação (PRD, regras, modelo de dados, arquitetura, ADRs).
- [x] Schema Supabase (`supabase/migrations/0001`).

## Fase 1 — MVP de leitura (somente consulta)
- [x] App web (Next.js App Router) + tema claro/escuro pt-BR + **menu lateral (drawer)** e bottom nav.
- [x] **Login** com "Entrar com Google" (Supabase Auth) e guarda de rota.
- [x] Tela **Hoje** (plano diário) lendo os assets do plano.
- [x] Tela **Plano** (calendário macro, cores por bloco, toque → Hoje).
- [x] Tela **Módulos/Lições** com marcação de concluído (conclusão de módulo derivada).
- [x] Tela **Concurso** com contagem regressiva.
- [x] Criar projeto Supabase, aplicar migration, carregar seeds; app lê o conteúdo do banco.
- [x] Ativar login com Google (Supabase Auth) — ver docs/SUPABASE.md.

## Fase 2 — Progresso e controle
- [x] Marcar lição concluída (persistência no Supabase) + módulo concluído automático.
- [x] Tela **Controle** (dashboard: geral, por bloco, por módulo, minutos concluídos).
- [x] Marcar sessão cumprida (`sessao_realizada`).
- [x] Aderência ao plano (dias cumpridos) no dashboard.

## Fase 3 — Materiais
- [x] Visualizador de **PDF** em tela cheia (no navegador).
- [x] Players de **vídeo** (MP4) e **áudio** (M4A) no navegador.
- [x] Manifesto `materiais.json` mapeando lição → arquivos reais do curso.
- [x] Mídia hospedada no **Cloudflare R2** (privado) com URL assinada via Edge Function; funciona web.
  Falta: você criar o bucket/token, setar os secrets e rodar o upload (ver docs/MATERIAIS_STORAGE.md).

## Fase 4 — Dinâmica do plano
- [x] Tela **Aluno** editável (disponibilidade por dia, persistida localmente).
- [x] Tela **Backlog** (lista por prioridade). Falta: promoção manual ao plano.
- [x] **Regeneração** do plano (Edge Function `regenerar-plano`) ao salvar a disponibilidade na
  tela Aluno (web): botão + confirmação, regenera de D+1 até prova-7d, pula lições concluídas e
  preserva o histórico. Falta: regenerar também ao mudar pesos.

## Fase 5 — Refino
- [ ] Modos alternativos de priorização (interleaving por bloco).
- [ ] Cache offline (ex.: IndexedDB / service worker).
- [ ] Ajustes de UX e responsividade.

## Ideias futuras (fora do escopo v1)
- Repetição espaçada (SRS) para a revisão.
- Registro de desempenho em exercícios (acertos por assunto) realimentando os pesos.
