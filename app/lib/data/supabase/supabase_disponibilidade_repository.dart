import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/disponibilidade_repository.dart';

/// Disponibilidade sincronizada no Supabase (tabela disponibilidade).
class SupabaseDisponibilidadeRepository implements DisponibilidadeRepository {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<List<int>> carregar() async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return List<int>.from(disponibilidadePadrao);
    final rows =
        await _c.from('disponibilidade').select('dia_semana,minutos');
    if (rows.isEmpty) return List<int>.from(disponibilidadePadrao);
    final arr = List<int>.from(disponibilidadePadrao);
    for (final r in rows) {
      final d = r['dia_semana'] as int;
      if (d >= 0 && d < 7) arr[d] = r['minutos'] as int;
    }
    return arr;
  }

  @override
  Future<void> salvar(List<int> minutosPorDia) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return;
    final rows = [
      for (var i = 0; i < 7; i++)
        {'user_id': uid, 'dia_semana': i, 'minutos': minutosPorDia[i]}
    ];
    await _c.from('disponibilidade').upsert(rows);
  }
}
