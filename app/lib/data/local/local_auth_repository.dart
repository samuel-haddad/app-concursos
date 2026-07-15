import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/auth_repository.dart';
import '../../domain/models/app_user.dart';

/// Stub de autenticação para desenvolvimento (sem backend).
/// Persiste apenas um flag "logado" localmente e devolve um usuário fixo.
///
/// Ao ligar o Supabase, substituir por SupabaseAuthRepository usando
/// `supabase.auth.signInWithOAuth(OAuthProvider.google)` e o stream
/// `onAuthStateChange` — sem mudar a UI.
class LocalAuthRepository implements AuthRepository {
  static const _chave = 'auth_logado';

  static const _demo = AppUser(
    id: 'local-user',
    nome: 'Samuel',
    email: 'samuelhsm@gmail.com',
  );

  @override
  Future<AppUser?> usuarioAtual() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(_chave) ?? false) ? _demo : null;
  }

  @override
  Future<AppUser> entrarComGoogle() async {
    // Simula a ida ao provedor. Real: OAuth Google via Supabase.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, true);
    return _demo;
  }

  @override
  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, false);
  }
}
