import 'package:supabase_flutter/supabase_flutter.dart';

/// Obtém uma URL assinada temporária para um material no R2,
/// chamando a Edge Function `assinar-material` (exige usuário logado).
class MaterialUrlService {
  Future<String> urlAssinada(String key) async {
    final res = await Supabase.instance.client.functions.invoke(
      'assinar-material',
      body: {'key': key},
    );
    final data = res.data;
    if (data is Map && data['url'] is String) {
      return data['url'] as String;
    }
    throw Exception('Não foi possível assinar o material (${res.status}).');
  }
}
