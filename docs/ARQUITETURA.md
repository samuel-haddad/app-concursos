# Arquitetura

> Histórico: o app começou em Flutter (ver ADR
> [`decisoes/0001-stack-flutter-supabase.md`](decisoes/0001-stack-flutter-supabase.md)). A versão
> atual é **web-only em Next.js**; o código Flutter foi descontinuado e removido do repo. Este
> documento descreve a arquitetura vigente.

## Visão geral

```
┌─────────────────────────────┐        ┌──────────────────────────────┐
│      Next.js (web/)          │  HTTPS │           Supabase           │
│  React + Tailwind            │ ─────► │  Postgres + RLS              │
│  SWR  →  lib/data (queries)  │        │  Auth (Google OAuth)         │
│         → supabase-js client │        │  Edge Functions              │
└─────────────────────────────┘        │  Storage / Cloudflare R2     │
             │                          └──────────────────────────────┘
             └── cache/revalidação client-side via SWR
```

## Camadas

- **Presentation** — telas (App Router, `web/src/app/(app)/*`) e componentes React
  (`web/src/components`). Estado local por tela via hooks do React.
- **Data hooks** — `web/src/lib/data/hooks.ts`: hooks SWR por recurso (`usePlano`,
  `useDisponibilidade`, `useProgresso`, ...), com cache e revalidação. Espelham os antigos providers
  Riverpod.
- **Data access** — `web/src/lib/data/queries.ts`: funções que falam com o Supabase via
  `supabase-js` (`carregarPlano`, `salvarDisponibilidade`, `regenerarPlano`, ...).
- **Domain** — tipos em `web/src/lib/types.ts` (`Modulo`, `Licao`, `PlanoDia`, `Sessao`,
  `MaterialItem`, `Concurso`).

## Estrutura de pastas (web/)

```
web/
├── package.json
├── next.config.ts
├── src/
│   ├── app/
│   │   ├── layout.tsx, page.tsx, globals.css
│   │   ├── login/            # login (Google OAuth)
│   │   ├── aguardando-aprovacao/
│   │   └── (app)/            # área autenticada (com BottomNav/Drawer)
│   │       ├── hoje/         # plano diário
│   │       ├── plano/        # calendário macro
│   │       ├── modulos/      # lista + detalhe/lições
│   │       ├── controle/     # dashboard de progresso
│   │       ├── concurso/     # dados do certame
│   │       ├── aluno/        # disponibilidade + regenerar plano
│   │       ├── materiais/    # PDF/vídeo/áudio (URL assinada)
│   │       └── backlog/      # lições fora do plano
│   ├── components/           # TopBar, Card, Icons, Drawer, ...
│   └── lib/
│       ├── data/             # hooks.ts, queries.ts, *.json estáticos
│       ├── supabase/         # client.ts, auth-context.tsx
│       ├── theme-*.ts        # tema claro/escuro
│       └── format.ts, types.ts
```

## Pacotes principais

| Necessidade | Pacote |
|---|---|
| Framework | `next` (App Router) + `react` |
| Backend/Auth/DB | `@supabase/supabase-js` + `@supabase/ssr` |
| Cache de dados | `swr` |
| Estilo | Tailwind CSS |
| Fontes | `@fontsource/inter` |

## Integração com o plano gerado

O plano em `data/` é a **carga inicial** do banco (`licao`/`modulo`/`concurso`, via `scripts/`).

A **regeneração** do plano individual (`plano_dia`), quando o aluno muda a disponibilidade, roda no
**servidor**: a Edge Function `supabase/functions/regenerar-plano/` executa o algoritmo (porta de
`scripts/gerar_plano.py` para TypeScript em `gerador.ts`) e regrava o plano. Isso mantém a regra em
um só lugar. Detalhes em [`SUPABASE.md`](SUPABASE.md) e no ADR
[`decisoes/0003-modelo-de-agendamento.md`](decisoes/0003-modelo-de-agendamento.md).

## Segurança

- Uma conta (a sua) no Supabase Auth (Google OAuth); **RLS por `user_id`** nas tabelas por usuário e
  leitura de conteúdo compartilhado restrita a usuários aprovados (`estudo_tcdf_approved_users`).
- Mídia em bucket privado (Cloudflare R2); acesso por **URL assinada** de curta duração via Edge
  Function `assinar-material`.
- No cliente, só a `anon key`; nunca a `service_role`.
