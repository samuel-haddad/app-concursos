import 'package:supabase_flutter/supabase_flutter.dart';

/// Obtém uma URL assinada temporária para um material no R2, chamando a Edge
/// Function `assinar-material` (exige usuário logado). Faz cache em memória:
/// as URLs valem 1h, então reaproveitamos por até ~55 min sem chamar de novo.
class MaterialUrlService {
  MaterialUrlService._();
  static final MaterialUrlService instance = MaterialUrlService._();

  static const _validade = Duration(minutes: 55);
  final Map<String, ({String url, DateTime em})> _cache = {};

  Future<String> urlAssinada(String key) async {
    final c = _cache[key];
    if (c != null && DateTime.now().difference(c.em) < _validade) {
      return c.url;
    }
    final res = await Supabase.instance.client.functions.invoke(
      'assinar-material',
      body: {'key': key},
    );
    final data = res.data;
    if (data is Map && data['url'] is String) {
      final url = data['url'] as String;
      _cache[key] = (url: url, em: DateTime.now());
      return url;
    }
    throw Exception('Não foi possível assinar o material (${res.status}).');
  }
}
