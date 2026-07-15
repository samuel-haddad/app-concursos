import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_providers.dart';
import '../features/hoje/hoje_screen.dart';
import '../features/plano/plano_screen.dart';
import '../features/modulos/modulos_screen.dart';
import '../features/modulos/modulo_detalhe_screen.dart';
import '../features/controle/controle_screen.dart';
import '../features/concurso/concurso_screen.dart';
import '../features/aluno/aluno_screen.dart';
import '../features/backlog/backlog_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/placeholders.dart';

/// Router com autenticação: redireciona para /login quando não logado.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/hoje',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.carregando) return null;
      final emLogin = state.matchedLocation == '/login';
      if (!auth.logado) return emLogin ? null : '/login';
      if (emLogin) return '/hoje';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/hoje', builder: (_, __) => const HojeScreen()),
            // Telas secundárias (acessadas pelo menu lateral) ficam nesta
            // branch para preservar a barra de navegação inferior.
            GoRoute(path: '/backlog', builder: (_, __) => const BacklogScreen()),
            GoRoute(path: '/concurso', builder: (_, __) => const ConcursoScreen()),
            GoRoute(path: '/aluno', builder: (_, __) => const AlunoScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/plano', builder: (_, __) => const PlanoScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/modulos',
              builder: (_, __) => const ModulosScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => ModuloDetalheScreen(
                    moduloId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/controle',
                builder: (_, __) => const ControleScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/materiais',
                builder: (_, __) => const MateriaisScreen()),
          ]),
        ],
      ),
    ],
  );
});

/// Faz o GoRouter reavaliar o redirect quando o estado de auth muda.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    _sub = ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

class _AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Hoje'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Plano'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Módulos'),
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Controle'),
          NavigationDestination(
              icon: Icon(Icons.folder_open_outlined),
              selectedIcon: Icon(Icons.folder_open),
              label: 'Materiais'),
        ],
      ),
    );
  }
}
