/// Um dia do plano de estudo (linha de plano_estudo.json).
class PlanoDia {
  final DateTime data;
  final String diaSemana;
  final int totalMin;
  final int revisaoMin;
  final int estudoMin;
  final int exerciciosMin;
  final int nConteudos;
  final String moduloDia;
  final String conteudoEstudo;
  final String licaoPrincipal;
  final String revisaoRef;
  final String exerciciosRef;

  PlanoDia({
    required this.data,
    required this.diaSemana,
    required this.totalMin,
    required this.revisaoMin,
    required this.estudoMin,
    required this.exerciciosMin,
    required this.nConteudos,
    required this.moduloDia,
    required this.conteudoEstudo,
    required this.licaoPrincipal,
    required this.revisaoRef,
    required this.exerciciosRef,
  });

  bool get fimDeSemana => diaSemana == 'Sab' || diaSemana == 'Dom';

  static int _i(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse('$v') ?? 0);
  static String _s(dynamic v) => v == null ? '' : '$v';

  factory PlanoDia.fromJson(Map<String, dynamic> j) => PlanoDia(
        data: DateTime.parse(j['data'] as String),
        diaSemana: _s(j['dia_semana']),
        totalMin: _i(j['total_min']),
        revisaoMin: _i(j['revisao_min']),
        estudoMin: _i(j['estudo_min']),
        exerciciosMin: _i(j['exercicios_min']),
        nConteudos: _i(j['n_conteudos']),
        moduloDia: _s(j['modulo_dia']),
        conteudoEstudo: _s(j['conteudo_estudo']),
        licaoPrincipal: _s(j['licao_principal']),
        revisaoRef: _s(j['revisao_ref']),
        exerciciosRef: _s(j['exercicios_ref']),
      );
}
