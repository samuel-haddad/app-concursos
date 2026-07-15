import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/progresso_repository.dart';

/// Persiste o conjunto de lições concluídas localmente (SharedPreferences).
/// Na Web usa localStorage; em desktop/mobile, o storage nativo.
class ProgressoLocalRepository implements ProgressoRepository {
  static const _chave = 'licoes_concluidas';

  @override
  Future<Set<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_chave) ?? const <String>[]).toSet();
  }

  @override
  Future<void> salvar(Set<String> licoesConcluidas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chave, licoesConcluidas.toList());
  }
}
