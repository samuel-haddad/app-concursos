import '../../domain/models/app_user.dart';

/// Contrato de autenticação. Hoje: stub local (LocalAuthRepository).
/// Futuro: Supabase Auth com OAuth do Google (signInWithOAuth).
abstract class AuthRepository {
  Future<AppUser?> usuarioAtual();
  Future<AppUser> entrarComGoogle();
  Future<void> sair();
}
