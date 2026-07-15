import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/supabase/material_url_service.dart';
import '../../domain/models/material_item.dart';

/// Card de um material: busca a URL assinada e abre no visualizador/player do
/// sistema (nova aba no navegador; app padrão no desktop). Abrir por navegação
/// evita CORS e problemas de renderização embutida.
class MaterialTile extends StatefulWidget {
  final MaterialItem item;
  final String? subtitulo;
  const MaterialTile({super.key, required this.item, this.subtitulo});

  @override
  State<MaterialTile> createState() => _MaterialTileState();
}

class _MaterialTileState extends State<MaterialTile> {
  bool _carregando = false;

  ({IconData icone, Color cor, String acao}) get _v {
    switch (widget.item.tipo) {
      case TipoMaterial.pdf:
        return (icone: Icons.picture_as_pdf, cor: const Color(0xFFC62828), acao: 'Abrir PDF');
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
    String? url;
    try {
      url = await MaterialUrlService.instance.urlAssinada(widget.item.key);
    } catch (e) {
      if (mounted) _msg('Falha ao carregar o material.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
    if (url == null) return;
    final ok = await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    if (!ok && mounted) _msg('Não foi possível abrir o material.');
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final v = _v;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(v.icone, color: v.cor),
        title: Text(widget.item.titulo),
        subtitle: Text(widget.subtitulo ?? v.acao),
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
