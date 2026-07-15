# Scripts (geração de seeds e plano)

Python que transforma os insumos brutos em seeds e no plano de estudo. Reprodutível e versionado.

| Script | Entrada | Saída |
|---|---|---|
| `gerar_seed.py` | `indice_curso.csv`, `TCDF-edital.pdf` | `seed_modulos.*`, `seed_licoes.*` |
| `gerar_plano.py` | `seed_licoes.json` | `plano_estudo.*`, `plano_sessoes.csv`, `backlog.*` |
| `gerar_materiais.py` | pasta do curso + `seed_licoes.json` | `materiais.json` (caminhos locais — versão desktop antiga) |
| `gerar_materiais_r2.py` | pasta do curso + `seed_licoes.json` | `materiais.json` (chaves R2) + `upload_map.csv` |
| `upload_r2.py` | `upload_map.csv` + credenciais R2 (env) | envia os arquivos ao Cloudflare R2 |

Fluxo dos materiais: `gerar_materiais_r2.py` → `upload_r2.py`. Detalhes em
[`../docs/MATERIAIS_STORAGE.md`](../docs/MATERIAIS_STORAGE.md).

## Uso

```bash
pip install pandas pdfplumber
python3 gerar_seed.py
python3 gerar_plano.py
```

> **Caminhos:** os scripts foram gerados apontando para o ambiente de processamento
> (`SRC`/`OUT` no topo de cada arquivo). Ajuste esses caminhos para a sua máquina antes de rodar
> (ex.: `SRC = r'D:\Concursos\indice_curso.csv'` e `OUT = r'D:\Concursos\app-estudo-tcdf\data'`).

## Parâmetros ajustáveis (em `gerar_plano.py`)
- `INICIO`, `FIM` — janela do plano.
- `WD_MIN`, `SAT_MIN`, `SUN_MIN` — disponibilidade.
- Percentuais por dia (função `perc`) — composição das sessões.
- Ordenação da `fila` — regra de prioridade (weight desc, módulo, lição).

## Pesos
A derivação dos pesos (dicionário `BLOCO` em `gerar_seed.py`) está documentada no ADR
[`../docs/decisoes/0002-derivacao-de-pesos.md`](../docs/decisoes/0002-derivacao-de-pesos.md).
