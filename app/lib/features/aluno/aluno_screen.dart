import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/aluno_providers.dart';
import '../../core/app_drawer.dart';
import '../../core/format.dart';

class AlunoScreen extends ConsumerWidget {
  const AlunoScreen({super.key});

  static const _nomes = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(disponibilidadeProvider);
    return Scaffold(
      drawer: const AppDrawer(rotaAtual: '/aluno'),
      appBar: AppBar(
        title: const Text('Aluno'),
        actions: [
          IconButton(
            tooltip: 'Restaurar padrão',
            icon: const Icon(Icons.restart_alt),
            onPressed: () =>
                ref.read(disponibilidadeProvider.notifier).restaurarPadrao(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (mins) {
          final semana =
              mins.take(5).fold<int>(0, (a, b) => a + b);
          final fds = mins.skip(5).fold<int>(0, (a, b) => a + b);
          final total = semana + fds;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _Resumo(semana: semana, fds: fds, total: total),
              const SizedBox(height: 12),
              Text('Disponibilidade por dia',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (var i = 0; i < 7; i++)
                        _LinhaDia(
                          nome: _nomes[i],
                          minutos: mins[i],
                          fimDeSemana: i >= 5,
                          onMenos: () => ref
                              .read(disponibilidadeProvider.notifier)
                              .definirDia(i, mins[i] - 15),
                          onMais: () => ref
                              .read(disponibilidadeProvider.notifier)
                              .definirDia(i, mins[i] + 15),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _NotaRegeneracao(),
            ],
          );
        },
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final int semana;
  final int fds;
  final int total;
  const _Resumo({required this.semana, required this.fds, required this.total});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Card(
      color: s.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _Bloco(rotulo: 'Seg–Sex', valor: Fmt.minutos(semana)),
            _Bloco(rotulo: 'Fim de semana', valor: Fmt.minutos(fds)),
            _Bloco(rotulo: 'Total/semana', valor: Fmt.minutos(total)),
          ],
        ),
      ),
    );
  }
}

class _Bloco extends StatelessWidget {
  final String rotulo;
  final String valor;
  const _Bloco({required this.rotulo, required this.valor});
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: s.onSecondaryContainer, fontWeight: FontWeight.bold)),
          Text(rotulo,
              style: TextStyle(color: s.onSecondaryContainer, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LinhaDia extends StatelessWidget {
  final String nome;
  final int minutos;
  final bool fimDeSemana;
  final VoidCallback onMenos;
  final VoidCallback onMais;
  const _LinhaDia({
    required this.nome,
    required this.minutos,
    required this.fimDeSemana,
    required this.onMenos,
    required this.onMais,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            fimDeSemana ? Icons.weekend_outlined : Icons.event_note_outlined,
            size: 20,
            color: s.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(nome)),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: minutos <= 0 ? null : onMenos,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 74,
            child: Text(
              Fmt.minutos(minutos),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onMais,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

class _NotaRegeneracao extends StatelessWidget {
  const _NotaRegeneracao();
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Card(
      color: s.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: s.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Alterar a disponibilidade não regenera o plano automaticamente ainda. '
                'A regeneração virá com o backend (Supabase). Por ora, ajuste também '
                'os parâmetros em scripts/gerar_plano.py e rode o script.',
                style: TextStyle(color: s.onSurfaceVariant, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
