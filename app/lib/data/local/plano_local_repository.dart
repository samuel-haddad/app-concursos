import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../repositories/plano_repository.dart';
import '../../domain/models/plano_dia.dart';
import '../../domain/models/sessao.dart';
import '../../domain/models/licao.dart';
import '../../domain/models/modulo.dart';
import '../../domain/models/concurso.dart';
import '../../domain/models/material_item.dart';

/// Lê o plano gerado a partir dos assets JSON empacotados no app
/// (assets/data/*.json). Fonte inicial enquanto o Supabase não é ligado.
class PlanoLocalRepository implements PlanoRepository {
  Future<List<dynamic>> _lista(String arquivo) async {
    final raw = await rootBundle.loadString('assets/data/$arquivo');
    return jsonDecode(raw) as List<dynamic>;
  }

  @override
  Future<List<PlanoDia>> carregarPlano() async {
    final l = await _lista('plano_estudo.json');
    return l
        .map((e) => PlanoDia.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.data.compareTo(b.data));
  }

  @override
  Future<List<Sessao>> carregarSessoes() async {
    final l = await _lista('plano_sessoes.json');
    return l.map((e) => Sessao.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, Licao>> carregarLicoes() async {
    final l = await _lista('seed_licoes.json');
    final map = <String, Licao>{};
    for (final e in l) {
      final lic = Licao.fromJson(e as Map<String, dynamic>);
      map[lic.licaoId] = lic;
    }
    return map;
  }

  @override
  Future<List<Modulo>> carregarModulos() async {
    final l = await _lista('seed_modulos.json');
    return l.map((e) => Modulo.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
  }

  @override
  Future<Concurso> carregarConcurso() async {
    final raw = await rootBundle.loadString('assets/data/concurso.json');
    return Concurso.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<List<Licao>> carregarBacklog() async {
    final l = await _lista('backlog.json');
    return l
        .map((e) => Licao.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) {
        final w = b.weight.compareTo(a.weight);
        if (w != 0) return w;
        return a.moduloId.compareTo(b.moduloId);
      });
  }

  @override
  Future<Map<String, List<MaterialItem>>> carregarMateriais() async {
    final raw = await rootBundle.loadString('assets/data/materiais.json');
    final mapa = jsonDecode(raw) as Map<String, dynamic>;
    return mapa.map((licaoId, itens) => MapEntry(
          licaoId,
          (itens as List<dynamic>)
              .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ));
  }
}
