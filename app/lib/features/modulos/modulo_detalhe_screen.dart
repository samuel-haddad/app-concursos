import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import '../../application/progresso_providers.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/models/licao.dart';
import '../../domain/models/modulo.dart';

class ModuloDetalheScreen extends ConsumerWidget {
  final String moduloId;
  const ModuloDetalheScreen({super.key, required this.moduloId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modsAsync = ref.watch(modulosProvider);
    final licoesAsync = ref.watch(licoesPorModuloProvider);
    final prog = ref.watch(progressoProvider).valueOrNull ?? const <String>{};

    final mods = modsAsync.asData?.value ?? const <Modulo>[];
    Modulo? modulo;
    for (final m in mods) {
      if (m.moduloId == moduloId) {
        modulo = m;
        break;
      }
    }
    final licoes =
        (licoesAsync.asData?.value ?? const <String, List<Licao>>{})[moduloId] ??
            const <Licao>[];

    final feitas = licoes.where((l) => prog.contains(l.licaoId)).length;
    final total = licoes.length;
    final concluido = total > 0 && feitas == total;
    final ids = licoes.map((l) => l.licaoId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(modulo?.nome ?? 'Módulo'),
        actions: [
          if (total > 0)
            TextButton(
              onPressed: () => ref
                  .read(progressoProvider.notifier)
                  .definirVarias(ids, !concluido),
              child: Text(concluido ? 'Limpar' : 'Concluir tudo'),
            ),
        ],
      ),
      body: modsAsync.isLoading || licoesAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                if (modulo != null)
                  _Cabecalho(
                      modulo: modulo,
                      feitas: feitas,
                      total: total,
                      concluido: concluido),
                const SizedBox(height: 12),
                Text('Lições', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                for (final l in licoes)
                  _LicaoTile(
                    licao: l,
                    concluida: prog.contains(l.licaoId),
                    onToggle: () =>
                        ref.read(progressoProvider.notifier).alternar(l.licaoId),
                  ),
                if (licoes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sem lições para este módulo.'),
                  ),
              ],
            ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final Modulo modulo;
  final int feitas;
  final int total;
  final bool concluido;
  const _Cabecalho({
    required this.modulo,
    required this.feitas,
    required this.total,
    required this.concluido,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final cor = BlocoCores.de(modulo.bloco);
    final pct = total == 0 ? 0.0 : feitas / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${modulo.bloco} · ${BlocoCores.rotulo(modulo.bloco)}',
                    style: TextStyle(color: cor, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('Peso ${modulo.weight}',
                    style: TextStyle(color: s.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: s.surfaceContainerHighest,
                      color: concluido ? s.primary : cor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$feitas/$total',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            if (concluido) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle, color: s.primary, size: 20),
                  const SizedBox(width: 6),
                  Text('Módulo concluído',
                      style: TextStyle(
                          color: s.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LicaoTile extends StatelessWidget {
  final Licao licao;
  final bool concluida;
  final VoidCallback onToggle;
  const _LicaoTile({
    required this.licao,
    required this.concluida,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final partes = <String>[];
    if (licao.docMin > 0) partes.add('Leitura ${Fmt.minutos(licao.docMin)}');
    if (licao.videoMin > 0) partes.add('Vídeo ${Fmt.minutos(licao.videoMin)}');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: concluida,
        onChanged: (_) => onToggle(),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('Lição ${licao.nLicao}: ${licao.titulo}'),
        subtitle: partes.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(partes.join('  ·  '),
                    style:
                        TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
              ),
      ),
    );
  }
}
