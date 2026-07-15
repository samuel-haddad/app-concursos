/// Um material complementar de uma lição (materiais.json).
enum TipoMaterial { pdf, audio, video, outro }

class MaterialItem {
  final TipoMaterial tipo;
  final String titulo;
  final String path; // caminho do arquivo no computador do usuário

  MaterialItem({required this.tipo, required this.titulo, required this.path});

  static TipoMaterial _tipo(dynamic v) {
    switch ('$v'.toUpperCase()) {
      case 'PDF':
        return TipoMaterial.pdf;
      case 'AUDIO':
        return TipoMaterial.audio;
      case 'VIDEO':
        return TipoMaterial.video;
      default:
        return TipoMaterial.outro;
    }
  }

  factory MaterialItem.fromJson(Map<String, dynamic> j) => MaterialItem(
        tipo: _tipo(j['tipo']),
        titulo: (j['titulo'] ?? '').toString(),
        path: (j['path'] ?? '').toString(),
      );
}
