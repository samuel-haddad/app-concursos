import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/disponibilidade_repository.dart';

/// Persiste a disponibilidade localmente (SharedPreferences).
class DisponibilidadeLocalRepository implements DisponibilidadeRepository {
  static const _chave = 'disponibilidade_min';

  @override
  Future<List<int>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getStringList(_chave);
    if (salvo == null || salvo.length != 7) {
      return List<int>.from(disponibilidadePadrao);
    }
    return salvo.map((e) => int.tryParse(e) ?? 0).toList();
  }

  @override
  Future<void> salvar(List<int> minutosPorDia) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _chave, minutosPorDia.map((e) => e.toString()).toList());
  }
}
