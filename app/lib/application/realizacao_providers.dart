import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase_config.dart';
import '../data/local/realizacao_local_repository.dart';
import '../data/supabase/supabase_realizacao_repository.dart';
import '../data/repositories/realizacao_repository.dart';
import '../domain/models/sessao.dart';

final realizacaoRepositoryProvider = Provider<RealizacaoRepository>(
  (ref) => SupabaseConfig.usarSupabaseAuth
      ? SupabaseRealizacaoRepository()
      : RealizacaoLocalRepository(),
);

/// Conjunto de sessões realizadas (por id).
class RealizacaoNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() =>
      ref.watch(realizacaoRepositoryProvider).carregar();

  Future<void> alternar(Sessao sessao) async {
    final atual = {...(state.valueOrNull ?? const <String>{})};
    final feita = !atual.contains(sessao.id);
    if (feita) {
      atual.add(sessao.id);
    } else {
      atual.remove(sessao.id);
    }
    state = AsyncData(atual);
    await ref.read(realizacaoRepositoryProvider).definir(sessao, feita);
  }
}

final realizacaoProvider =
    AsyncNotifierProvider<RealizacaoNotifier, Set<String>>(
        RealizacaoNotifier.new);
