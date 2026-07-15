import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import '../../core/app_drawer.dart';
import '../../core/theme.dart';
import '../../domain/models/material_item.dart';
import '../../domain/models/modulo.dart';
import 'material_tile.dart';

/// Tela de materiais complementares, agrupados por módulo.
class MateriaisScreen extends ConsumerWidget {
  const MateriaisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modsAsync = ref.watch(modulosProvider);
    final matsAsync = ref.watch(materiaisPorModuloProvider);

    return Scaffold(
      drawer: const AppDrawer(rotaAtual: '/materiais'),
      appBar: AppBar(title: const Text('Materiais')),
      body: (modsAsync.isLoading || matsAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : modsAsync.hasError
              ? Center(child: Text('Erro: ${modsAsync.error}'))
              : _Lista(
                  modulos: modsAsync.asData?.value ?? const [],
                  porModulo:
                      matsAsync.asData?.value ?? const <String, List<MaterialItem>>{},
                ),
    );
  }
}

class _Lista extends StatelessWidget {
  final List<Modulo> modulos;
  final Map<String, List<MaterialItem>> porModulo;
  const _Lista({required this.modulos, required this.porModulo});

  @override
  Widget build(BuildContext context) {
    final comMaterial =
        modulos.where((m) => (porModulo[m.moduloId] ?? const []).isNotEmpty).toList();
    if (comMaterial.isEmpty) {
      return const Center(child: Text('Nenhum material disponível.'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      children: [
        for (final m in comMaterial)
          _ModuloExpansivel(modulo: m, itens: porModulo[m.moduloId]!),
      ],
    );
  }
}

class _ModuloExpansivel extends StatelessWidget {
  final Modulo modulo;
  final List<MaterialItem> itens;
  const _ModuloExpansivel({required this.modulo, required this.itens});

  @override
  Widget build(BuildContext context) {
    final cor = BlocoCores.de(modulo.bloco);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: cor.withOpacity(0.15),
          child: Text('${modulo.ordem}',
              style: TextStyle(
                  color: cor, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        title: Text(modulo.nome,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${itens.length} materiais'),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        children: [for (final it in itens) MaterialTile(item: it)],
      ),
    );
  }
}
