/// Um material complementar de uma lição (materiais.json).
/// `key` é o caminho do objeto no Cloudflare R2 (ex.: mod_01/resumo.pdf).
enum TipoMaterial { pdf, audio, video, outro }

class MaterialItem {
  final TipoMaterial tipo;
  final String titulo;
  final String key;

  MaterialItem({required this.tipo, required this.titulo, required this.key});

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
        key: (j['key'] ?? j['path'] ?? '').toString(),
      );
}
