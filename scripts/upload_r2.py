"""Faz upload dos materiais para o Cloudflare R2 (bucket privado).
Lê data/upload_map.csv (local_path,key) e envia cada arquivo.

Funciona no Windows e no WSL/Linux (converte caminhos D:\\... -> /mnt/d/...).

Pré-requisitos:
  pip install boto3
  Variáveis de ambiente (do token R2):
    R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET

Uso:
  python scripts/upload_r2.py            # envia o que faltar (pula os já enviados)
  python scripts/upload_r2.py --force    # reenvia tudo
"""
import os, re, csv, sys, mimetypes

try:
    import boto3
    from botocore.config import Config
except ImportError:
    sys.exit("Instale boto3:  pip install boto3")

ACCOUNT = os.environ["R2_ACCOUNT_ID"]
BUCKET  = os.environ["R2_BUCKET"]
FORCE   = "--force" in sys.argv
MAP     = os.path.join(os.path.dirname(__file__), "..", "data", "upload_map.csv")


def to_local(p):
    """Converte caminho Windows (D:\\...) para o formato do SO atual.
    No WSL/Linux vira /mnt/<letra>/... ; no Windows fica como está."""
    p = p.strip()
    if os.name != "nt":
        m = re.match(r"^([A-Za-z]):[\\/](.*)$", p)
        if m:
            drive = m.group(1).lower()
            rest = m.group(2).replace("\\", "/")
            return f"/mnt/{drive}/{rest}"
    return p


s3 = boto3.client(
    "s3",
    endpoint_url=f"https://{ACCOUNT}.r2.cloudflarestorage.com",
    aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
    aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
    config=Config(signature_version="s3v4"),
    region_name="auto",
)


def existe(key):
    try:
        s3.head_object(Bucket=BUCKET, Key=key)
        return True
    except Exception:
        return False


CT = {".pdf": "application/pdf", ".m4a": "audio/mp4", ".mp4": "video/mp4"}

rows = list(csv.DictReader(open(MAP, encoding="utf-8")))
enviados = pulados = falhas = 0
for i, r in enumerate(rows, 1):
    lp, key = to_local(r["local_path"]), r["key"]
    if not os.path.exists(lp):
        print(f"[{i}/{len(rows)}] FALTA arquivo: {lp}")
        falhas += 1
        continue
    if not FORCE and existe(key):
        pulados += 1
        continue
    ext = os.path.splitext(lp)[1].lower()
    ct = CT.get(ext) or mimetypes.guess_type(lp)[0] or "application/octet-stream"
    print(f"[{i}/{len(rows)}] enviando {key} ...")
    s3.upload_file(lp, BUCKET, key, ExtraArgs={"ContentType": ct})
    enviados += 1

print(f"\nOK: enviados={enviados} pulados={pulados} falhas={falhas}")
