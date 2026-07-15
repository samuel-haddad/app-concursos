# ADR 0003 — Modelo de agendamento do plano

- **Status:** Aceito (atualizado em 2026-07-14)
- **Data:** 2026-07-14

## Contexto
Transformar ~1.037 h de conteúdo e ~160 h disponíveis na janela em um plano diário, respeitando a
composição de sessões, a prioridade por peso e a exigência de **não repetir o mesmo módulo em dias
seguidos**.

## Decisão (v2 — atual)
**Smooth Weighted Round-Robin (SWRR) com cooldown de 2 dias:**
1. Cada módulo com conteúdo restante acumula crédito = seu peso, a cada dia.
2. Escolhe-se o módulo elegível (com conteúdo e fora do cooldown de 2 dias) de maior crédito; ao ser
   escolhido, ele paga o crédito (subtrai a soma dos pesos ativos).
3. Os minutos de ESTUDO consomem a fila daquele módulo (lições em ordem). Uma lição longa é
   distribuída em vários dias **não consecutivos**.
4. **Fim de semana:** escolhem-se **2** módulos (os de maior peso elegíveis), com o estudo dividido
   meio a meio (30 min cada); geram-se 2 sessões `ESTUDO`. Dias úteis usam 1 módulo.
5. REVISÃO referencia o(s) módulo(s) do dia anterior; EXERCÍCIOS, o(s) módulo(s) do dia.
6. Lições não alcançadas + todo peso 0 → backlog.

### Por que SWRR
- Faz os módulos **avançarem em paralelo** (evita deixar um bloco eliminatório zerado).
- Dá tempo **proporcional ao peso** sem starvation dos pesos menores.
- O **cooldown** garante o requisito de não repetir assunto em dias seguidos (verificado: 0
  violações, inclusive com 1 dia de intervalo).

## Alternativa anterior (v1) — descartada
Fila estritamente ordenada por peso: estudava um módulo inteiro antes do próximo. Consequências ruins:
repetia o mesmo assunto por muitos dias seguidos e deixava blocos eliminatórios (P1) sem cobertura.

## Pontos em aberto (flags futuras)
- `COOLDOWN` configurável (atual: 2).
- Divisão do fim de semana (hoje 120+120).
- Revisão evoluir para repetição espaçada (SRS).
- Regra de regeneração deve viver em **um só lugar** (recomendado: Supabase Edge Function).
