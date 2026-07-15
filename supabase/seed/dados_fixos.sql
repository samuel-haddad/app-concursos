-- Dados fixos (concurso + disponibilidade). Rode LOGADO para o default owner=auth.uid() valer.

insert into concurso (banca, cargo, vagas, escolaridade, salario,
                      inscricao_ini, inscricao_fim, taxa, data_prova)
values ('Cebraspe', 'Analista Administrativo de Controle Externo', '10 + CR',
        'Superior (qualquer área)', 14990.41,
        date '2026-08-26', date '2026-09-17', 148.00, date '2026-11-22');

-- Disponibilidade: 0=segunda ... 6=domingo
insert into disponibilidade (dia_semana, minutos) values
  (0, 60),  -- segunda
  (1, 60),  -- terça
  (2, 60),  -- quarta
  (3, 60),  -- quinta
  (4, 60),  -- sexta
  (5, 120), -- sábado
  (6, 120)  -- domingo
on conflict (owner, dia_semana) do update set minutos = excluded.minutos;
