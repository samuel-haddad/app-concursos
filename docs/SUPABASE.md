# Supabase — configuração e login com Google

O projeto Supabase **estudo-tcdf** já está criado e carregado. Este documento explica o estado atual
e como ativar o login real com o Google.

## Estado atual

- **Projeto:** `estudo-tcdf` (ref `wlogwtbfxnomuakklrpy`), região us-east-1.
- **URL/anon key:** configuradas via variáveis `NEXT_PUBLIC_SUPABASE_URL` /
  `NEXT_PUBLIC_SUPABASE_ANON_KEY` (embutidas no workflow de deploy; localmente em `web/.env.local`).
  Lidas em `web/src/lib/supabase/client.ts`.
- **Schema aplicado** (migrations): conteúdo compartilhado + dados por usuário com RLS.
- **Dados carregados:** 18 módulos, 173 lições, 124 dias de plano, 1 concurso.
- **Leitura do conteúdo:** liberada para a chave anônima (o app lê o plano sem depender do login).
- **Progresso e disponibilidade:** por usuário (`licao_concluida`, `disponibilidade`), protegidos por RLS.

### Tabelas
`modulo`, `licao`, `plano_dia`, `plano_sessao` (vazia — as sessões são reconstruídas no app),
`backlog` (vazia — lida dos assets), `material` (vazia — lida dos assets), `concurso`,
`licao_concluida` (progresso do usuário), `disponibilidade` (do usuário).

## Como o app usa

O web usa **Supabase Auth (Google OAuth)** direto (`web/src/lib/supabase/auth-context.tsx` +
`client.ts`). Ao logar, o progresso e a disponibilidade são lidos/gravados na nuvem com RLS por
`user_id`; o conteúdo compartilhado (módulos/lições/plano) é lido pela chave anônima.

## Ativar o login com Google

### 1. Google Cloud (criar credenciais OAuth)
1. Acesse https://console.cloud.google.com/ → crie/《escolha》um projeto.
2. **APIs e Serviços → Tela de consentimento OAuth**: tipo "Externo", preencha o básico, adicione seu
   e-mail como usuário de teste.
3. **Credenciais → Criar credenciais → ID do cliente OAuth → Aplicativo da Web**.
4. Em **URIs de redirecionamento autorizados**, adicione:
   `https://wlogwtbfxnomuakklrpy.supabase.co/auth/v1/callback`
5. Copie o **Client ID** e o **Client Secret**.

### 2. Supabase (habilitar o provedor)
1. No painel do projeto: **Authentication → Providers → Google**.
2. Cole o Client ID e o Client Secret; salve e habilite.
3. **Authentication → URL Configuration → Redirect URLs**: adicione a URL do app web:
   - produção: `https://samuel-haddad.github.io/app-concursos/`
   - local: `http://localhost:3000`

### 3. Rodar e testar
```powershell
cd web
npm install
npm run dev   # http://localhost:3000
```
Ao abrir e clicar em "Entrar com Google", o login abre, retorna para o app e o progresso passa a
sincronizar na sua conta. Em produção, o deploy no GitHub Pages usa a URL do Pages como redirect.

## Regenerar o plano
O conteúdo base (`licao`/`modulo`/`concurso`) foi carregado uma vez pelos scripts em `scripts/`.

O **plano individual** (`plano_dia`) é regenerado sob demanda pela Edge Function `regenerar-plano`
(`supabase/functions/regenerar-plano/`), disparada pela tela **Aluno** do web ao tocar em *Salvar e
regenerar plano* (com confirmação). Ela:

- lê `disponibilidade`, `licao`, `licao_concluida` e `concurso.data_prova` do usuário (via JWT, RLS
  aplica);
- roda o mesmo algoritmo de `scripts/gerar_plano.py` (porta em TypeScript em `gerador.ts`: SWRR por
  peso, cooldown de 2 dias, split de fim de semana);
- gera o plano de **D+1 até prova − 7 dias**, **pulando lições já concluídas**;
- apaga e reinsere só os `plano_dia` de D+1 em diante — **dias passados ficam intactos** e
  `licao_concluida`/`sessao_realizada` **não são tocadas** (histórico preservado).

A lógica é testável isoladamente: `node --experimental-strip-types gerador.ts` (função pura, sem
I/O). Regerar os pesos/conteúdo ainda exige rodar os scripts e recarregar `licao`/`modulo`.
