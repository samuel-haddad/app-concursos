-- =====================================================================
-- App de Estudo TCDF — schema inicial (Supabase / PostgreSQL)
-- Migration 0001
-- App pessoal (single-user): RLS restringe tudo ao dono (auth.uid()).
-- =====================================================================

-- Extensões úteis
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------
do $$ begin
  create type bloco_prova as enum ('P1','P2','P3','P4','FORA');
exception when duplicate_object then null; end $$;

do $$ begin
  create type tipo_sessao as enum ('REVISAO','ESTUDO','EXERCICIOS');
exception when duplicate_object then null; end $$;

do $$ begin
  create type tipo_material as enum ('PDF','VIDEO','AUDIO');
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------
-- Helper: owner padrão = usuário autenticado
-- ---------------------------------------------------------------------
-- Cada tabela tem coluna owner uuid default auth.uid() e RLS por owner.

-- ============================ CONCURSO ================================
create table if not exists concurso (
  id            uuid primary key default gen_random_uuid(),
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  banca         text not null,
  cargo         text not null,
  vagas         text,
  escolaridade  text,
  salario       numeric(12,2),
  inscricao_ini date,
  inscricao_fim date,
  taxa          numeric(10,2),
  data_prova    date not null,
  criado_em     timestamptz not null default now()
);

-- ======================= ALUNO / DISPONIBILIDADE =====================
-- 1 linha por dia da semana (0=segunda ... 6=domingo)
create table if not exists disponibilidade (
  id           uuid primary key default gen_random_uuid(),
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  dia_semana   smallint not null check (dia_semana between 0 and 6),
  minutos      integer not null default 0 check (minutos >= 0),
  unique (owner, dia_semana)
);

-- ============================= MÓDULO ================================
create table if not exists modulo (
  modulo_id        text primary key,          -- ex: mod_01
  owner            uuid not null default auth.uid() references auth.users(id) on delete cascade,
  ordem            integer not null,
  nome             text not null,
  bloco            bloco_prova not null,
  weight           integer not null default 0,
  n_licoes         integer not null default 0,
  total_doc_min    integer not null default 0,
  total_video_min  integer not null default 0,
  total_estudo_min integer not null default 0
);

-- coluna gerada: módulo concluído quando todas as lições estão concluídas
-- (mantida por trigger — ver abaixo)
alter table modulo add column if not exists concluido boolean not null default false;

-- ============================== LIÇÃO ================================
create table if not exists licao (
  licao_id     text primary key,              -- ex: mod_12_l01
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  modulo_id    text not null references modulo(modulo_id) on delete cascade,
  n_licao      integer not null,
  titulo       text not null,
  doc_min      integer not null default 0,
  video_min    integer not null default 0,
  estudo_min   integer not null default 0,
  bloco        bloco_prova not null,
  weight       integer not null default 0,
  concluido    boolean not null default false,
  concluido_em timestamptz
);
create index if not exists idx_licao_modulo on licao(modulo_id);

-- ============================ MATERIAL ===============================
create table if not exists material (
  id           uuid primary key default gen_random_uuid(),
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  modulo_id    text not null references modulo(modulo_id) on delete cascade,
  licao_id     text references licao(licao_id) on delete set null,
  tipo         tipo_material not null,
  titulo       text not null,
  storage_path text,                          -- caminho no Supabase Storage
  url          text,                          -- url pública/assinada (opcional)
  criado_em    timestamptz not null default now()
);
create index if not exists idx_material_modulo on material(modulo_id);

-- ============================ PLANO_DIA ==============================
create table if not exists plano_dia (
  data            date not null,
  owner           uuid not null default auth.uid() references auth.users(id) on delete cascade,
  dia_semana      text not null,
  total_min       integer not null default 0,
  revisao_min     integer not null default 0,
  estudo_min      integer not null default 0,
  exercicios_min  integer not null default 0,
  n_conteudos     integer not null default 1, -- módulos estudados no dia (2 no fim de semana)
  modulo_dia      text,                       -- módulo(s) do dia (interleaving; " + " se 2)
  conteudo_estudo text,
  licao_principal text references licao(licao_id) on delete set null,
  revisao_ref     text,
  exercicios_ref  text,
  primary key (owner, data)
);

-- =========================== PLANO_SESSAO ============================
create table if not exists plano_sessao (
  id          uuid primary key default gen_random_uuid(),
  owner       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data        date not null,
  tipo        tipo_sessao not null,
  minutos     integer not null default 0,
  licao_ref   text references licao(licao_id) on delete set null,
  modulo_ref  text,
  concluida   boolean not null default false
);
create index if not exists idx_sessao_data on plano_sessao(owner, data);

-- ============================= BACKLOG ==============================
create table if not exists backlog (
  licao_id         text primary key references licao(licao_id) on delete cascade,
  owner            uuid not null default auth.uid() references auth.users(id) on delete cascade,
  ordem_prioridade integer not null default 0,
  motivo           text default 'Sem disponibilidade na janela do plano'
);

-- ---------------------------------------------------------------------
-- Trigger: conclusão automática do módulo
-- Quando todas as lições de um módulo estão concluídas -> modulo.concluido = true
-- ---------------------------------------------------------------------
create or replace function atualiza_conclusao_modulo() returns trigger
language plpgsql as $$
declare v_mod text; v_pend integer;
begin
  v_mod := coalesce(new.modulo_id, old.modulo_id);
  select count(*) into v_pend from licao where modulo_id = v_mod and concluido = false;
  update modulo set concluido = (v_pend = 0) where modulo_id = v_mod;
  return null;
end $$;

drop trigger if exists trg_conclusao_modulo on licao;
create trigger trg_conclusao_modulo
  after insert or update of concluido or delete on licao
  for each row execute function atualiza_conclusao_modulo();

-- ---------------------------------------------------------------------
-- View de dashboard (percentuais de progresso)
-- ---------------------------------------------------------------------
create or replace view vw_progresso_modulo as
select m.modulo_id, m.nome, m.bloco, m.weight,
       m.n_licoes,
       count(l.*) filter (where l.concluido) as licoes_concluidas,
       round(100.0 * count(l.*) filter (where l.concluido) / nullif(m.n_licoes,0), 1) as pct_concluido,
       m.concluido
from modulo m
left join licao l on l.modulo_id = m.modulo_id
group by m.modulo_id, m.nome, m.bloco, m.weight, m.n_licoes, m.concluido;

create or replace view vw_progresso_geral as
select
  count(*) as total_licoes,
  count(*) filter (where concluido) as concluidas,
  round(100.0 * count(*) filter (where concluido) / nullif(count(*),0), 1) as pct_geral,
  sum(estudo_min) as min_total,
  sum(estudo_min) filter (where concluido) as min_concluido
from licao;

-- ---------------------------------------------------------------------
-- RLS: tudo restrito ao owner (app pessoal)
-- ---------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['concurso','disponibilidade','modulo','licao','material',
                           'plano_dia','plano_sessao','backlog']
  loop
    execute format('alter table %I enable row level security;', t);
    execute format($p$create policy %I on %I for all
                     using (owner = auth.uid()) with check (owner = auth.uid());$p$,
                   t||'_owner', t);
  end loop;
exception when duplicate_object then null;
end $$;
