# Supabase — configuração e login com Google

O projeto Supabase **estudo-tcdf** já está criado e carregado. Este documento explica o estado atual
e como ativar o login real com o Google.

## Estado atual

- **Projeto:** `estudo-tcdf` (ref `wlogwtbfxnomuakklrpy`), região us-east-1.
- **URL/anon key:** já configuradas em `app/lib/core/supabase_config.dart`.
- **Schema aplicado** (migrations): conteúdo compartilhado + dados por usuário com RLS.
- **Dados carregados:** 18 módulos, 173 lições, 124 dias de plano, 1 concurso.
- **Leitura do conteúdo:** liberada para a chave anônima (o app lê o plano sem depender do login).
- **Progresso e disponibilidade:** por usuário (`licao_concluida`, `disponibilidade`), protegidos por RLS.

### Tabelas
`modulo`, `licao`, `plano_dia`, `plano_sessao` (vazia — as sessões são reconstruídas no app),
`backlog` (vazia — lida dos assets), `material` (vazia — lida dos assets), `concurso`,
`licao_concluida` (progresso do usuário), `disponibilidade` (do usuário).

## Como o app usa

Um único interruptor controla auth/progresso: `SupabaseConfig.usarSupabaseAuth` em
`app/lib/core/supabase_config.dart`.

- **false (padrão):** login local (stub) + progresso local. O app **já roda** e lê o conteúdo do
  Supabase. Use isto até concluir o setup do Google abaixo.
- **true:** login com Google (Supabase Auth) e progresso/disponibilidade sincronizados na nuvem.

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
3. **Authentication → URL Configuration → Redirect URLs**: adicione o deep link do app:
   `br.samuel.estudotcdf://login-callback`

### 3. App (deep link) — necessário no desktop/mobile
O retorno do navegador para o app usa o esquema `br.samuel.estudotcdf`. É preciso registrá-lo na
plataforma:
- **Windows:** registrar o esquema de URL no registro do Windows (ou usar o pacote `app_links` /
  `url_protocol`) apontando para o executável. É a parte mais trabalhosa no desktop.
- **Android:** adicionar um `intent-filter` com o esquema no `AndroidManifest.xml`.
- **Web:** usar como redirect a URL do próprio app (ex.: `http://localhost:PORTA`).

> Alternativa mais simples para testar rápido no desktop: rodar como **Web**
> (`flutter run -d chrome`) e usar o redirect `http://localhost:<porta>` nas Redirect URLs do Supabase.

### 4. Ligar no app
Em `app/lib/core/supabase_config.dart`, mude `usarSupabaseAuth` para `true` e rode de novo.
A tela de login passará a abrir o Google no navegador; ao voltar, o app fica logado e o progresso
sincroniza.

## Regenerar o plano no futuro
Hoje o conteúdo no banco foi carregado uma vez. Se você regerar o plano (scripts em `scripts/`),
será preciso recarregar as tabelas `plano_dia`/`licao`/`modulo`. Um passo natural da próxima fase é
uma **Edge Function** que regenera e regrava o plano quando a disponibilidade muda.
