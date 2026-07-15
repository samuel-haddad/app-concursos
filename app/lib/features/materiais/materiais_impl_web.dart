import 'package:flutter/material.dart';

import '../../domain/models/material_item.dart';

/// Implementação de materiais para Web. Os arquivos ficam no computador do
/// usuário (caminhos locais), que o navegador não acessa — então mostramos um
/// aviso. (Para servir mídia na web, use o Supabase Storage numa próxima fase.)

Widget _indisponivel(IconData icone, String titulo) => Builder(
      builder: (context) {
        final s = Theme.of(context).colorScheme;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(icone, color: s.onSurfaceVariant),
            title: Text(titulo),
            subtitle: const Text('Disponível apenas no app desktop'),
          ),
        );
      },
    );

Widget buildPdfCard(BuildContext context, MaterialItem item) =>
    _indisponivel(Icons.picture_as_pdf, item.titulo);

Widget buildAudioCard(MaterialItem item) =>
    _indisponivel(Icons.audiotrack, item.titulo);

Widget buildVideoCard(BuildContext context, MaterialItem item) =>
    _indisponivel(Icons.movie, item.titulo);
