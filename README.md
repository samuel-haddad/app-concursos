# App de Estudo — TCDF (Analista Administrativo de Controle Externo)

Web app pessoal para **controlar o plano de estudo** rumo ao concurso do Tribunal de Contas do
Distrito Federal (TCDF), banca **Cebraspe**, com provas objetivas e discursiva em **22/11/2026**.

O app organiza o conteúdo do curso em módulos e lições, gera um plano de estudo diário respeitando
disponibilidade e prioridade, e acompanha o progresso (concluído/pendente) com um dashboard.

> Uso pessoal (single-user). Não há multiusuário, cadastro público ou compartilhamento.

## Acesso online

- **App (GitHub Pages):** https://samuel-haddad.github.io/app-concursos/ (após o primeiro deploy).
- **Deploy:** automático via GitHub Actions a cada push na `main` — ver
  [`docs/DEPLOY.md`](docs/DEPLOY.md).
- **Backend Supabase** já configurado — ver [`docs/SUPABASE.md`](docs/SUPABASE.md).

> Na versão web, os **materiais** (PDF/áudio/vídeo) aparecem como "apenas no desktop", pois apontam
> para arquivos locais do computador. O restante do app funciona normalmente.

## Stack

| Camada | Tecnologia |
|---|---|
| Frontend | **Next.js** (App Router) + **React** + Tailwind, alvo web (GitHub Pages) |
| Backend / DB | **Supabase** (PostgreSQL + Auth + Storage + Edge Functions) |
| Armazenamento de mídia | Cloudflare R2 (privado, URL assinada via Edge Function) |
| Estado / dados | SWR (cache/revalidação client-side) |

> O app começou em Flutter (ADR `docs/decisoes/0001-stack-flutter-supabase.md`); a versão atual é
> **web-only em Next.js** (pasta `web/`). O código Flutter foi descontinuado e removido do repo.

## As 7 áreas do app

1. **Plano de estudo** — calendário com o conteúdo de cada dia.
   - **Plano diário** — sessões do dia (revisão, estudo, exercícios) e tempo de cada uma.
2. **Módulos** — lista geral dos conteúdos, com detalhamento por **lição** (duração de leitura e vídeo).
3. **Controle** — dashboard de progresso; marcar lições como concluídas (módulo conclui automaticamente).
4. **Concurso** — resumo com dados básicos do certame.
5. **Aluno** — disponibilidade de estudo.
6. **Materiais complementares** — PDFs, vídeos e áudios atrelados a cada módulo.
7. **Backlog** — lições/módulos fora do plano por falta de tempo.

## Panorama dos dados gerados

O plano já foi **gerado** a partir dos seus insumos (índice do curso + edital) e está em [`data/`](data/):

- **173 lições** em **18 módulos** — total de **1.037 h** de conteúdo.
- Janela do plano: **15/07/2026 a 15/11/2026** (124 dias; 1 semana antes da prova).
- Disponibilidade na janela: **160 h** → só **~13,6%** do conteúdo cabe no tempo disponível.
- Prioridade pelo **peso do CSV**; o que não cabe (todo peso 0 + excedente) vai para o **backlog**.
- Os módulos **se alternam** dia a dia (interleaving): nenhum assunto se repete nos 2 dias seguintes,
  e o tempo de cada módulo é proporcional ao seu peso.

> ⚠️ **Leitura recomendada:** [`docs/REGRAS_PLANO_ESTUDO.md`](docs/REGRAS_PLANO_ESTUDO.md) explica os
> pesos, o algoritmo de interleaving (SWRR + cooldown) e a cobertura real.

## Estrutura do repositório

```
app-concursos/
├── README.md                  ← este arquivo
├── CHANGELOG.md
├── .gitignore
├── .env.example
├── docs/                      ← documentação de produto e engenharia
│   ├── PRD.md                 ← requisitos / visão do produto
│   ├── ESTRUTURA_TELAS.md     ← as 7 telas em detalhe
│   ├── REGRAS_PLANO_ESTUDO.md ← regras de tempo/prioridade + metodologia de pesos
│   ├── MODELO_DE_DADOS.md     ← entidades, relacionamentos, DER
│   ├── ARQUITETURA.md         ← camadas, pastas, integração Supabase
│   ├── ROADMAP.md             ← fases de entrega (MVP → completo)
│   ├── SETUP.md               ← como rodar localmente
│   └── decisoes/              ← ADRs (registros de decisão)
├── supabase/
│   ├── migrations/0001_schema_inicial.sql
│   ├── functions/             ← Edge Functions (assinar-material, regenerar-plano)
│   └── seed/README.md         ← como carregar os CSVs
├── data/                      ← seeds e plano JÁ gerados (fonte da verdade inicial)
├── web/                       ← app Next.js (frontend web)
└── scripts/                   ← Python que gerou seeds e plano (reprodutível)
```

## Como começar

Leia, nesta ordem: [`docs/PRD.md`](docs/PRD.md) → [`docs/REGRAS_PLANO_ESTUDO.md`](docs/REGRAS_PLANO_ESTUDO.md)
→ [`docs/MODELO_DE_DADOS.md`](docs/MODELO_DE_DADOS.md) → [`docs/SETUP.md`](docs/SETUP.md).
