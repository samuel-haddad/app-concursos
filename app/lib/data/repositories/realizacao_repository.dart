import '../../domain/models/sessao.dart';

/// Contrato de persistência da realização de sessões (estudo/revisão/exercícios).
/// Presença do id no conjunto = sessão feita.
abstract class RealizacaoRepository {
  Future<Set<String>> carregar();
  Future<void> definir(Sessao sessao, bool feita);
}
