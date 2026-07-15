/// Uma sessão de um dia (Revisão/Estudo/Exercícios).
class Sessao {
  final String id; // estável: "yyyy-MM-dd|TIPO|ordinal"
  final DateTime data;
  final String tipo; // REVISAO | ESTUDO | EXERCICIOS
  final int minutos;
  final String licaoRef;
  final String moduloRef;

  Sessao({
    required this.id,
    required this.data,
    required this.tipo,
    required this.minutos,
    required this.licaoRef,
    required this.moduloRef,
  });

  static int _i(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse('$v') ?? 0);
  static String _s(dynamic v) => v == null ? '' : '$v';

  static String iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Monta o id estável a partir de data/tipo/ordinal.
  static String montarId(DateTime data, String tipo, int ordinal) =>
      '${iso(data)}|${tipo.toUpperCase()}|$ordinal';

  factory Sessao.fromJson(Map<String, dynamic> j, {int ordinal = 0}) {
    final data = DateTime.parse(j['data'] as String);
    final tipo = _s(j['tipo']);
    return Sessao(
      id: montarId(data, tipo, ordinal),
      data: data,
      tipo: tipo,
      minutos: _i(j['minutos']),
      licaoRef: _s(j['licao_ref']),
      moduloRef: _s(j['modulo_ref']),
    );
  }

  /// Ordem de exibição: Revisão, Estudo, Exercícios.
  int get ordem => switch (tipo.toUpperCase()) {
        'REVISAO' => 0,
        'ESTUDO' => 1,
        'EXERCICIOS' => 2,
        _ => 3,
      };
}
