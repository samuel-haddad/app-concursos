import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import 'material_tile.dart';

/// Seção de materiais da lição do dia (na tela Hoje).
class MateriaisSecao extends ConsumerWidget {
  final String licaoId;
  const MateriaisSecao({super.key, required this.licaoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (licaoId.isEmpty) return const SizedBox.shrink();
    final itens = ref.watch(materiaisDaLicaoProvider(licaoId));
    if (itens.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.folder_open, size: 20),
            const SizedBox(width: 8),
            Text('Materiais', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in itens) MaterialTile(item: item),
      ],
    );
  }
}
