import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import '../../core/app_drawer.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/models/licao.dart';

class BacklogScreen extends ConsumerWidget {
  const BacklogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(backlogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Backlog')),
      drawer: const AppDrawer(rotaAtual: '/backlog'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(child: Text('Backlog vazio.'));
          }
          final totalMin =
              lista.fold<int>(0, (a, l) => a + l.estudoMin);
          final semPeso = lista.where((l) => l.weight == 0).length;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: lista.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return _Resumo(
                  qtd: lista.length,
                  totalMin: totalMin,
                  semPeso: semPeso,
                );
              }
              return _ItemBacklog(licao: lista[i - 1]);
            },
          );
        },
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final int qtd;
  final int totalMin;
  final int semPeso;
  const _Resumo({
    required this.qtd,
    required this.totalMin,
    required this.semPeso,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$qtd lições fora do plano',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Somam ${Fmt.minutos(totalMin)} de conteúdo. '
              '$semPeso são de peso 0 (deixadas de lado); as demais não '
              'couberam no tempo disponível.',
              style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemBacklog extends StatelessWidget {
  final Licao licao;
  const _ItemBacklog({required this.licao});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final cor = BlocoCores.de(licao.bloco);
    final partes = <String>[];
    if (licao.docMin > 0) partes.add('Leitura ${Fmt.minutos(licao.docMin)}');
    if (licao.videoMin > 0) partes.add('Vídeo ${Fmt.minutos(licao.videoMin)}');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                licao.weight == 0 ? 'P0' : 'P${licao.weight}',
                style: TextStyle(
                    color: cor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(licao.modulo,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Lição ${licao.nLicao}: ${licao.titulo}',
                      style: TextStyle(color: s.onSurfaceVariant, fontSize: 13)),
                  if (partes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(partes.join('  ·  '),
                        style: TextStyle(
                            color: s.onSurfaceVariant, fontSize: 11)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
