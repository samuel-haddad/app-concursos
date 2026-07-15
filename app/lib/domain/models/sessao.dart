/// Uma sessão de um dia (linha de plano_sessoes.json).
class Sessao {
  final DateTime data;
  final String tipo; // REVISAO | ESTUDO | EXERCICIOS
  final int minutos;
  final String licaoRef;
  final String moduloRef;

  Sessao({
    required this.data,
    required this.tipo,
    required this.minutos,
    required this.licaoRef,
    required this.moduloRef,
  });

  static int _i(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse('$v') ?? 0);
  static String _s(dynamic v) => v == null ? '' : '$v';

  factory Sessao.fromJson(Map<String, dynamic> j) => Sessao(
        data: DateTime.parse(j['data'] as String),
        tipo: _s(j['tipo']),
        minutos: _i(j['minutos']),
        licaoRef: _s(j['licao_ref']),
        moduloRef: _s(j['modulo_ref']),
      );

  /// Ordem de exibição: Revisão, Estudo, Exercícios.
  int get ordem => switch (tipo.toUpperCase()) {
        'REVISAO' => 0,
        'ESTUDO' => 1,
        'EXERCICIOS' => 2,
        _ => 3,
      };
}
