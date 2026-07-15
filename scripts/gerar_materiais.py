"""Varre a pasta do curso e gera materiais.json: por licao_id, os caminhos
(Windows) do PDF da aula, do PDF resumo do modulo, do audio (.m4a) e do video (.mp4).
Ajuste CURSO_DIR/WIN_BASE/OUT para o seu ambiente.
"""
import os, re, json

CURSO_DIR = "/sessions/vigilant-peaceful-heisenberg/mnt/Concursos/Curso_Curso Completo para Analista Administrativo de Controle Externo do TCDF"
WIN_BASE  = r"D:\Concursos\Curso_Curso Completo para Analista Administrativo de Controle Externo do TCDF"
OUT       = "/sessions/vigilant-peaceful-heisenberg/mnt/Concursos/app-estudo-tcdf/data"

licoes = json.load(open(f"{OUT}/seed_licoes.json"))

def winpath(*parts):
    return "\\".join([WIN_BASE] + list(parts))

# indexa pastas por prefixo de modulo (01..18)
pastas = {}
for nome in os.listdir(CURSO_DIR):
    if os.path.isdir(os.path.join(CURSO_DIR, nome)):
        m = re.match(r"(\d+)_", nome)
        if m:
            pastas[m.group(1)] = nome

manifesto = {}
for lic in licoes:
    mid = lic["modulo_id"]            # mod_NN
    pref = mid.split("_")[1]          # NN
    pasta = pastas.get(pref)
    if not pasta:
        continue
    ndir = os.path.join(CURSO_DIR, pasta)
    arquivos = os.listdir(ndir)
    n = lic["n_licao"]
    modnum = str(int(pref))           # sem zero à esquerda (resumo_modulo_1_)

    pdf_aula = None
    for a in arquivos:
        if a.lower().endswith(".pdf") and re.match(rf"0*{n}_", a):
            pdf_aula = a; break

    pdf_resumo = audio = video = None
    for a in arquivos:
        low = a.lower()
        if low.startswith(f"resumo_modulo_{modnum}_"):
            if low.endswith(".pdf"): pdf_resumo = a
            elif low.endswith(".m4a"): audio = a
            elif low.endswith(".mp4"): video = a

    itens = []
    if pdf_aula:   itens.append({"tipo": "PDF",   "titulo": "PDF da aula",     "path": winpath(pasta, pdf_aula)})
    if pdf_resumo: itens.append({"tipo": "PDF",   "titulo": "PDF resumo",      "path": winpath(pasta, pdf_resumo)})
    if audio:      itens.append({"tipo": "AUDIO", "titulo": "Áudio resumo",    "path": winpath(pasta, audio)})
    if video:      itens.append({"tipo": "VIDEO", "titulo": "Vídeo resumo",    "path": winpath(pasta, video)})
    if itens:
        manifesto[lic["licao_id"]] = itens

json.dump(manifesto, open(f"{OUT}/materiais.json", "w"), ensure_ascii=False, indent=2)
tot = sum(len(v) for v in manifesto.values())
print(f"Lições com material: {len(manifesto)} | itens totais: {tot}")
# amostra
import itertools
for lid, its in itertools.islice(manifesto.items(), 2):
    print(lid, "->")
    for it in its:
        print("   ", it["tipo"], "|", it["path"])
