/// Um módulo do curso (linha de seed_modulos.json).
class Modulo {
  final String moduloId;
  final int ordem;
  final String nome;
  final String bloco; // P1 | P2 | P3 | P4 | FORA
  final int weight;
  final int nLicoes;
  final int totalEstudoMin;

  Modulo({
    required this.moduloId,
    required this.ordem,
    required this.nome,
    required this.bloco,
    required this.weight,
    required this.nLicoes,
    required this.totalEstudoMin,
  });

  static int _i(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse('$v') ?? 0);
  static String _s(dynamic v) => v == null ? '' : '$v';

  factory Modulo.fromJson(Map<String, dynamic> j) => Modulo(
        moduloId: _s(j['modulo_id']),
        ordem: _i(j['ordem']),
        nome: _s(j['nome']),
        bloco: _s(j['bloco']),
        weight: _i(j['weight']),
        nLicoes: _i(j['n_licoes']),
        totalEstudoMin: _i(j['total_estudo_min']),
      );
}
