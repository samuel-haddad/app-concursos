"""Gera o plano de estudo diário a partir de seed_licoes.json.

Regras:
- Janela: D+1 até 1 semana antes da prova.
- Disponibilidade: seg-sex 60min; sáb/dom 120min cada (4h/fim de semana).
- Sessoes por dia: Seg = 70% estudo / 30% exercicios;
                   Ter-Sex = 20% revisao / 50% estudo / 30% exercicios;
                   Fim de semana = 5% revisao / 50% estudo / 45% exercicios.
- Prioridade: peso (weight) do CSV. Peso 0 -> backlog.
- INTERLEAVING: modulos se alternam ao longo dos dias. Um modulo estudado no dia D
  nao volta nos 2 dias seguintes (cooldown = 2). Tempo por modulo proporcional ao peso,
  via Smooth Weighted Round-Robin (SWRR).
- FIM DE SEMANA: o estudo do dia e dividido entre os DOIS modulos de MAIOR PESO possivel
  (elegiveis pelo cooldown), com metade do tempo de estudo para cada.
"""
import json, pandas as pd
from datetime import date, timedelta

OUT = '/sessions/vigilant-peaceful-heisenberg/mnt/Concursos/app-estudo-tcdf/data'
licoes = json.load(open(f'{OUT}/seed_licoes.json'))

INICIO = date(2026, 7, 15)
FIM    = date(2026, 11, 15)
PROVA  = date(2026, 11, 22)
WD_MIN, SAT_MIN, SUN_MIN = 60, 120, 120
COOLDOWN = 2

def perc(total, r, e, x):
    rev = round(total*r); exe = round(total*x); est = total-rev-exe
    return rev, est, exe

lic_map = {l['licao_id']: l for l in licoes}

mods = {}
for l in sorted(licoes, key=lambda l: (l['modulo_id'], l['n_licao'])):
    if l['weight'] <= 0: continue
    mods.setdefault(l['modulo_id'], dict(
        modulo_id=l['modulo_id'], weight=l['weight'], nome=l['modulo'],
        fila=[], idx=0, rem=0, last_day=-10**9, credit=0))
    mods[l['modulo_id']]['fila'].append(l['licao_id'])
for mid, m in mods.items():
    m['rem'] = lic_map[m['fila'][0]]['estudo_min']

def tem_conteudo(m): return m['idx'] < len(m['fila'])

def consumir(m, minutos):
    touched = []
    while minutos > 0 and tem_conteudo(m):
        lid = m['fila'][m['idx']]
        take = min(minutos, m['rem'])
        if take <= 0:
            touched.append((lid, 0)); m['idx'] += 1
            m['rem'] = lic_map[m['fila'][m['idx']]]['estudo_min'] if tem_conteudo(m) else 0
            continue
        touched.append((lid, take)); m['rem'] -= take; minutos -= take
        if m['rem'] <= 0:
            m['idx'] += 1
            m['rem'] = lic_map[m['fila'][m['idx']]]['estudo_min'] if tem_conteudo(m) else 0
    return touched

def escolher_n(day_i, n, prioriza_peso=False):
    """Seleciona ate n modulos distintos para o dia.
    prioriza_peso=True (fim de semana): ordena por MAIOR PESO (depois credito).
    prioriza_peso=False (dias uteis): SWRR puro por credito (depois peso).
    Credito e incrementado UMA vez por dia para todos os modulos ativos."""
    ativos = [m for m in mods.values() if tem_conteudo(m)]
    if not ativos: return []
    for m in ativos: m['credit'] += m['weight']
    total_w = sum(m['weight'] for m in ativos)
    pool = [m for m in ativos if day_i - m['last_day'] > COOLDOWN] or ativos
    if prioriza_peso:
        key = lambda m: (m['weight'], m['credit'], -m['last_day'])
    else:
        key = lambda m: (m['credit'], m['weight'], -m['last_day'])
    picks = []
    for _ in range(min(n, len(pool))):
        cand = [m for m in pool if m not in picks]
        if not cand: break
        p = max(cand, key=key)
        p['credit'] -= total_w
        picks.append(p)
    return picks

def split_metade(total, k):
    """Divide `total` em k partes o mais iguais possivel (resto nas primeiras)."""
    if k == 0: return []
    base = total // k; resto = total - base*k
    return [base + (1 if i < resto else 0) for i in range(k)]

plano, sessoes = [], []
prev_studied = []   # ids de modulos estudados no dia anterior (alvo da revisao)
d = INICIO; day_i = 0
while d <= FIM:
    wd = d.weekday()
    total = WD_MIN if wd < 5 else (SAT_MIN if wd == 5 else SUN_MIN)
    if wd == 0:   rev, est, exe = perc(total, 0.0, 0.70, 0.30)
    elif wd < 5:  rev, est, exe = perc(total, 0.20, 0.50, 0.30)
    else:         rev, est, exe = perc(total, 0.05, 0.50, 0.45)

    fim_de_semana = wd >= 5
    n_mod = 2 if fim_de_semana else 1
    picks = escolher_n(day_i, n_mod, prioriza_peso=fim_de_semana)

    # divide o tempo de estudo entre os modulos escolhidos
    partes = split_metade(est, len(picks)) if picks else []
    estudo_por_pick = []   # (modulo, minutos, touched)
    studied_ids = []
    for m, mn in zip(picks, partes):
        touched = consumir(m, mn)
        if touched:
            m['last_day'] = day_i
            studied_ids.append(m['modulo_id'])
            estudo_por_pick.append((m, mn, touched))

    # ordena por peso desc para nomear o "principal"
    estudo_por_pick.sort(key=lambda t: -t[0]['weight'])
    all_touched = [t for _, _, tt in estudo_por_pick for t in tt]
    main_lid = max(all_touched, key=lambda t: t[1])[0] if all_touched else None

    nomes_dia = [p[0]['nome'] for p in estudo_por_pick]
    modulo_dia = " + ".join(nomes_dia)
    conteudo = "; ".join(sorted({lic_map[t[0]]['modulo'] + " - L" + str(lic_map[t[0]]['n_licao'])
                                 for t in all_touched})) or "(fila esgotada)"
    rev_txt = ("" if rev == 0 else
               (" + ".join(mods[mid]['nome'] for mid in prev_studied) if prev_studied else ""))
    exe_txt = modulo_dia

    plano.append(dict(
        data=d.isoformat(), dia_semana=['Seg','Ter','Qua','Qui','Sex','Sab','Dom'][wd],
        total_min=total, revisao_min=rev, estudo_min=est, exercicios_min=exe,
        n_conteudos=len(estudo_por_pick), modulo_dia=modulo_dia,
        conteudo_estudo=conteudo, licao_principal=main_lid or "",
        revisao_ref=rev_txt, exercicios_ref=exe_txt))

    # sessoes: REVISAO (1, exceto segundas), ESTUDO (1 por modulo), EXERCICIOS (1)
    if rev > 0:
        sessoes.append(dict(data=d.isoformat(), tipo="REVISAO", minutos=rev,
                            licao_ref="", modulo_ref=rev_txt))
    if estudo_por_pick:
        for m, mn, tt in estudo_por_pick:
            lid = max(tt, key=lambda t: t[1])[0]
            sessoes.append(dict(data=d.isoformat(), tipo="ESTUDO", minutos=mn,
                                licao_ref=lid, modulo_ref=m['nome']))
    else:
        sessoes.append(dict(data=d.isoformat(), tipo="ESTUDO", minutos=est,
                            licao_ref="", modulo_ref=""))
    sessoes.append(dict(data=d.isoformat(), tipo="EXERCICIOS", minutos=exe,
                        licao_ref=main_lid or "", modulo_ref=exe_txt))

    if studied_ids: prev_studied = studied_ids
    d += timedelta(days=1); day_i += 1

pd.DataFrame(plano).to_csv(f'{OUT}/plano_estudo.csv', index=False)
json.dump(plano, open(f'{OUT}/plano_estudo.json', 'w'), ensure_ascii=False, indent=2)
pd.DataFrame(sessoes).to_csv(f'{OUT}/plano_sessoes.csv', index=False)

reached = set()
for mid, m in mods.items():
    reached |= set(m['fila'][:m['idx']])
    if tem_conteudo(m) and m['rem'] < lic_map[m['fila'][m['idx']]]['estudo_min']:
        reached.add(m['fila'][m['idx']])
backlog = [l for l in sorted(licoes, key=lambda l: (-l['weight'], l['modulo_id'], l['n_licao']))
           if l['licao_id'] not in reached]
pd.DataFrame(backlog).to_csv(f'{OUT}/backlog.csv', index=False)
json.dump(backlog, open(f'{OUT}/backlog.json', 'w'), ensure_ascii=False, indent=2)

# ---- relatorio ----
print(f"Janela {INICIO}..{FIM} ({len(plano)} dias) | Prova {PROVA}")
conteudo_total = sum(l['estudo_min'] for l in licoes)
back_min = sum(l['estudo_min'] for l in backlog)
print(f"Conteudo total {conteudo_total/60:.1f}h | coberto ~{(conteudo_total-back_min)/60:.1f}h "
      f"({(conteudo_total-back_min)/conteudo_total*100:.1f}%)")
# verificacao de cooldown por MODULO (conjuntos por dia)
sets = []
for p in plano:
    ids = [mods[k]['modulo_id'] for k in mods if mods[k]['nome'] in p['modulo_dia'].split(" + ")] if p['modulo_dia'] else []
    sets.append(set(p['modulo_dia'].split(" + ")) if p['modulo_dia'] else set())
v1 = sum(1 for i in range(len(sets)-1) if sets[i] & sets[i+1])
v2 = sum(1 for i in range(len(sets)-2) if sets[i] & sets[i+2])
print("Repeticoes consecutivas (por modulo):", v1, "| a 2 dias:", v2)
# checar fim de semana com 2 conteudos e split
fds = [p for p in plano if p['dia_semana'] in ('Sab','Dom')]
com2 = sum(1 for p in fds if p['n_conteudos']==2)
print(f"Fins de semana: {len(fds)} dias | com 2 conteudos: {com2} | com 1: {sum(1 for p in fds if p['n_conteudos']==1)}")
print("\nExemplo de um fim de semana (sessoes ESTUDO):")
ex = pd.read_csv(f'{OUT}/plano_sessoes.csv')
ex = ex[(ex['tipo']=='ESTUDO') & (ex['data'].isin(['2026-07-18','2026-07-19']))]
print(ex.to_string(index=False))
print("\nPrimeiros dias (macro):")
print(pd.DataFrame(plano).head(9)[['data','dia_semana','estudo_min','n_conteudos','modulo_dia']].to_string(index=False))
