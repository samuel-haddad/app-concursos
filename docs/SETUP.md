# Setup

## Pré-requisitos
- Node.js 20+ (app web em Next.js) e npm.
- Conta Supabase + [Supabase CLI](https://supabase.com/docs/guides/cli).
- Python 3 (para regenerar seeds/plano) com `pandas` e `pdfplumber`.

## 1. Banco (Supabase)

```bash
# criar projeto no dashboard do Supabase, depois:
supabase link --project-ref <SEU_PROJECT_REF>
supabase db push        # aplica supabase/migrations/0001_schema_inicial.sql
```

## 2. Carregar os seeds
Ver [`../supabase/seed/README.md`](../supabase/seed/README.md). Resumo: importar os CSV de
`data/` na ordem `modulo → licao → plano_dia → plano_sessao → backlog` (pelo Table Editor ou `\copy`).

> Ao inserir, defina `owner` = seu `auth.uid()` (ou insira logado via app). Os CSV não trazem `owner`.

## 3. Variáveis de ambiente
Copie `.env.example` para `.env` e preencha:

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

## 4. App web (Next.js)

```bash
cd web
npm install
npm run dev        # http://localhost:3000
```

Deploy automático para GitHub Pages via GitHub Actions — ver [`DEPLOY.md`](DEPLOY.md).

## 5. Regenerar plano (opcional)

```bash
cd scripts
pip install pandas pdfplumber
python3 gerar_seed.py     # requer indice_curso.csv e TCDF-edital.pdf na pasta Concursos
python3 gerar_plano.py
```
Edite disponibilidade, janela ou pesos nos scripts antes de rodar. Ajuste os caminhos `SRC`/`OUT`
no topo dos scripts para o seu ambiente.
