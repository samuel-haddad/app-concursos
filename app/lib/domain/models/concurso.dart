/// Dados do certame (concurso.json).
class Concurso {
  final String banca;
  final String cargo;
  final String orgao;
  final String vagas;
  final String escolaridade;
  final double salario;
  final DateTime inscricaoIni;
  final DateTime inscricaoFim;
  final double taxa;
  final DateTime dataProva;

  Concurso({
    required this.banca,
    required this.cargo,
    required this.orgao,
    required this.vagas,
    required this.escolaridade,
    required this.salario,
    required this.inscricaoIni,
    required this.inscricaoFim,
    required this.taxa,
    required this.dataProva,
  });

  static double _d(dynamic v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
  static String _s(dynamic v) => v == null ? '' : '$v';

  factory Concurso.fromJson(Map<String, dynamic> j) => Concurso(
        banca: _s(j['banca']),
        cargo: _s(j['cargo']),
        orgao: _s(j['orgao']),
        vagas: _s(j['vagas']),
        escolaridade: _s(j['escolaridade']),
        salario: _d(j['salario']),
        inscricaoIni: DateTime.parse(j['inscricao_ini'] as String),
        inscricaoFim: DateTime.parse(j['inscricao_fim'] as String),
        taxa: _d(j['taxa']),
        dataProva: DateTime.parse(j['data_prova'] as String),
      );
}
