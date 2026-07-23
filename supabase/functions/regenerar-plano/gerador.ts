// Gerador do plano de estudo — porta pura (sem I/O) de scripts/gerar_plano.py.
// Usado pela Edge Function `regenerar-plano` e testável isoladamente
// (node --experimental-strip-types gerador.ts).
//
// Regras (idênticas ao script):
// - Janela: `inicio`..`fim` (a Edge Function passa inicio = D+1 e fim = prova-7d).
// - Disponibilidade: minutos por dia da semana (0=segunda .. 6=domingo).
// - Percentuais por dia: Seg = 0%rev/70%est/30%exe; Ter-Sex = 20/50/30;
//   fim de semana = 5/50/45.
// - Prioridade: peso (weight). Peso <= 0 -> fora (backlog).
// - Interleaving: cooldown de 2 dias por módulo; tempo por peso via SWRR.
// - Fim de semana: estudo dividido entre os DOIS módulos de maior peso elegíveis.
//
// Diferença proposital vs. script: lições em `concluidas` são REMOVIDAS da fila
// de cada módulo (não reagenda o que já foi feito).

export interface LicaoSeed {
  licao_id: string;
  modulo_id: string;
  modulo: string;
  n_licao: number;
  estudo_min: number;
  weight: number;
}

export interface PlanoDiaGerado {
  data: string;
  dia_semana: string;
  total_min: number;
  revisao_min: number;
  estudo_min: number;
  exercicios_min: number;
  n_conteudos: number;
  modulo_dia: string;
  conteudo_estudo: string;
  licao_principal: string;
  revisao_ref: string;
  exercicios_ref: string;
}

export interface GeradorInput {
  licoes: LicaoSeed[];
  /** minutos por dia: índice 0 = segunda ... 6 = domingo. */
  disponibilidade: number[];
  /** primeira data do plano (ISO YYYY-MM-DD), tipicamente amanhã. */
  inicio: string;
  /** última data do plano (ISO YYYY-MM-DD), tipicamente prova - 7 dias. */
  fim: string;
  /** licao_id já concluídas — removidas da fila. */
  concluidas: Set<string>;
  /** dias de cooldown por módulo (default 2). */
  cooldown?: number;
}

export interface GeradorResultado {
  dias: PlanoDiaGerado[];
  backlog: LicaoSeed[];
}

interface ModState {
  modulo_id: string;
  weight: number;
  nome: string;
  fila: string[];
  idx: number;
  rem: number;
  last_day: number;
  credit: number;
}

const DIA_NOMES = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sab", "Dom"];

function perc(total: number, r: number, x: number) {
  const rev = Math.round(total * r);
  const exe = Math.round(total * x);
  const est = total - rev - exe;
  return { rev, est, exe };
}

function splitMetade(total: number, k: number): number[] {
  if (k === 0) return [];
  const base = Math.floor(total / k);
  const resto = total - base * k;
  return Array.from({ length: k }, (_, i) => base + (i < resto ? 1 : 0));
}

/** Compara duas "chaves-tupla" numéricas lexicograficamente (asc). */
function cmpTuple(a: number[], b: number[]): number {
  for (let i = 0; i < a.length; i++) {
    if (a[i] !== b[i]) return a[i] - b[i];
  }
  return 0;
}

function maxBy<T>(arr: T[], key: (t: T) => number[]): T {
  let best = arr[0];
  let bestKey = key(best);
  for (let i = 1; i < arr.length; i++) {
    const k = key(arr[i]);
    if (cmpTuple(k, bestKey) > 0) {
      best = arr[i];
      bestKey = k;
    }
  }
  return best;
}

/** Itera datas ISO (UTC) de `inicio` até `fim` inclusive. */
function* diasNoIntervalo(inicio: string, fim: string): Generator<Date> {
  const d = new Date(inicio + "T00:00:00Z");
  const end = new Date(fim + "T00:00:00Z");
  while (d.getTime() <= end.getTime()) {
    yield new Date(d.getTime());
    d.setUTCDate(d.getUTCDate() + 1);
  }
}

/** weekday no padrão Python: 0=segunda ... 6=domingo. */
function pyWeekday(d: Date): number {
  return (d.getUTCDay() + 6) % 7;
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

export function gerarPlano(input: GeradorInput): GeradorResultado {
  const COOLDOWN = input.cooldown ?? 2;
  const concluidas = input.concluidas;

  const licMap = new Map<string, LicaoSeed>();
  for (const l of input.licoes) licMap.set(l.licao_id, l);

  // Constrói fila por módulo (peso > 0, lição não concluída), ordenada por n_licao.
  const ordenadas = [...input.licoes].sort(
    (a, b) =>
      a.modulo_id < b.modulo_id ? -1 : a.modulo_id > b.modulo_id ? 1 : a.n_licao - b.n_licao,
  );
  const mods = new Map<string, ModState>();
  for (const l of ordenadas) {
    if (l.weight <= 0) continue;
    if (concluidas.has(l.licao_id)) continue;
    let m = mods.get(l.modulo_id);
    if (!m) {
      m = {
        modulo_id: l.modulo_id,
        weight: l.weight,
        nome: l.modulo,
        fila: [],
        idx: 0,
        rem: 0,
        last_day: -1e9,
        credit: 0,
      };
      mods.set(l.modulo_id, m);
    }
    m.fila.push(l.licao_id);
  }
  for (const m of mods.values()) {
    m.rem = m.fila.length > 0 ? licMap.get(m.fila[0])!.estudo_min : 0;
  }

  const temConteudo = (m: ModState) => m.idx < m.fila.length;

  function consumir(m: ModState, minutos: number): Array<[string, number]> {
    const touched: Array<[string, number]> = [];
    while (minutos > 0 && temConteudo(m)) {
      const lid = m.fila[m.idx];
      const take = Math.min(minutos, m.rem);
      if (take <= 0) {
        touched.push([lid, 0]);
        m.idx += 1;
        m.rem = temConteudo(m) ? licMap.get(m.fila[m.idx])!.estudo_min : 0;
        continue;
      }
      touched.push([lid, take]);
      m.rem -= take;
      minutos -= take;
      if (m.rem <= 0) {
        m.idx += 1;
        m.rem = temConteudo(m) ? licMap.get(m.fila[m.idx])!.estudo_min : 0;
      }
    }
    return touched;
  }

  function escolherN(dayI: number, n: number, priorizaPeso: boolean): ModState[] {
    const ativos = [...mods.values()].filter(temConteudo);
    if (ativos.length === 0) return [];
    for (const m of ativos) m.credit += m.weight;
    const totalW = ativos.reduce((s, m) => s + m.weight, 0);
    const emCooldown = ativos.filter((m) => dayI - m.last_day > COOLDOWN);
    const pool = emCooldown.length > 0 ? emCooldown : ativos;
    const key = priorizaPeso
      ? (m: ModState) => [m.weight, m.credit, -m.last_day]
      : (m: ModState) => [m.credit, m.weight, -m.last_day];
    const picks: ModState[] = [];
    const lim = Math.min(n, pool.length);
    for (let i = 0; i < lim; i++) {
      const cand = pool.filter((m) => !picks.includes(m));
      if (cand.length === 0) break;
      const p = maxBy(cand, key);
      p.credit -= totalW;
      picks.push(p);
    }
    return picks;
  }

  const plano: PlanoDiaGerado[] = [];
  let prevStudied: string[] = []; // módulos estudados no dia anterior (alvo da revisão)
  let dayI = 0;

  for (const d of diasNoIntervalo(input.inicio, input.fim)) {
    const wd = pyWeekday(d);
    const total = input.disponibilidade[wd] ?? 0;
    let rev: number, est: number, exe: number;
    if (wd === 0) ({ rev, est, exe } = perc(total, 0.0, 0.3));
    else if (wd < 5) ({ rev, est, exe } = perc(total, 0.2, 0.3));
    else ({ rev, est, exe } = perc(total, 0.05, 0.45));

    const fimDeSemana = wd >= 5;
    const nMod = fimDeSemana ? 2 : 1;
    const picks = escolherN(dayI, nMod, fimDeSemana);

    const partes = picks.length > 0 ? splitMetade(est, picks.length) : [];
    const estudoPorPick: Array<{ m: ModState; mn: number; touched: Array<[string, number]> }> = [];
    const studiedIds: string[] = [];
    for (let i = 0; i < picks.length; i++) {
      const m = picks[i];
      const mn = partes[i];
      const touched = consumir(m, mn);
      if (touched.length > 0) {
        m.last_day = dayI;
        studiedIds.push(m.modulo_id);
        estudoPorPick.push({ m, mn, touched });
      }
    }

    // ordena por peso desc para nomear o "principal"
    estudoPorPick.sort((a, b) => b.m.weight - a.m.weight);
    const allTouched: Array<[string, number]> = [];
    for (const p of estudoPorPick) for (const t of p.touched) allTouched.push(t);
    const mainLid = allTouched.length > 0 ? maxBy(allTouched, (t) => [t[1]])[0] : "";

    const nomesDia = estudoPorPick.map((p) => p.m.nome);
    const moduloDia = nomesDia.join(" + ");
    const conteudoSet = new Set<string>();
    for (const t of allTouched) {
      const l = licMap.get(t[0])!;
      conteudoSet.add(`${l.modulo} - L${l.n_licao}`);
    }
    const conteudo = conteudoSet.size > 0 ? [...conteudoSet].sort().join("; ") : "(fila esgotada)";
    const revTxt =
      rev === 0
        ? ""
        : prevStudied.length > 0
          ? prevStudied.map((mid) => mods.get(mid)?.nome ?? "").filter(Boolean).join(" + ")
          : "";
    const exeTxt = moduloDia;

    plano.push({
      data: isoDate(d),
      dia_semana: DIA_NOMES[wd],
      total_min: total,
      revisao_min: rev,
      estudo_min: est,
      exercicios_min: exe,
      n_conteudos: estudoPorPick.length,
      modulo_dia: moduloDia,
      conteudo_estudo: conteudo,
      licao_principal: mainLid,
      revisao_ref: revTxt,
      exercicios_ref: exeTxt,
    });

    if (studiedIds.length > 0) prevStudied = studiedIds;
    dayI += 1;
  }

  // Backlog: lições com peso > 0 e não concluídas que não foram alcançadas.
  const reached = new Set<string>();
  for (const m of mods.values()) {
    for (let i = 0; i < m.idx; i++) reached.add(m.fila[i]);
    if (temConteudo(m) && m.rem < licMap.get(m.fila[m.idx])!.estudo_min) {
      reached.add(m.fila[m.idx]);
    }
  }
  const backlog = [...input.licoes]
    .filter((l) => l.weight > 0 && !concluidas.has(l.licao_id) && !reached.has(l.licao_id))
    .sort(
      (a, b) =>
        b.weight - a.weight ||
        (a.modulo_id < b.modulo_id ? -1 : a.modulo_id > b.modulo_id ? 1 : a.n_licao - b.n_licao),
    );

  return { dias: plano, backlog };
}
