import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/realizacao_repository.dart';
import '../../domain/models/sessao.dart';

/// Realização de sessões guardada localmente (SharedPreferences).
class RealizacaoLocalRepository implements RealizacaoRepository {
  static const _chave = 'sessoes_realizadas';

  @override
  Future<Set<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_chave) ?? const <String>[]).toSet();
  }

  @override
  Future<void> definir(Sessao sessao, bool feita) async {
    final prefs = await SharedPreferences.getInstance();
    final atual = (prefs.getStringList(_chave) ?? const <String>[]).toSet();
    if (feita) {
      atual.add(sessao.id);
    } else {
      atual.remove(sessao.id);
    }
    await prefs.setStringList(_chave, atual.toList());
  }
}
