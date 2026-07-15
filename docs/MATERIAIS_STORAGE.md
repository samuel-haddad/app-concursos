# Materiais — armazenamento no Cloudflare R2 (privado)

Os materiais (PDFs, áudios M4A, vídeos MP4 — ~2,8 GB) ficam num bucket **privado** do Cloudflare R2.
O app pede uma **URL assinada temporária** a uma Edge Function do Supabase (que exige login), e então
abre o material. Nada fica público — protege o conteúdo do curso pago.

```
App (logado) → Edge Function "assinar-material" (valida usuário) → URL assinada do R2 (1h)
   → PDF: abre em tela cheia no app | Áudio/Vídeo: abre no player nativo/navegador
```

O mapeamento lição → arquivos está em `app/assets/data/materiais.json` (chaves como `mod_01/resumo.pdf`),
gerado por `scripts/gerar_materiais_r2.py`. A lista de upload está em `data/upload_map.csv`.

## Passo 1 — Cloudflare R2 (bucket já criado: `materiais-tcdf`)

### 1a. Pegar o Account ID
- No dashboard, abra **R2** (menu à esquerda) → **Overview**.
- No canto direito há **"Account details" → Account ID**. Copie (ex.: `a1b2c3...`, 32 caracteres).
- Alternativa: abra o bucket → aba **Settings** → em **S3 API** o endpoint é
  `https://<ACCOUNT_ID>.r2.cloudflarestorage.com/materiais-tcdf` — o `<ACCOUNT_ID>` é o que você precisa.

### 1b. Criar o API Token (Access Key + Secret)
- Em **R2 → Overview**, botão **"Manage R2 API Tokens"** (canto superior direito) →
  **"Create API token"** (ou **Create Account API token**).
- **Token name:** `estudo-tcdf-app` (ou o que quiser).
- **Permissions:** selecione **Object Read & Write**.
- **Specify bucket(s):** escolha **Apply to specific buckets only → `materiais-tcdf`**
  (mais seguro que "all buckets").
- **TTL:** pode deixar sem expiração (Forever) para uso pessoal.
- Clique **Create API Token**. A tela final mostra, na seção **"Use the S3 API"**:
  - **Access Key ID**
  - **Secret Access Key** ← aparece **só uma vez**; copie agora.
  - (também repete o endpoint `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`)

Guarde os três valores: **Account ID**, **Access Key ID**, **Secret Access Key**.

## Passo 2 — Secrets da Edge Function (no Supabase)
A função `assinar-material` já está publicada. Falta dar a ela as credenciais do R2. Pelo **CLI**:
```bash
supabase secrets set \
  R2_ACCOUNT_ID=<account_id> \
  R2_ACCESS_KEY_ID=<access_key_id> \
  R2_SECRET_ACCESS_KEY=<secret_access_key> \
  R2_BUCKET=materiais-tcdf \
  --project-ref wlogwtbfxnomuakklrpy
```
(Ou no painel: **Edge Functions → Manage secrets**.) `SUPABASE_URL`/`SUPABASE_ANON_KEY` já existem.

## Passo 3 — CORS no bucket R2 (necessário p/ a web)
Para o PDF abrir no navegador (a versão web faz fetch do arquivo), o R2 precisa permitir a origem do
app. Passos:
- Abra **R2 → materiais-tcdf → aba Settings**.
- Role até **CORS Policy** → **Add CORS policy** (ou **Edit**).
- Cole o JSON abaixo e **Save**:
```json
[
  {
    "AllowedOrigins": ["https://samuel-haddad.github.io", "http://localhost:5000"],
    "AllowedMethods": ["GET"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["Content-Length", "Content-Range", "Accept-Ranges"],
    "MaxAgeSeconds": 3600
  }
]
```

## Passo 4 — Enviar os arquivos (na sua máquina)
Os arquivos ficam na pasta do curso em `D:\Concursos\Curso_...`. São **193 arquivos (~2,8 GB)**; o
script **pula os já enviados**, então pode rodar de novo se cair.

O `upload_r2.py` já converte automaticamente os caminhos Windows para WSL. Escolha seu terminal:

### WSL / Linux (bash)
```bash
cd /mnt/d/Desktop/samuel-haddad/app-concursos
pip install boto3
export R2_ACCOUNT_ID=<account_id>
export R2_ACCESS_KEY_ID=<access_key_id>
export R2_SECRET_ACCESS_KEY=<secret>
export R2_BUCKET=materiais-tcdf
python scripts/upload_r2.py
```
> Se estiver com uma versão antiga do script (sem conversão de caminho), ajuste o CSV uma vez:
> `sed -i 's#\\#/#g; s#^D:#/mnt/d#' data/upload_map.csv`

### Windows (PowerShell)
```powershell
cd D:\Desktop\samuel-haddad\app-concursos
pip install boto3
$env:R2_ACCOUNT_ID="<account_id>"
$env:R2_ACCESS_KEY_ID="<access_key_id>"
$env:R2_SECRET_ACCESS_KEY="<secret>"
$env:R2_BUCKET="materiais-tcdf"
python scripts\upload_r2.py
```

> **Segurança:** não comite as chaves nem as cole em lugares públicos. Se o *Secret* vazar, revogue o
> token no Cloudflare (R2 → Manage R2 API Tokens) e crie outro.

## Passo 5 — Testar
1. Abra o app (web publicado ou local), faça login com Google.
2. Vá em **Hoje** → seção **Materiais** → toque num item.
   - PDF abre em tela cheia; áudio/vídeo abrem no player nativo/aba do navegador.
3. Se der erro: veja os logs da função em **Supabase → Edge Functions → assinar-material → Logs**
   (causas comuns: secret do R2 faltando, CORS no R2, ou usuário não logado).

## Notas
- A URL assinada expira em **1 hora** (ajustável em `EXPIRA` na função).
- Só usuários logados conseguem gerar URLs — o acervo permanece privado.
- Regerar o manifesto/mapa: `python scripts/gerar_materiais_r2.py` (recopie `materiais.json` para
  `app/assets/data/`).
