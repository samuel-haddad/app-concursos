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

/// Materiais únicos agrupados por modulo_id (para a tela Materiais).
/// Deriva os títulos das chaves (aula_NN.pdf, resumo.pdf/.m4a/.mp4).
final materiaisPorModuloProvider =
    FutureProvider<Map<String, List<MaterialItem>>>((ref) async {
  final mapa = await ref.watch(materiaisProvider.future);
  final vistos = <String>{};
  final porModulo = <String, List<MaterialItem>>{};
  for (final itens in mapa.values) {
    for (final it in itens) {
      if (!vistos.add(it.key)) continue; // dedup por chave
      final partes = it.key.split('/'); // mod_XX / arquivo
      if (partes.length != 2) continue;
      final moduloId = partes[0];
      porModulo.putIfAbsent(moduloId, () => []).add(_titulado(it));
    }
  }
  // ordena dentro do módulo: aulas (por número), depois resumos pdf/audio/video
  int rank(MaterialItem m) {
    final arq = m.key.split('/').last;
    if (arq.startsWith('aula_')) {
      final n = int.tryParse(arq.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return n; // 1..99
    }
    if (arq == 'resumo.pdf') return 100;
    if (arq == 'resumo.m4a') return 101;
    if (arq == 'resumo.mp4') return 102;
    return 200;
  }

  for (final lista in porModulo.values) {
    lista.sort((a, b) => rank(a).compareTo(rank(b)));
  }
  return porModulo;
});

MaterialItem _titulado(MaterialItem it) {
  final arq = it.key.split('/').last;
  String titulo;
  if (arq.startsWith('aula_')) {
    final n = arq.replaceAll(RegExp(r'[^0-9]'), '');
    titulo = 'Aula $n (PDF)';
  } else if (arq == 'resumo.pdf') {
    titulo = 'Resumo (PDF)';
  } else if (arq == 'resumo.m4a') {
    titulo = 'Resumo (áudio)';
  } else if (arq == 'resumo.mp4') {
    titulo = 'Resumo (vídeo)';
  } else {
    titulo = it.titulo;
  }
  return MaterialItem(tipo: it.tipo, titulo: titulo, key: it.key);
}

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
