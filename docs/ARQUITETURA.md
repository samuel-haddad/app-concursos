# Arquitetura

## Visão geral

```
┌─────────────────────────────┐        ┌──────────────────────────┐
│         Flutter (Web)        │  HTTPS │        Supabase          │
│  UI  →  Riverpod  →  Repos   │ ─────► │  Postgres + RLS          │
│                    (supabase │        │  Auth                    │
│                     _flutter)│        │  Storage (PDF/vídeo/áudio)│
└─────────────────────────────┘        └──────────────────────────┘
             │
             └── cache local (Isar/Hive) p/ plano e progresso (offline-first leve)
```

## Camadas (Clean-ish)

- **Presentation** — telas e widgets Flutter; estado via **Riverpod**.
- **Application** — providers/notifiers com casos de uso (marcar concluído, regenerar plano, etc.).
- **Domain** — modelos (`Modulo`, `Licao`, `PlanoDia`, `Sessao`, `Material`, `Concurso`).
- **Data** — repositórios que falam com Supabase (`supabase_flutter`) + cache local.

## Estrutura de pastas Flutter sugerida

```
app/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── core/            # tema, rotas, config, env, extensões
│   ├── domain/
│   │   └── models/      # modulo.dart, licao.dart, plano_dia.dart, sessao.dart, ...
│   ├── data/
│   │   ├── supabase/    # client, mapeadores
│   │   └── repositories/# modulo_repo.dart, plano_repo.dart, progresso_repo.dart
│   ├── application/     # providers Riverpod (por feature)
│   └── features/
│       ├── plano/       # macro + diário
│       ├── modulos/     # lista + detalhe/lições
│       ├── controle/    # dashboard
│       ├── concurso/
│       ├── aluno/
│       ├── materiais/   # viewer PDF + players
│       └── backlog/
└── test/
```

## Pacotes recomendados (pubspec)

| Necessidade | Pacote |
|---|---|
| Backend/Auth/DB | `supabase_flutter` |
| Estado | `flutter_riverpod` |
| Rotas | `go_router` |
| PDF | `syncfusion_flutter_pdfviewer` (ou `pdfx`) |
| Vídeo | `video_player` (+ `chewie` para controles) |
| Áudio | `just_audio` |
| Cache local | `isar` ou `hive` |
| Datas | `intl` (locale pt_BR) |

## Integração com o plano gerado

O plano em `data/` é a **carga inicial** do banco. A regeneração (quando o aluno muda disponibilidade
ou pesos) pode acontecer de duas formas:

1. **Cliente:** portar a lógica de `scripts/gerar_plano.py` para Dart e regravar `plano_dia`/`plano_sessao`.
2. **Servidor:** uma **Supabase Edge Function** que roda o algoritmo e persiste o novo plano.

A opção 2 mantém a regra em um só lugar e é a recomendada — ver ADR
[`decisoes/0003-modelo-de-agendamento.md`](decisoes/0003-modelo-de-agendamento.md).

## Segurança

- Uma conta (a sua) no Supabase Auth; **RLS por `owner`** em todas as tabelas.
- Mídia em bucket privado; acesso por **URL assinada** de curta duração.
- Chaves só a `anon key` no cliente; nunca a `service_role` no app.
