# PRD — App de Estudo TCDF

## 1. Visão

Um web app **pessoal** (single-user) que centraliza o plano de estudo para o concurso de Analista
Administrativo de Controle Externo do TCDF. Ele transforma o conteúdo de um curso (módulos, lições,
durações) em um **plano diário executável**, respeitando a disponibilidade real de estudo e a
importância de cada assunto, e permite acompanhar o progresso até a prova.

## 2. Problema

- O conteúdo do curso é muito maior (1.041 h) do que o tempo disponível até a prova (160 h na janela).
- É preciso decidir **o que estudar, quando e por quanto tempo**, priorizando o que mais pontua.
- Falta uma visão única de progresso (o que já foi concluído, o que falta, o que caiu no backlog).

## 3. Público e uso

- Apenas o próprio usuário (Samuel). Sem multiusuário, sem cadastro público.
- Acesso primário via navegador (Flutter Web). Sincronização via Supabase entre dispositivos.

## 4. Concurso (contexto fixo)

| Campo | Valor |
|---|---|
| Banca | Cebraspe |
| Cargo | Analista Administrativo de Controle Externo |
| Vagas | 10 + CR |
| Escolaridade | Superior (qualquer área) |
| Salário | R$ 14.990,41 |
| Inscrições | 26/08/2026 a 17/09/2026 |
| Taxa | R$ 148,00 |
| Provas objetivas e discursiva | 22/11/2026 |
| Estrutura | P1 básicos (35 itens) · P2 específicos (45) · P3 especializados (70) · P4 discursiva |

## 5. Requisitos funcionais

### RF1 — Plano de estudo (macro)
Exibir o calendário do plano com o conteúdo de cada dia, da data seguinte à atual até uma semana
antes da prova.

### RF2 — Plano diário
Ao selecionar um dia (padrão: hoje), exibir as **sessões** do dia — revisão, estudo e exercícios —
com o tempo alocado a cada uma e o conteúdo (módulo/lição) correspondente.

### RF3 — Módulos e lições
Listar todos os módulos e, ao abrir um módulo, suas lições com duração de leitura (`doc`) e vídeo.

### RF4 — Controle de progresso
Marcar lições como **concluídas**. Quando todas as lições de um módulo estiverem concluídas, o módulo
é automaticamente concluído. Dashboard com percentuais (por módulo, por bloco, geral).

### RF5 — Concurso
Tela-resumo com os dados básicos do certame (tabela acima) e contagem regressiva para a prova.

### RF6 — Aluno
Configurar a disponibilidade de estudo (minutos por dia da semana / fim de semana). Alterações
podem disparar **regeneração do plano**.

### RF7 — Materiais complementares
Para cada módulo, acessar materiais em **PDF** (visualizar no app), **vídeo** e **áudio** (reproduzir
no app), incluindo resumos.

### RF8 — Backlog
Listar lições/módulos não contemplados no plano por falta de tempo, ordenados por prioridade, com
opção de promover manualmente ao plano.

## 6. Interações-chave (o que o app deve fazer)

1. Exibir a visão macro do plano.
2. Exibir o plano de um dia selecionado (padrão: dia atual).
3. Dashboard de controle com desempenho (percentuais estudados etc.).
4. Exibir PDFs.
5. Reproduzir vídeos e áudios de apoio.

## 7. Requisitos não-funcionais

- **Offline-first leve:** cache local do plano e progresso; sincroniza com Supabase quando online.
- **Responsivo:** priorizar layout web desktop; utilizável em mobile.
- **Reprodutibilidade:** o plano é gerado por script versionado (`scripts/`), não “na mão”.
- **Privacidade:** dados pessoais de estudo ficam na conta Supabase do usuário (RLS ativa).

## 8. Fora de escopo (v1)

- Banco de questões próprio / correção de exercícios dentro do app.
- Repetição espaçada automática (SRS) — a revisão é baseada em regra simples de “conteúdo anterior”.
- Compartilhamento social / colaboração.

## 9. Métricas de sucesso (pessoais)

- % de aderência ao plano (dias cumpridos).
- % de conteúdo prioritário (P3/P2) concluído até a prova.
- Redução do backlog de alta prioridade.
