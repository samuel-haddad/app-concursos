"""Gera seeds de módulos e lições a partir de indice_curso.csv.
O peso (weight) é lido DIRETO do CSV (preenchendo nulos com o peso do módulo).
O bloco de prova (P1/P2/P3/P4/FORA) é mapeado do edital apenas para referência/dashboard.
Ajuste SRC/OUT para o seu ambiente.
"""
import pandas as pd, re, json

SRC = '/sessions/vigilant-peaceful-heisenberg/mnt/Concursos/indice_curso.csv'
OUT = '/sessions/vigilant-peaceful-heisenberg/mnt/Concursos/app-estudo-tcdf/data'

def dur2min(s):
    if not isinstance(s, str) or not s.strip(): return 0
    h = re.search(r'(\d+)\s*h', s); m = re.search(r'(\d+)\s*min', s)
    return (int(h.group(1))*60 if h else 0) + (int(m.group(1)) if m else 0)

df = pd.read_csv(SRC)
df['doc_min']   = df['duracao_doc'].apply(dur2min)
df['video_min'] = df['duracao_video'].apply(dur2min)
df['estudo_min'] = df['doc_min'] + df['video_min']

df['weight'] = df.groupby('modulo')['weight'].transform(
    lambda s: s.fillna(s.dropna().mode().iloc[0] if not s.dropna().empty else 0))
df['weight'] = df['weight'].fillna(0).astype(int)

def pref(m): return m.split('_')[0]
BLOCO = {'01':'P1','02':'P1','03':'P1','04':'P1','05':'P1',
         '06':'P2','07':'P2','08':'P2','09':'P2','10':'P2','11':'P2',
         '12':'P3','13':'P3','14':'P3','15':'P3','16':'P3',
         '17':'P4','18':'FORA'}
df['bloco'] = df['modulo'].apply(lambda m: BLOCO[pref(m)])

mod_order = list(dict.fromkeys(df['modulo'].tolist()))
mod_meta = {}
for m in mod_order:
    sub = df[df['modulo'] == m]
    mod_meta[m] = dict(
        modulo_id=f"mod_{pref(m)}", ordem=int(pref(m)),
        nome=m.split('_', 1)[1], bloco=sub['bloco'].iloc[0],
        weight=int(sub['weight'].max()), n_licoes=int(len(sub)),
        total_doc_min=int(sub['doc_min'].sum()),
        total_video_min=int(sub['video_min'].sum()),
        total_estudo_min=int(sub['estudo_min'].sum()))

mods = []
for m in mod_order:
    d = mod_meta[m].copy(); d['modulo_nome_raw'] = m; mods.append(d)
pd.DataFrame(mods).to_csv(f'{OUT}/seed_modulos.csv', index=False)
json.dump(mods, open(f'{OUT}/seed_modulos.json', 'w'), ensure_ascii=False, indent=2)

licoes = []
for _, r in df.iterrows():
    m = r['modulo']
    licoes.append(dict(
        licao_id=f"{mod_meta[m]['modulo_id']}_l{int(r['n_licao']):02d}",
        modulo_id=mod_meta[m]['modulo_id'], modulo=m.split('_', 1)[1],
        n_licao=int(r['n_licao']), titulo=r['lesson'],
        doc_min=int(r['doc_min']), video_min=int(r['video_min']),
        estudo_min=int(r['estudo_min']), bloco=r['bloco'], weight=int(r['weight'])))
pd.DataFrame(licoes).to_csv(f'{OUT}/seed_licoes.csv', index=False)
json.dump(licoes, open(f'{OUT}/seed_licoes.json', 'w'), ensure_ascii=False, indent=2)

print(pd.DataFrame(mods)[['modulo_id','ordem','bloco','weight','n_licoes','total_estudo_min']].to_string(index=False))
tot = sum(l['estudo_min'] for l in licoes)
print(f"\nLicoes: {len(licoes)} | Conteudo total: {tot/60:.1f} h")
print("Weight>0:", sum(1 for l in licoes if l['weight']>0),
      "| Weight=0 (backlog):", sum(1 for l in licoes if l['weight']==0))
