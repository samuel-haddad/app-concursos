import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_providers.dart';
import '../application/theme_providers.dart';

class _Item {
  final String rota;
  final String titulo;
  final IconData icone;
  const _Item(this.rota, this.titulo, this.icone);
}

/// Alterna tema claro/escuro (ícone sol/lua).
class _ToggleTema extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escuro = ref.watch(themeModeProvider) == ThemeMode.dark;
    return SwitchListTile(
      value: escuro,
      onChanged: (_) => ref.read(themeModeProvider.notifier).alternar(),
      secondary: Icon(escuro ? Icons.dark_mode : Icons.light_mode),
      title: Text(escuro ? 'Tema escuro' : 'Tema claro'),
    );
  }
}

const _itens = <_Item>[
  _Item('/hoje', 'Hoje', Icons.today),
  _Item('/plano', 'Plano', Icons.calendar_month),
  _Item('/modulos', 'Módulos', Icons.menu_book),
  _Item('/controle', 'Controle', Icons.insights),
  _Item('/materiais', 'Materiais', Icons.folder_open),
  _Item('/backlog', 'Backlog', Icons.inbox),
  _Item('/concurso', 'Concurso', Icons.workspace_premium),
  _Item('/aluno', 'Aluno', Icons.person),
];

/// Menu lateral (hambúrguer) com acesso a todas as telas + usuário e logout.
class AppDrawer extends ConsumerWidget {
  final String rotaAtual;
  const AppDrawer({super.key, required this.rotaAtual});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: s.primaryContainer),
              currentAccountPicture: CircleAvatar(
                backgroundColor: s.primary,
                child: Text(
                  user?.iniciais ?? '?',
                  style: TextStyle(
                      color: s.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              accountName: Text(
                user?.nome ?? 'Visitante',
                style: TextStyle(color: s.onPrimaryContainer),
              ),
              accountEmail: Text(
                user?.email ?? '',
                style: TextStyle(color: s.onPrimaryContainer),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final it in _itens)
                    ListTile(
                      leading: Icon(it.icone),
                      title: Text(it.titulo),
                      selected: it.rota == rotaAtual,
                      selectedTileColor: s.secondaryContainer.withOpacity(0.4),
                      onTap: () {
                        Navigator.of(context).pop();
                        if (it.rota != rotaAtual) context.go(it.rota);
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            _ToggleTema(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authProvider.notifier).sair();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
