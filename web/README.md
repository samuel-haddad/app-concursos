# Concursos — web (Next.js)

Redesign visual do app Flutter `app-estudo-tcdf` (agora com marca **Concursos**),
reimplementado em Next.js 16 (App Router) + TypeScript + Tailwind v4, usando o
**mesmo projeto Supabase** do app original (dados, login Google e allowlist).

## Rodando localmente

```bash
npm install
npm run dev
```

Abra http://localhost:3000. As variáveis do Supabase já estão em `.env.local`
(mesmo projeto do app Flutter — `wlogwtbfxnomuakklrpy`).

## Deploy (GitHub Pages)

O app é publicado como **export estático** (`output: "export"`, sem SSR/API
routes — mesmo padrão dos outros projetos), pelo workflow
`.github/workflows/deploy.yml`: builda `web/` e publica `web/out` em
`https://samuel-haddad.github.io/app-concursos/`, substituindo o antigo
deploy do Flutter. Roda automaticamente a cada push em `main`.

Isso exige duas coisas configuradas via `next.config.ts` / env vars do
workflow (já prontas, não precisa mexer):

- `basePath`/`assetPrefix` = `/app-concursos` (`NEXT_PUBLIC_BASE_PATH`), pois
  o GitHub Pages serve o repo num subcaminho, não na raiz do domínio.
- `images.unoptimized: true`, já que não há servidor para rodar a otimização
  de imagem do Next — sem impacto aqui, o app só usa SVG inline.
- A rota dinâmica `/modulos/[id]` usa `generateStaticParams()` lendo
  `src/lib/data/seed_modulos.json` (mesmo seed da tabela `modulo`), porque
  export estático precisa saber todos os `:id` possíveis no build.

Pra rodar o build de export localmente (útil pra debugar algo do deploy):

```bash
NEXT_PUBLIC_BASE_PATH=/app-concursos NEXT_PUBLIC_SITE_URL=https://samuel-haddad.github.io npm run build
npx serve out
```

## Login com Google

O login usa Supabase Auth (OAuth Google), igual ao app Flutter. O
`redirectTo` já inclui o `basePath` automaticamente (`src/lib/base-path.ts`),
então funciona tanto em `localhost:3000` quanto em
`.../app-concursos/`. Se o domínio de deploy mudar, adicione a nova URL em
**Authentication → URL Configuration → Redirect URLs** no painel do Supabase.

## Estrutura

- `src/app/(app)/*` — as 9 telas autenticadas (Hoje, Plano, Módulos, Módulo
  detalhe, Controle, Materiais, Backlog, Concurso, Aluno), com bottom nav +
  menu lateral (`src/components/BottomNav.tsx`, `Drawer.tsx`).
- `src/app/login`, `src/app/aguardando-aprovacao` — fluxo de auth (fora do
  shell autenticado).
- `src/lib/supabase/` — cliente Supabase + contexto de autenticação
  (`useAuth`), espelhando `authProvider` do Riverpod original.
- `src/lib/data/queries.ts` + `hooks.ts` — camada de dados (SWR), espelhando
  os repositórios Dart (`plano_providers.dart`, `progresso_providers.dart`
  etc). Backlog e materiais continuam vindo de JSON estático
  (`src/lib/data/backlog.json` / `materiais.json`), como no app original.
- `src/app/globals.css` — todos os tokens de design (cores claro/escuro,
  cores por bloco de prova P1–P4, cores por tipo de sessão) extraídos do
  handoff de design.

## Novidades deste redesign (não existiam no app Flutter)

- **Card hero em "Hoje"**: anel de progresso com sessões concluídas/tempo
  estudado no dia. Sessões agora têm checkbox próprio, persistido na tabela
  `sessao_realizada` (já existia no banco, sem uso até então).
- **Dias concluídos no calendário de "Plano"**: dia vira um check quando
  todas as sessões daquele dia foram marcadas.
- **Card "Adesão ao plano" em "Controle"**: % de sessões realizadas até hoje
  vs. planejadas.
- **Tela "Materiais" completa** (antes era um placeholder "Em breve" no app
  Flutter): lista de módulos expansível com os materiais de cada lição.

## Pendências / próximos passos

- PDF é aberto em nova aba (URL assinada da Edge Function
  `assinar-material`) em vez de um leitor embutido como no app Flutter
  (`pdf_viewer_screen.dart`) — pode ser adicionado depois com `react-pdf`.
- Geração de ícones de app (PWA/manifest) a partir de `src/app/icon.svg` —
  hoje só favicon/apple-touch-icon estão gerados.
