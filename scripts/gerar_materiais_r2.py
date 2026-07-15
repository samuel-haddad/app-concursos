"""Gera:
- data/materiais.json (asset): licao_id -> [{tipo,titulo,key}] com chaves R2 limpas (ASCII).
- data/upload_map.csv: (local_path, key) deduplicado, para o upload no R2.
Convenção de chave: mod_XX/aula_NN.pdf | mod_XX/resumo.pdf | resumo.m4a | resumo.mp4
Ajuste CURSO_DIR/WIN_BASE se necessário.
"""
import os, re, json, csv

CURSO_DIR = "/sessions/vigilant-peaceful-heisenberg/mnt/Concursos/Curso_Curso Completo para Analista Administrativo de Controle Externo do TCDF"
WIN_BASE  = r"D:\Concursos\Curso_Curso Completo para Analista Administrativo de Controle Externo do TCDF"
OUT       = "/sessions/vigilant-peaceful-heisenberg/mnt/Concursos/app-estudo-tcdf/data"

licoes = json.load(open(f"{OUT}/seed_licoes.json"))

pastas = {}
for nome in os.listdir(CURSO_DIR):
    if os.path.isdir(os.path.join(CURSO_DIR, nome)):
        m = re.match(r"(\d+)_", nome)
        if m: pastas[m.group(1)] = nome

def winpath(pasta, arq): return f"{WIN_BASE}\\{pasta}\\{arq}"

manifesto = {}
upload = {}   # key -> local_path (dedup)

for lic in licoes:
    pref = lic["modulo_id"].split("_")[1]          # NN
    pasta = pastas.get(pref)
    if not pasta: continue
    arqs = os.listdir(os.path.join(CURSO_DIR, pasta))
    n = lic["n_licao"]; modnum = str(int(pref))

    pdf_aula = next((a for a in arqs if a.lower().endswith(".pdf") and re.match(rf"0*{n}_", a)), None)
    pdf_res = next((a for a in arqs if a.lower().startswith(f"resumo_modulo_{modnum}_") and a.lower().endswith(".pdf")), None)
    audio   = next((a for a in arqs if a.lower().startswith(f"resumo_modulo_{modnum}_") and a.lower().endswith(".m4a")), None)
    video   = next((a for a in arqs if a.lower().startswith(f"resumo_modulo_{modnum}_") and a.lower().endswith(".mp4")), None)

    itens = []
    def add(tipo, titulo, arq, key):
        if not arq: return
        upload[key] = winpath(pasta, arq)
        itens.append({"tipo": tipo, "titulo": titulo, "key": key})

    add("PDF",   "PDF da aula",  pdf_aula, f"mod_{pref}/aula_{n:02d}.pdf")
    add("PDF",   "PDF resumo",   pdf_res,  f"mod_{pref}/resumo.pdf")
    add("AUDIO", "Áudio resumo", audio,    f"mod_{pref}/resumo.m4a")
    add("VIDEO", "Vídeo resumo", video,    f"mod_{pref}/resumo.mp4")
    if itens:
        manifesto[lic["licao_id"]] = itens

json.dump(manifesto, open(f"{OUT}/materiais.json", "w"), ensure_ascii=False, indent=2)
with open(f"{OUT}/upload_map.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerow(["local_path", "key"])
    for key, lp in sorted(upload.items()): w.writerow([lp, key])

print("Lições com material:", len(manifesto))
print("Arquivos únicos p/ upload:", len(upload))
from collections import Counter
print("Por tipo (keys):", Counter(k.split('.')[-1] for k in upload))
