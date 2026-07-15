/// Uma lição (linha de seed_licoes.json).
class Licao {
  final String licaoId;
  final String moduloId;
  final String modulo;
  final int nLicao;
  final String titulo;
  final int docMin;
  final int videoMin;
  final int estudoMin;
  final String bloco;
  final int weight;

  Licao({
    required this.licaoId,
    required this.moduloId,
    required this.modulo,
    required this.nLicao,
    required this.titulo,
    required this.docMin,
    required this.videoMin,
    required this.estudoMin,
    required this.bloco,
    required this.weight,
  });

  static int _i(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse('$v') ?? 0);
  static String _s(dynamic v) => v == null ? '' : '$v';

  factory Licao.fromJson(Map<String, dynamic> j) => Licao(
        licaoId: _s(j['licao_id']),
        moduloId: _s(j['modulo_id']),
        modulo: _s(j['modulo']),
        nLicao: _i(j['n_licao']),
        titulo: _s(j['titulo']),
        docMin: _i(j['doc_min']),
        videoMin: _i(j['video_min']),
        estudoMin: _i(j['estudo_min']),
        bloco: _s(j['bloco']),
        weight: _i(j['weight']),
      );
}
