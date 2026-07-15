import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/plano_repository.dart';
import '../../domain/models/plano_dia.dart';
import '../../domain/models/sessao.dart';
import '../../domain/models/licao.dart';
import '../../domain/models/modulo.dart';
import '../../domain/models/concurso.dart';
import '../../domain/models/material_item.dart';

/// Lê o conteúdo (módulos, lições, plano, concurso) do Supabase.
/// As sessões são reconstruídas a partir de plano_dia. Backlog e materiais
/// continuam vindo dos assets (dados derivados / caminhos locais).
class SupabasePlanoRepository implements PlanoRepository {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<List<Modulo>> carregarModulos() async {
    final rows = await _db.from('modulo').select().order('ordem');
    return rows.map<Modulo>((e) => Modulo.fromJson(e)).toList();
  }

  @override
  Future<Map<String, Licao>> carregarLicoes() async {
    final rows = await _db.from('licao').select();
    final map = <String, Licao>{};
    for (final e in rows) {
      final l = Licao.fromJson(e);
      map[l.licaoId] = l;
    }
    return map;
  }

  @override
  Future<List<PlanoDia>> carregarPlano() async {
    final rows = await _db.from('plano_dia').select().order('data');
    return rows.map<PlanoDia>((e) => PlanoDia.fromJson(e)).toList();
  }

  @override
  Future<Concurso> carregarConcurso() async {
    final row = await _db.from('concurso').select().limit(1).single();
    return Concurso.fromJson(row);
  }

  /// Reconstrói as sessões (Revisão/Estudo/Exercícios) de cada dia do plano.
  @override
  Future<List<Sessao>> carregarSessoes() async {
    final dias = await carregarPlano();
    final out = <Sessao>[];
    for (final d in dias) {
      if (d.revisaoMin > 0) {
        out.add(Sessao(
            data: d.data,
            tipo: 'REVISAO',
            minutos: d.revisaoMin,
            licaoRef: '',
            moduloRef: d.revisaoRef));
      }
      final modulos = d.moduloDia.split(' + ');
      if (d.nConteudos >= 2 && modulos.length == 2) {
        final metade = d.estudoMin ~/ 2;
        out.add(Sessao(
            data: d.data,
            tipo: 'ESTUDO',
            minutos: metade,
            licaoRef: d.licaoPrincipal,
            moduloRef: modulos[0]));
        out.add(Sessao(
            data: d.data,
            tipo: 'ESTUDO',
            minutos: d.estudoMin - metade,
            licaoRef: '',
            moduloRef: modulos[1]));
      } else {
        out.add(Sessao(
            data: d.data,
            tipo: 'ESTUDO',
            minutos: d.estudoMin,
            licaoRef: d.licaoPrincipal,
            moduloRef: d.moduloDia));
      }
      out.add(Sessao(
          data: d.data,
          tipo: 'EXERCICIOS',
          minutos: d.exerciciosMin,
          licaoRef: d.licaoPrincipal,
          moduloRef: d.exerciciosRef));
    }
    return out;
  }

  // Backlog e materiais continuam nos assets locais.
  Future<List<dynamic>> _asset(String arquivo) async {
    final raw = await rootBundle.loadString('assets/data/$arquivo');
    return jsonDecode(raw) as List<dynamic>;
  }

  @override
  Future<List<Licao>> carregarBacklog() async {
    final l = await _asset('backlog.json');
    return l.map((e) => Licao.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) {
        final w = b.weight.compareTo(a.weight);
        return w != 0 ? w : a.moduloId.compareTo(b.moduloId);
      });
  }

  @override
  Future<Map<String, List<MaterialItem>>> carregarMateriais() async {
    final raw = await rootBundle.loadString('assets/data/materiais.json');
    final mapa = jsonDecode(raw) as Map<String, dynamic>;
    return mapa.map((k, v) => MapEntry(
        k,
        (v as List<dynamic>)
            .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
            .toList()));
  }
}
