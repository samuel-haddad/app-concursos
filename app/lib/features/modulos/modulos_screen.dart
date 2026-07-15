import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/plano_providers.dart';
import '../../application/progresso_providers.dart';
import '../../core/app_drawer.dart';
import '../../core/theme.dart';
import '../../domain/models/licao.dart';
import '../../domain/models/modulo.dart';

class ModulosScreen extends ConsumerWidget {
  const ModulosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modsAsync = ref.watch(modulosProvider);
    final licoesAsync = ref.watch(licoesPorModuloProvider);
    final prog = ref.watch(progressoProvider).valueOrNull ?? const <String>{};

    return Scaffold(
      drawer: const AppDrawer(rotaAtual: '/modulos'),
      appBar: AppBar(title: const Text('Módulos')),
      body: modsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (mods) {
          final porModulo =
              licoesAsync.asData?.value ?? const <String, List<Licao>>{};
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: mods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = mods[i];
              final licoes = porModulo[m.moduloId] ?? const <Licao>[];
              final total = licoes.length;
              final feitas =
                  licoes.where((l) => prog.contains(l.licaoId)).length;
              return _ModuloCard(
                modulo: m,
                total: total,
                feitas: feitas,
                onTap: () => context.push('/modulos/${m.moduloId}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _ModuloCard extends StatelessWidget {
  final Modulo modulo;
  final int total;
  final int feitas;
  final VoidCallback onTap;
  const _ModuloCard({
    required this.modulo,
    required this.total,
    required this.feitas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final concluido = total > 0 && feitas == total;
    final pct = total == 0 ? 0.0 : feitas / total;
    final cor = BlocoCores.de(modulo.bloco);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: cor.withOpacity(0.15),
                    child: Text('${modulo.ordem}',
                        style: TextStyle(
                            color: cor, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(modulo.nome,
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  if (concluido)
                    Icon(Icons.check_circle, color: s.primary, size: 22),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Tag(texto: modulo.bloco, cor: cor),
                  const SizedBox(width: 8),
                  _Tag(texto: 'Peso ${modulo.weight}', cor: s.outline),
                  const Spacer(),
                  Text('$feitas/$total lições',
                      style: TextStyle(
                          color: s.onSurfaceVariant, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: s.surfaceContainerHighest,
                  color: concluido ? s.primary : cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String texto;
  final Color cor;
  const _Tag({required this.texto, required this.cor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(texto,
          style: TextStyle(
              color: cor, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
