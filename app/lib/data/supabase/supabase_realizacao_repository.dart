import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/realizacao_repository.dart';
import '../../domain/models/sessao.dart';

/// Realização de sessões sincronizada no Supabase (tabela sessao_realizada).
class SupabaseRealizacaoRepository implements RealizacaoRepository {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<Set<String>> carregar() async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return <String>{};
    final rows = await _c.from('sessao_realizada').select('sessao_id');
    return rows.map<String>((e) => e['sessao_id'] as String).toSet();
  }

  @override
  Future<void> definir(Sessao sessao, bool feita) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return;
    if (feita) {
      await _c.from('sessao_realizada').upsert({
        'user_id': uid,
        'sessao_id': sessao.id,
        'data': Sessao.iso(sessao.data),
        'tipo': sessao.tipo.toUpperCase(),
        'minutos': sessao.minutos,
      });
    } else {
      await _c
          .from('sessao_realizada')
          .delete()
          .eq('user_id', uid)
          .eq('sessao_id', sessao.id);
    }
  }
}
