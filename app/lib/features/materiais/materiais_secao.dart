import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/plano_providers.dart';
import '../../data/supabase/material_url_service.dart';
import '../../domain/models/material_item.dart';
import 'pdf_viewer_screen.dart';

/// Seção de materiais da lição do dia. Cada item pede uma URL assinada
/// (Edge Function) e abre: PDF em tela cheia; áudio/vídeo no player nativo.
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
        for (final item in itens) _MaterialTile(item: item),
      ],
    );
  }
}

class _MaterialTile extends StatefulWidget {
  final MaterialItem item;
  const _MaterialTile({required this.item});

  @override
  State<_MaterialTile> createState() => _MaterialTileState();
}

class _MaterialTileState extends State<_MaterialTile> {
  final _service = MaterialUrlService();
  bool _carregando = false;

  ({IconData icone, Color cor, String acao}) get _visual {
    switch (widget.item.tipo) {
      case TipoMaterial.pdf:
        return (icone: Icons.picture_as_pdf, cor: const Color(0xFFC62828), acao: 'Abrir em tela cheia');
      case TipoMaterial.audio:
        return (icone: Icons.audiotrack, cor: const Color(0xFF00796B), acao: 'Reproduzir áudio');
      case TipoMaterial.video:
        return (icone: Icons.movie, cor: const Color(0xFF1565C0), acao: 'Reproduzir vídeo');
      default:
        return (icone: Icons.insert_drive_file, cor: Colors.grey, acao: 'Abrir');
    }
  }

  Future<void> _abrir() async {
    setState(() => _carregando = true);
    try {
      final url = await _service.urlAssinada(widget.item.key);
      if (!mounted) return;
      if (widget.item.tipo == TipoMaterial.pdf) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: url, titulo: widget.item.titulo),
        ));
      } else {
        final ok = await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication);
        if (!ok && mounted) _erro('Não foi possível abrir o player.');
      }
    } catch (e) {
      if (mounted) _erro('Falha ao carregar o material.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _erro(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(v.icone, color: v.cor),
        title: Text(widget.item.titulo),
        subtitle: Text(v.acao),
        trailing: _carregando
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.open_in_new, size: 18),
        onTap: _carregando ? null : _abrir,
      ),
    );
  }
}
