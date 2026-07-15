import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import '../../domain/models/material_item.dart';
// Implementação condicional: desktop/mobile (dart:io) x web (stub).
import 'materiais_impl_web.dart'
    if (dart.library.io) 'materiais_impl_io.dart' as impl;

/// Seção de materiais complementares de uma lição (PDFs, áudio, vídeo).
class MateriaisSecao extends ConsumerWidget {
  final String licaoId;
  const MateriaisSecao({super.key, required this.licaoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (licaoId.isEmpty) return const SizedBox.shrink();
    final itens = ref.watch(materiaisDaLicaoProvider(licaoId));

    final pdfs = itens.where((m) => m.tipo == TipoMaterial.pdf).toList();
    final audios = itens.where((m) => m.tipo == TipoMaterial.audio).toList();
    final videos = itens.where((m) => m.tipo == TipoMaterial.video).toList();

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
        if (itens.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sem materiais para esta lição.'),
            ),
          )
        else ...[
          for (final pdf in pdfs) impl.buildPdfCard(context, pdf),
          for (final audio in audios) impl.buildAudioCard(audio),
          for (final video in videos) impl.buildVideoCard(context, video),
        ],
      ],
    );
  }
}
