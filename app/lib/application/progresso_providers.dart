import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/progresso_local_repository.dart';
import '../data/supabase/supabase_progresso_repository.dart';
import '../data/repositories/progresso_repository.dart';
import '../core/supabase_config.dart';

final progressoRepositoryProvider = Provider<ProgressoRepository>(
  (ref) => SupabaseConfig.usarSupabaseAuth
      ? SupabaseProgressoRepository()
      : ProgressoLocalRepository(),
);

/// Conjunto de lições concluídas (ids). Carrega da persistência e permite
/// alternar/definir, salvando a cada mudança.
class ProgressoNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() =>
      ref.watch(progressoRepositoryProvider).carregar();

  Future<void> _persistir(Set<String> novo) async {
    state = AsyncData(novo);
    await ref.read(progressoRepositoryProvider).salvar(novo);
  }

  Future<void> alternar(String licaoId) async {
    final atual = {...(state.valueOrNull ?? const <String>{})};
    if (!atual.add(licaoId)) atual.remove(licaoId);
    await _persistir(atual);
  }

  /// Marca (ou desmarca) todas as lições informadas de uma vez.
  Future<void> definirVarias(Iterable<String> ids, bool concluir) async {
    final atual = {...(state.valueOrNull ?? const <String>{})};
    if (concluir) {
      atual.addAll(ids);
    } else {
      atual.removeAll(ids);
    }
    await _persistir(atual);
  }
}

final progressoProvider =
    AsyncNotifierProvider<ProgressoNotifier, Set<String>>(ProgressoNotifier.new);
