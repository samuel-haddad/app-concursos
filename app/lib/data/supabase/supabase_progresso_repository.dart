import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/progresso_repository.dart';

/// Progresso das lições sincronizado no Supabase (tabela licao_concluida).
class SupabaseProgressoRepository implements ProgressoRepository {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<Set<String>> carregar() async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return <String>{};
    final rows = await _c.from('licao_concluida').select('licao_id');
    return rows.map<String>((e) => e['licao_id'] as String).toSet();
  }

  @override
  Future<void> salvar(Set<String> licoesConcluidas) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return;
    // Substitui o conjunto do usuário.
    await _c.from('licao_concluida').delete().eq('user_id', uid);
    if (licoesConcluidas.isNotEmpty) {
      await _c.from('licao_concluida').insert(
            licoesConcluidas
                .map((id) => {'user_id': uid, 'licao_id': id})
                .toList(),
          );
    }
  }
}
