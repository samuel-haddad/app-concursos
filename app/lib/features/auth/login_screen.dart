import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final s = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: s.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(Icons.school,
                      size: 44, color: s.onPrimaryContainer),
                ),
                const SizedBox(height: 20),
                Text('Estudo TCDF',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Seu plano de estudo para o concurso',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: s.onSurfaceVariant),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.tonalIcon(
                    onPressed: auth.carregando
                        ? null
                        : () =>
                            ref.read(authProvider.notifier).entrarComGoogle(),
                    icon: auth.carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const _GoogleG(),
                    label: Text(
                        auth.carregando ? 'Entrando…' : 'Entrar com Google'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Login de desenvolvimento. O OAuth real do Google será '
                  'ativado com o Supabase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: s.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "G" colorido simples do Google (evita depender de asset externo).
class _GoogleG extends StatelessWidget {
  const _GoogleG();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
