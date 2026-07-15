import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../data/supabase/supabase_plano_repository.dart';
import '../data/repositories/plano_repository.dart';
import '../domain/models/plano_dia.dart';
import '../domain/models/sessao.dart';
import '../domain/models/licao.dart';
import '../domain/models/modulo.dart';
import '../domain/models/concurso.dart';
import '../domain/models/material_item.dart';

/// Data da prova (usada na contagem regressiva).
final dataProva = DateTime(2026, 11, 22);

/// Conteúdo (módulos, lições, plano, concurso) vem do Supabase; backlog e
/// materiais dos assets. Ver SupabasePlanoRepository.
final planoRepositoryProvider = Provider<PlanoRepository>(
  (ref) => SupabasePlanoRepository(),
);

final planoProvider = FutureProvider<List<PlanoDia>>(
  (ref) => ref.watch(planoRepositoryProvider).carregarPlano(),
);

final sessoesProvider = FutureProvider<List<Sessao>>(
  (ref) => ref.watch(planoRepositoryProvider).carregarSessoes(),
);

final licoesProvider = FutureProvider<Map<String, Licao>>(
  (ref) => ref.watch(planoRepositoryProvider).carregarLicoes(),
);

final modulosProvider = FutureProvider<List<Modulo>>(
  (ref) => ref.watch(planoRepositoryProvider).carregarModulos(),
);

final concursoProvider = FutureProvider<Concurso>(
  (ref) => ref.watch(planoRepositoryProvider).carregarConcurso(),
);

final backlogProvider = FutureProvider<List<Licao>>(
  (ref) => ref.watch(planoRepositoryProvider).carregarBacklog(),
);

final materiaisProvider =
    FutureProvider<Map<String, List<MaterialItem>>>(
  (ref) => ref.watch(planoRepositoryProvider).carregarMateriais(),
);

/// Materiais de uma lição específica (vazio se não houver).
final materiaisDaLicaoProvider =
    Provider.family<List<MaterialItem>, String>((ref, licaoId) {
  final mapa = ref.watch(materiaisProvider).asData?.value ?? const {};
  return mapa[licaoId] ?? const [];
});

/// Mapa nome-do-módulo → Modulo (para colorir o plano por bloco).
final modulosPorNomeProvider = FutureProvider<Map<String, Modulo>>((ref) async {
  final lista = await ref.watch(modulosProvider.future);
  return {for (final m in lista) m.nome: m};
});

/// Lições agrupadas por modulo_id, ordenadas por n_licao.
final licoesPorModuloProvider =
    FutureProvider<Map<String, List<Licao>>>((ref) async {
  final mapa = await ref.watch(licoesProvider.future);
  final out = <String, List<Licao>>{};
  for (final lic in mapa.values) {
    out.putIfAbsent(lic.moduloId, () => []).add(lic);
  }
  for (final lista in out.values) {
    lista.sort((a, b) => a.nLicao.compareTo(b.nLicao));
  }
  return out;
});

/// Data selecionada na tela Hoje. Default: data atual (será limitada à
/// janela do plano na hora de exibir).
final dataSelecionadaProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
});

/// Sessões de um dia específico, já ordenadas (Revisão, Estudo, Exercícios).
final sessoesDoDiaProvider =
    Provider.family<AsyncValue<List<Sessao>>, DateTime>((ref, dia) {
  final iso = Fmt.iso(dia);
  return ref.watch(sessoesProvider).whenData((todas) {
    final doDia = todas.where((s) => Fmt.iso(s.data) == iso).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    return doDia;
  });
});
