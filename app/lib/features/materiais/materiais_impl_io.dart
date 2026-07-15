import 'package:flutter/material.dart';

import '../../domain/models/material_item.dart';
import 'audio_player_card.dart';
import 'pdf_viewer_screen.dart';
import 'video_player_card.dart';

/// Implementação de materiais para plataformas com sistema de arquivos
/// (desktop/mobile). Abre PDFs e reproduz áudio/vídeo dos arquivos locais.

Widget buildPdfCard(BuildContext context, MaterialItem item) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFC62828)),
      title: Text(item.titulo),
      subtitle: const Text('Abrir em tela cheia'),
      trailing: const Icon(Icons.open_in_full, size: 18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              PdfViewerScreen(path: item.path, titulo: item.titulo),
        ),
      ),
    ),
  );
}

Widget buildAudioCard(MaterialItem item) =>
    AudioPlayerCard(titulo: item.titulo, path: item.path);

Widget buildVideoCard(BuildContext context, MaterialItem item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
        child:
            Text(item.titulo, style: Theme.of(context).textTheme.bodyMedium),
      ),
      VideoPlayerCard(path: item.path),
      const SizedBox(height: 8),
    ],
  );
}
