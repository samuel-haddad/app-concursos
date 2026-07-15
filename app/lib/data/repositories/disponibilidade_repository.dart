/// Contrato da disponibilidade de estudo do aluno.
/// Lista de 7 posições: índice 0 = segunda ... 6 = domingo (minutos/dia).
abstract class DisponibilidadeRepository {
  Future<List<int>> carregar();
  Future<void> salvar(List<int> minutosPorDia);
}

/// Padrão inicial: seg–sex 60 min; sáb/dom 120 min (4h no fim de semana).
const disponibilidadePadrao = <int>[60, 60, 60, 60, 60, 120, 120];
