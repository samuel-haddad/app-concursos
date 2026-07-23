# Deploy — GitHub + GitHub Pages

O app é hospedado como **site estático Next.js** (export) no GitHub Pages, em
`https://samuel-haddad.github.io/app-concursos/`, com deploy automático via GitHub Actions.

> **Importante (web):** os **materiais** (PDFs/áudio/vídeo) hospedados no Cloudflare R2 são servidos
> por URL assinada; o resto (plano, módulos, controle, concurso, aluno, backlog, login, progresso)
> funciona normalmente na web.

## 1. Subir para o GitHub
O repositório fica em `D:\Desktop\samuel-haddad\app-concursos`.
```powershell
cd D:\Desktop\samuel-haddad\app-concursos
git add .
git commit -m "..."
git push
```
(Se ainda não tiver remote: `git remote add origin https://github.com/samuel-haddad/app-concursos.git`
e `git push -u origin main`.)

## 2. Ativar o GitHub Pages
No GitHub: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
O workflow `.github/workflows/deploy.yml` builda o `web/` (Next.js, `npm ci` + `npm run build`) e
publica a cada push na `main`. Acompanhe em **Actions**. Ao terminar, o app fica em
`https://samuel-haddad.github.io/app-concursos/`.

As variáveis públicas (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`,
`NEXT_PUBLIC_BASE_PATH`, `NEXT_PUBLIC_SITE_URL`) estão embutidas no workflow — a `anon key` é pública
por design; o que protege os dados é o RLS.

## 3. Conectar o Supabase (login Google na web)
No painel do Supabase → **Authentication → URL Configuration**:
- **Site URL:** `https://samuel-haddad.github.io/app-concursos/`
- **Redirect URLs:** adicione `https://samuel-haddad.github.io/app-concursos/`

No **Google Cloud** (credenciais OAuth) a URL de redirecionamento continua sendo a do Supabase
(`https://wlogwtbfxnomuakklrpy.supabase.co/auth/v1/callback`) — nada muda ali.

Ao abrir o app publicado e clicar em "Entrar com Google", o login abre, retorna para o Pages e o
progresso sincroniza na sua conta.

## Rodar localmente (para testar antes de publicar)
```powershell
cd D:\Desktop\samuel-haddad\app-concursos\web
npm install
npm run dev   # http://localhost:3000
```
Para o login funcionar local, adicione `http://localhost:3000` às Redirect URLs do Supabase e defina
as variáveis `NEXT_PUBLIC_*` num `.env.local` (ver `.env.example`).

## Observações
- A **chave anônima** do Supabase é pública por design; o RLS protege os dados.
- Edge Functions (`assinar-material`, `regenerar-plano`) são publicadas à parte via Supabase CLI/MCP,
  não pelo workflow do Pages.
