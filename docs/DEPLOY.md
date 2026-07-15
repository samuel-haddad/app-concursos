# Deploy — GitHub + GitHub Pages

O app será hospedado como **Flutter Web** no GitHub Pages, em
`https://samuel-haddad.github.io/app-concursos/`, com deploy automático via GitHub Actions.

> **Importante (web):** os **materiais** (PDFs/áudio/vídeo) apontam para arquivos no seu computador,
> que o navegador não acessa — na versão web eles aparecem como "disponível apenas no desktop". Todo o
> resto (plano, módulos, controle, concurso, aluno, backlog, login, progresso) funciona na web.

## 1. Mover a pasta para D:\Desktop\samuel-haddad
No PowerShell:
```powershell
mkdir D:\Desktop\samuel-haddad -Force
robocopy "D:\Concursos\app-estudo-tcdf" "D:\Desktop\samuel-haddad\app-concursos" /E
```
Confira o resultado em `D:\Desktop\samuel-haddad\app-concursos`. (Depois, se quiser, apague a pasta
antiga `D:\Concursos\app-estudo-tcdf`.)

## 2. Subir para o GitHub
```powershell
cd D:\Desktop\samuel-haddad\app-concursos
git init -b main
git add .
git commit -m "Primeiro commit: app de estudo TCDF"
git remote add origin git@github.com:samuel-haddad/app-concursos.git
git push -u origin main
```
(Se usar HTTPS em vez de SSH: `git remote add origin https://github.com/samuel-haddad/app-concursos.git`.)

## 3. Ativar o GitHub Pages
No GitHub: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
O workflow `.github/workflows/deploy.yml` builda o web e publica a cada push na `main`.
Acompanhe em **Actions**. Ao terminar, o app fica em `https://samuel-haddad.github.io/app-concursos/`.

## 4. Conectar o Supabase (login Google na web)
No painel do Supabase → **Authentication → URL Configuration**:
- **Site URL:** `https://samuel-haddad.github.io/app-concursos/`
- **Redirect URLs:** adicione `https://samuel-haddad.github.io/app-concursos/`
  (mantenha também o deep link do desktop, se for usar: `br.samuel.estudotcdf://login-callback`).

No **Google Cloud** (credenciais OAuth) a URL de redirecionamento continua sendo a do Supabase
(`https://wlogwtbfxnomuakklrpy.supabase.co/auth/v1/callback`) — nada muda ali.

O app já está configurado (`lib/core/supabase_config.dart`): `usarSupabaseAuth = true` e o redirect na
web usa automaticamente a URL do Pages. Ao abrir o app publicado e clicar em "Entrar com Google", o
login abre, retorna para o Pages e o progresso passa a sincronizar na sua conta.

## Rodar localmente na web (para testar antes de publicar)
```powershell
cd D:\Desktop\samuel-haddad\app-concursos\app
flutter run -d chrome --web-port 5000
```
Para o login funcionar local, adicione `http://localhost:5000` às Redirect URLs do Supabase.

## Observações
- A **chave anônima** do Supabase fica no código (é pública por design; o que protege os dados é o RLS).
- Se algum plugin nativo (media_kit) atrapalhar o build web, me avise com o log — dá para isolá-lo do
  alvo web sem afetar o desktop.
