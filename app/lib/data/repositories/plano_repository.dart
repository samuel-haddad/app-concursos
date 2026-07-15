import '../../domain/models/plano_dia.dart';
import '../../domain/models/sessao.dart';
import '../../domain/models/licao.dart';
import '../../domain/models/modulo.dart';
import '../../domain/models/concurso.dart';
import '../../domain/models/material_item.dart';

/// Contrato de acesso ao plano. Hoje é implementado por assets locais
/// (PlanoLocalRepository); futuramente por Supabase, sem mudar a UI.
abstract class PlanoRepository {
  Future<List<PlanoDia>> carregarPlano();
  Future<List<Sessao>> carregarSessoes();
  Future<Map<String, Licao>> carregarLicoes();
  Future<List<Modulo>> carregarModulos();
  Future<Concurso> carregarConcurso();
  Future<List<Licao>> carregarBacklog();

  /// Materiais por licao_id.
  Future<Map<String, List<MaterialItem>>> carregarMateriais();
}
