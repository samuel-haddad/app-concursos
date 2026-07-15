# App Flutter — Estudo TCDF

App pessoal (Flutter Web) de controle do plano de estudo. Esta pasta já contém o **código-fonte**
(`lib/`), o `pubspec.yaml`, o tema, as rotas e a **tela "Hoje"** funcional lendo o plano dos assets.

## O que já está implementado (Fase 1 — início)
- Tema Material 3 (claro/escuro) e locale **pt_BR**.
- **Login** com "Entrar com Google" (stub local até o Supabase) e redirecionamento automático.
- **Menu lateral (drawer)** com todas as telas + usuário e "Sair".
- Navegação inferior (go_router) com 5 destinos: **Hoje, Plano, Módulos, Controle, Materiais**.
- **Backlog:** lições fora do plano por prioridade, com resumo (mantém a barra inferior).
- **Tema claro/escuro** alternável pelo menu lateral (persistido).
- **Materiais na tela Hoje:** 2 PDFs (tela cheia, `syncfusion_flutter_pdfviewer`), áudio M4A e vídeo
  MP4 embutido (`media_kit`), lendo os arquivos reais do curso via `assets/data/materiais.json`.
- **Tela Hoje:** mostra o dia selecionado (padrão: data atual, limitada à janela do plano),
  navega dia a dia, exibe o tempo total, o conteúdo do dia e as **sessões** (Revisão/Estudo/
  Exercícios) com o módulo e a lição de cada uma. Fins de semana exibem os 2 estudos.
- **Tela Plano:** calendário mensal do plano, com navegação de mês, **cores por bloco de prova**
  (P1/P2/P3/P4) e legenda; tocar num dia abre o detalhe dele na tela Hoje.
- **Telas Módulos e Lições:** lista de módulos com progresso/bloco/peso e detalhe com **checkbox por
  lição**. Marcar todas as lições conclui o módulo automaticamente. Progresso **persistido localmente**
  (SharedPreferences) — isolado em `lib/data/` para troca por Supabase depois.
- **Tela Controle (dashboard):** % geral concluído, progresso por bloco de prova e por módulo, e
  tempo de estudo concluído — tudo reativo ao progresso marcado nas lições.
- **Tela Concurso:** resumo do certame e contagem regressiva (menu ⋮ na tela Hoje).
- **Tela Aluno:** disponibilidade editável por dia da semana, persistida localmente (menu ⋮).
- Fonte de dados: **assets JSON** em `assets/data/` (gerados em `../data/`). A troca para Supabase
  é isolada em `lib/data/` — ver `ARQUITETURA.md`.

A tela Materiais é placeholder ("Em breve") da próxima fase.

## Estrutura
```
lib/
├── main.dart                     # ProviderScope + MaterialApp.router
├── core/                         # theme, router, format (datas/min)
├── domain/models/                # PlanoDia, Sessao, Licao
├── data/
│   ├── repositories/             # PlanoRepository (contrato)
│   └── local/                    # PlanoLocalRepository (lê assets)
├── application/                  # providers Riverpod
└── features/
    ├── hoje/hoje_screen.dart     # tela Hoje
    └── placeholders.dart         # telas futuras
assets/data/                      # plano_estudo.json, plano_sessoes.json, seed_*.json
```

## Como rodar
Pré-requisito: Flutter SDK (stable) com Web habilitado.

```bash
cd app
# 1) gerar os arquivos de plataforma (não sobrescreve o lib/ existente):
flutter create --platforms=web,windows,android --org br.samuel.estudotcdf .
# 2) dependências e execução:
flutter pub get
flutter run -d chrome
```

Se atualizar o plano em `../data/`, recopie os JSON para `assets/data/` (ver `../scripts/`).

## Próximos passos
Ligar o Supabase (`supabase_flutter`) implementando um `PlanoSupabaseRepository` e trocando o
`planoRepositoryProvider`. Depois, telas de progresso (marcar concluído) e materiais. Ver
`../docs/ROADMAP.md`.
