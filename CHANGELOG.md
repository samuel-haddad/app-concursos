# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/).

## [1.1.0] — 2026-07-15
### Adicionado
- **Deploy web no GitHub Pages** via GitHub Actions (`.github/workflows/deploy.yml`, base-href
  `/app-concursos/`). `docs/DEPLOY.md` com o passo a passo (mover pasta, git, Pages, Supabase).
- `LICENSE` (MIT) e link do app online no README.
- **OAuth do Google ligado** (`usarSupabaseAuth = true`); na web o redirect usa a URL do Pages.
### Alterado
- **Compatibilidade web:** os players de PDF/áudio/vídeo (que usam `dart:io` e arquivos locais)
  foram isolados por import condicional; na web a seção de materiais mostra "apenas no desktop".
  `MediaKit.ensureInitialized()` só roda fora da web.

## [1.0.0] — 2026-07-15
### Adicionado
- **Backend Supabase** (projeto `estudo-tcdf`): schema com RLS, conteúdo carregado (18 módulos,
  173 lições, 124 dias, concurso) e tabelas de progresso/disponibilidade por usuário.
- App passa a **ler o conteúdo do Supabase** (leitura anônima); sessões reconstruídas de `plano_dia`.
- Repositórios Supabase para **auth (Google OAuth)**, **progresso** e **disponibilidade**, atrás do
  interruptor `SupabaseConfig.usarSupabaseAuth` (login/progresso local enquanto o Google não é ligado).
- `docs/SUPABASE.md` com o passo a passo para ativar o login com Google.

## [0.9.1] — 2026-07-14
### Corrigido
- **Falha de build no Windows (CMake/pdfium):** o `pdfx` compila o pdfium via CMake e quebrou em
  versões novas do CMake (remoção de compat. < 3.5). Trocado pelo **`syncfusion_flutter_pdfviewer`**
  (renderização em Dart puro, sem build nativo). Rode `flutter clean && flutter pub get` antes de buildar.

## [0.9.0] — 2026-07-14
### Adicionado
- **Materiais na tela Hoje:** seção ao final com os materiais da lição do dia — 2 PDFs (abrem em
  tela cheia via `syncfusion_flutter_pdfviewer`), player de **áudio M4A** e **vídeo MP4** embutido (`media_kit`).
  Manifesto `materiais.json` gerado de `scripts/gerar_materiais.py` (164 lições, caminhos reais do curso).
- **Tema claro/escuro** com alternância no menu lateral (persistido).
### Corrigido
- **Barra inferior some no Backlog:** Backlog/Concurso/Aluno passaram para dentro do shell, mantendo a
  navegação inferior visível.

## [0.8.0] — 2026-07-14
### Adicionado
- **Login** com botão "Entrar com Google" e **guarda de rota** (redireciona para /login quando
  deslogado). Autenticação isolada em `AuthRepository` — hoje um stub local que persiste o login;
  o OAuth real do Google entra com o Supabase, sem mudar a UI.
- **Menu lateral (drawer)** com todas as telas (Hoje, Plano, Módulos, Controle, Materiais, Backlog,
  Concurso, Aluno), cabeçalho com usuário e ação **Sair**. Substitui o menu ⋮ da tela Hoje.
- **Tela Backlog:** lições fora do plano ordenadas por prioridade, com resumo (quantidade, horas,
  quantas são de peso 0).

## [0.7.0] — 2026-07-14
### Adicionado
- **Tela Concurso:** resumo do certame (banca, cargo, vagas, salário, inscrições, taxa, data) e
  **contagem regressiva** para a prova. Dados em `assets/data/concurso.json`.
- **Tela Aluno:** disponibilidade de estudo editável por dia da semana (±15 min), com totais
  semana/fim de semana, persistida localmente; nota sobre regeneração do plano.
- Acesso a Concurso/Aluno via menu na barra da tela Hoje; rotas `/concurso` e `/aluno`.
### Corrigido
- **Build quebrado** no `controle_screen.dart`: cascatas com `++`/`+=` (inválidas em Dart)
  substituídas por statements normais.

## [0.6.0] — 2026-07-14
### Adicionado
- **Tela Controle (dashboard):** % geral de lições concluídas, progresso **por bloco de prova** e
  **por módulo**, além de tempo de estudo concluído e % por tempo. Reativo ao progresso local.

## [0.5.0] — 2026-07-14
### Adicionado
- **Telas Módulos e Lições:** lista de módulos com progresso, bloco e peso; detalhe com checkbox por
  lição. **Conclusão de módulo derivada** (todas as lições marcadas → módulo concluído).
- **Persistência local do progresso** via SharedPreferences (isolada em `ProgressoRepository`, troca
  por Supabase depois). Ação "Concluir tudo"/"Limpar" no módulo.

## [0.4.0] — 2026-07-14
### Adicionado
- **App Flutter** inicializado (`app/`): tema Material 3 (pt_BR), navegação go_router com 5 destinos,
  camadas domain/data/application e leitura do plano via assets JSON.
- **Tela Hoje:** dia selecionável, navegação dia a dia, sessões (Revisão/Estudo/Exercícios) com
  módulo e lição; suporte aos 2 estudos de fim de semana e segundas sem revisão.
- **Tela Plano:** calendário mensal com cores por bloco de prova, legenda e toque no dia → Hoje.

## [0.3.1] — 2026-07-14
### Corrigido
- Segundas-feiras deixam de gerar sessão de `REVISAO` (antes havia uma sessão de 0 min). Agora têm
  apenas `ESTUDO` e `EXERCICIOS`, e `revisao_ref` fica vazio.

## [0.3.0] — 2026-07-14
### Adicionado
- **Fim de semana com 2 conteúdos:** sábado e domingo estudam os dois módulos de maior peso
  elegíveis, com o tempo de estudo dividido meio a meio (2 sessões `ESTUDO` de 30 min).
- Coluna `n_conteudos` em `plano_dia`; `modulo_dia` passa a listar 2 módulos ("A + B") nos fins de semana.
### Alterado
- Plano regenerado (cobertura ~14,0%); cooldown mantido (0 repetições em ≤2 dias).

## [0.2.0] — 2026-07-14
### Alterado
- Pesos agora **lidos direto de `indice_curso.csv`** (o usuário preencheu a coluna `weight`), não
  mais derivados do edital. Nulo é preenchido com o peso do módulo.
- Novo algoritmo de agendamento: **Smooth Weighted Round-Robin com cooldown de 2 dias**. Os módulos
  se alternam ao longo dos dias — nenhum assunto se repete nos 2 dias seguintes — e o tempo por
  módulo fica proporcional ao peso.
- Plano regenerado: 173 lições / 1.037 h; cobertura ~13,6%; todos os blocos avançam em paralelo.
- `plano_dia` ganhou a coluna `modulo_dia`.
### Corrigido
- Módulos de peso 0 vão integralmente para o backlog (31 lições).

## [0.1.0] — 2026-07-14
### Adicionado
- Estrutura inicial do projeto e documentação (PRD, regras do plano, modelo de dados, arquitetura,
  roadmap, setup, ADRs 0001–0003).
- Processamento do índice do curso (`indice_curso.csv`) e do edital (`TCDF-edital.pdf`).
- Derivação de pesos de prioridade a partir dos blocos do edital (coluna `weight` original vazia).
- Seeds gerados: 18 módulos e 175 lições com durações em minutos (`data/seed_*`).
- Plano de estudo gerado para 15/07–15/11/2026 e backlog (`data/plano_*`, `data/backlog`).
- Schema Supabase inicial com RLS, trigger de conclusão de módulo e views de progresso.
- Scripts Python reprodutíveis (`scripts/gerar_seed.py`, `scripts/gerar_plano.py`).
