/// Contrato de persistência do progresso (lições concluídas por id).
/// Hoje: SharedPreferences (local). Futuro: Supabase (coluna licao.concluido).
abstract class ProgressoRepository {
  Future<Set<String>> carregar();
  Future<void> salvar(Set<String> licoesConcluidas);
}
