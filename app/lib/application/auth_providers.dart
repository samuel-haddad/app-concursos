import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/local_auth_repository.dart';
import '../data/supabase/supabase_auth_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/models/app_user.dart';
import '../core/supabase_config.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseConfig.usarSupabaseAuth
      ? SupabaseAuthRepository()
      : LocalAuthRepository(),
);

/// Estado de autenticação (carregando + usuário atual).
class AuthState {
  final bool carregando;
  final AppUser? user;
  const AuthState({required this.carregando, this.user});

  bool get logado => user != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _carregar();
    return const AuthState(carregando: true);
  }

  Future<void> _carregar() async {
    final u = await ref.read(authRepositoryProvider).usuarioAtual();
    state = AuthState(carregando: false, user: u);
  }

  Future<void> entrarComGoogle() async {
    state = const AuthState(carregando: true);
    final u = await ref.read(authRepositoryProvider).entrarComGoogle();
    state = AuthState(carregando: false, user: u);
  }

  Future<void> sair() async {
    await ref.read(authRepositoryProvider).sair();
    state = const AuthState(carregando: false);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
