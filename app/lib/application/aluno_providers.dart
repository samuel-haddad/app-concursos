import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/disponibilidade_local_repository.dart';
import '../data/supabase/supabase_disponibilidade_repository.dart';
import '../data/repositories/disponibilidade_repository.dart';
import '../core/supabase_config.dart';

final disponibilidadeRepositoryProvider = Provider<DisponibilidadeRepository>(
  (ref) => SupabaseConfig.usarSupabaseAuth
      ? SupabaseDisponibilidadeRepository()
      : DisponibilidadeLocalRepository(),
);

/// Minutos disponíveis por dia da semana (0=seg ... 6=dom).
class DisponibilidadeNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() =>
      ref.watch(disponibilidadeRepositoryProvider).carregar();

  Future<void> definirDia(int dia, int minutos) async {
    final atual = [...(state.valueOrNull ?? disponibilidadePadrao)];
    atual[dia] = minutos.clamp(0, 600);
    state = AsyncData(atual);
    await ref.read(disponibilidadeRepositoryProvider).salvar(atual);
  }

  Future<void> restaurarPadrao() async {
    final padrao = List<int>.from(disponibilidadePadrao);
    state = AsyncData(padrao);
    await ref.read(disponibilidadeRepositoryProvider).salvar(padrao);
  }
}

final disponibilidadeProvider =
    AsyncNotifierProvider<DisponibilidadeNotifier, List<int>>(
        DisponibilidadeNotifier.new);
