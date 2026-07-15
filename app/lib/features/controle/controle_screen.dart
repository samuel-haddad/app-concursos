import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import '../../application/progresso_providers.dart';
import '../../core/app_drawer.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/models/licao.dart';
import '../../domain/models/modulo.dart';

/// Agregado de progresso (contagem e minutos).
class _Prog {
  int feitas = 0;
  int total = 0;
  int minFeitos = 0;
  int minTotal = 0;
  double get pct => total == 0 ? 0 : feitas / total;
}

class ControleScreen extends ConsumerWidget {
  const ControleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licoesAsync = ref.watch(licoesProvider);
    final modsAsync = ref.watch(modulosProvider);
    final porModuloAsync = ref.watch(licoesPorModuloProvider);
    final progAsync = ref.watch(progressoProvider);

    return Scaffold(
      drawer: const AppDrawer(rotaAtual: '/controle'),
      appBar: AppBar(title: const Text('Controle')),
      body: () {
        if (licoesAsync.isLoading || modsAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final licoes =
            (licoesAsync.asData?.value ?? const <String, Licao>{}).values.toList();
        final mods = modsAsync.asData?.value ?? const <Modulo>[];
        final porModulo =
            porModuloAsync.asData?.value ?? const <String, List<Licao>>{};
        final prog = progAsync.valueOrNull ?? const <String>{};

        // geral
        final geral = _Prog();
        final porBloco = <String, _Prog>{};
        for (final l in licoes) {
          final feita = prog.contains(l.licaoId);
          final b = porBloco.putIfAbsent(l.bloco, () => _Prog());
          geral.total++;
          geral.minTotal += l.estudoMin;
          b.total++;
          b.minTotal += l.estudoMin;
          if (feita) {
            geral.feitas++;
            geral.minFeitos += l.estudoMin;
            b.feitas++;
            b.minFeitos += l.estudoMin;
          }
        }

        const ordemBloco = ['P1', 'P2', 'P3', 'P4', 'FORA'];
        final blocos = ordemBloco.where(porBloco.containsKey).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            _KpiGeral(geral: geral),
            const SizedBox(height: 16),
            Text('Por bloco de prova',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (final b in blocos) ...[
                      _LinhaBloco(bloco: b, prog: porBloco[b]!),
                      if (b != blocos.last) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Por módulo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final m in mods)
              _LinhaModulo(
                modulo: m,
                licoes: porModulo[m.moduloId] ?? const <Licao>[],
                prog: prog,
              ),
          ],
        );
      }(),
    );
  }
}

class _KpiGeral extends StatelessWidget {
  final _Prog geral;
  const _KpiGeral({required this.geral});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final pctTempo =
        geral.minTotal == 0 ? 0.0 : geral.minFeitos / geral.minTotal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${(geral.pct * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: s.primary, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('das lições concluídas',
                      style: TextStyle(color: s.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: geral.pct,
                minHeight: 10,
                backgroundColor: s.surfaceContainerHighest,
                color: s.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(
                    rotulo: 'Lições',
                    valor: '${geral.feitas}/${geral.total}'),
                _Metric(
                    rotulo: 'Tempo estudado',
                    valor: Fmt.minutos(geral.minFeitos)),
                _Metric(
                    rotulo: '% por tempo',
                    valor: '${(pctTempo * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String rotulo;
  final String valor;
  const _Metric({required this.rotulo, required this.valor});
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor, style: Theme.of(context).textTheme.titleMedium),
          Text(rotulo,
              style: TextStyle(color: s.onSurfaceVariant, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LinhaBloco extends StatelessWidget {
  final String bloco;
  final _Prog prog;
  const _LinhaBloco({required this.bloco, required this.prog});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final cor = BlocoCores.de(bloco);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text('$bloco · ${BlocoCores.rotulo(bloco)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${prog.feitas}/${prog.total}',
                style: TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: prog.pct,
            minHeight: 6,
            backgroundColor: s.surfaceContainerHighest,
            color: cor,
          ),
        ),
      ],
    );
  }
}

class _LinhaModulo extends StatelessWidget {
  final Modulo modulo;
  final List<Licao> licoes;
  final Set<String> prog;
  const _LinhaModulo({
    required this.modulo,
    required this.licoes,
    required this.prog,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final cor = BlocoCores.de(modulo.bloco);
    final total = licoes.length;
    final feitas = licoes.where((l) => prog.contains(l.licaoId)).length;
    final pct = total == 0 ? 0.0 : feitas / total;
    final concluido = total > 0 && feitas == total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${modulo.ordem}. ${modulo.nome}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              if (concluido)
                Icon(Icons.check_circle, size: 16, color: s.primary),
              const SizedBox(width: 4),
              Text('$feitas/$total',
                  style: TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: s.surfaceContainerHighest,
              color: concluido ? s.primary : cor,
            ),
          ),
        ],
      ),
    );
  }
}
