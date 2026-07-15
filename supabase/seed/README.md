# Carga inicial (seed)

Os dados prontos estão em [`../../data/`](../../data/). Ordem de import (respeita as FKs):

1. `seed_modulos.csv` → tabela `modulo`
2. `seed_licoes.csv` → tabela `licao`
3. `plano_estudo.csv` → tabela `plano_dia`
4. `plano_sessoes.csv` → tabela `plano_sessao`
5. `backlog.csv` → tabela `backlog`

## Observações de mapeamento

- Os CSV **não** trazem a coluna `owner`. Opções:
  - inserir logado pelo app (o `default auth.uid()` preenche), ou
  - definir `owner` no import (Table Editor) com o seu `auth.uid()`.
- `seed_modulos.csv` tem uma coluna extra `modulo_nome_raw` (nome com prefixo `NN_`), útil para
  conferência — pode ser ignorada no import da tabela `modulo`.
- `plano_estudo.csv` mapeia para `plano_dia`: `data, dia_semana, total_min, revisao_min, estudo_min,
  exercicios_min, n_conteudos, modulo_dia, conteudo_estudo, licao_principal, revisao_ref, exercicios_ref`.
  Nos fins de semana `n_conteudos = 2` e `modulo_dia` traz os dois módulos separados por " + ".
- `plano_sessoes.csv` mapeia para `plano_sessao`: `data, tipo, minutos, licao_ref, modulo_ref`
  (`concluida` assume `false`). **Nos fins de semana há 2 linhas `ESTUDO` por dia** (uma por módulo,
  30 min cada) — por isso o arquivo tem mais de 3 sessões/dia nesses dias.

## Import via psql (exemplo)

```sql
\copy modulo(modulo_id,ordem,nome,bloco,weight,n_licoes,total_doc_min,total_video_min,total_estudo_min,concluido)
  from 'data/seed_modulos.csv' with (format csv, header true);
-- (repetir para as demais; ajustar colunas conforme o CSV)
```

> Dica: para inserir com `owner`, importe primeiro em uma tabela de staging e faça
> `insert ... select ..., '<seu-uid>'::uuid`.
