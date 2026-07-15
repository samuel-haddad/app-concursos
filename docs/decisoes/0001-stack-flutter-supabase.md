# ADR 0001 — Stack: Flutter + Supabase

- **Status:** Aceito
- **Data:** 2026-07-14

## Contexto
App pessoal de controle de estudo, com necessidade de exibir PDFs e reproduzir vídeo/áudio, e
sincronizar progresso entre dispositivos. O desenvolvedor tem experiência com Flutter e Supabase.

## Decisão
Usar **Flutter** (alvo principal Web, com desktop/mobile de graça) e **Supabase** (Postgres + Auth +
Storage) como backend.

## Alternativas consideradas
- **Next.js/React + Supabase:** ótimo ecossistema web (PDF.js, players), mas fora da experiência atual.
- **Flutter Web puro (sem backend):** simples, porém sem sincronização entre dispositivos.

## Consequências
- Aproveita a experiência existente → menor tempo de entrega.
- Um só código-base para web e, se quiser, mobile/desktop.
- PDFs e mídia via pacotes maduros (`syncfusion_flutter_pdfviewer`, `video_player`, `just_audio`).
- Precisa cuidar de peculiaridades do Flutter Web (renderer, tamanho de bundle).
