import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';
import '../../domain/models/app_user.dart';
import '../../core/supabase_config.dart';

/// Autenticação via Supabase com OAuth do Google.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _c => Supabase.instance.client;

  AppUser? _map(User? u) {
    if (u == null) return null;
    final m = u.userMetadata ?? const {};
    return AppUser(
      id: u.id,
      nome: (m['full_name'] ?? m['name'] ?? u.email ?? 'Usuário').toString(),
      email: u.email ?? '',
      avatarUrl: m['avatar_url']?.toString(),
    );
  }

  @override
  Future<AppUser?> usuarioAtual() async => _map(_c.auth.currentUser);

  @override
  Future<AppUser> entrarComGoogle() async {
    final completer = Completer<AppUser>();
    late final StreamSubscription sub;
    sub = _c.auth.onAuthStateChange.listen((data) {
      final u = data.session?.user;
      if (u != null && !completer.isCompleted) {
        completer.complete(_map(u)!);
        sub.cancel();
      }
    });
    await _c.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: SupabaseConfig.redirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    return completer.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        sub.cancel();
        throw Exception('Tempo esgotado aguardando o login com Google.');
      },
    );
  }

  @override
  Future<void> sair() async => _c.auth.signOut();
}
