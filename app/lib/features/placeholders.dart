import 'package:flutter/material.dart';

import '../core/app_drawer.dart';

/// Telas ainda não implementadas (fases seguintes do roadmap).
class EmBreveScreen extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final String descricao;
  final String? rota;
  const EmBreveScreen({
    super.key,
    required this.titulo,
    required this.icone,
    required this.descricao,
    this.rota,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: rota == null ? null : AppDrawer(rotaAtual: rota!),
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 56, color: s.primary),
              const SizedBox(height: 16),
              Text(titulo, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                descricao,
                textAlign: TextAlign.center,
                style: TextStyle(color: s.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Chip(label: const Text('Em breve')),
            ],
          ),
        ),
      ),
    );
  }
}

class MateriaisScreen extends StatelessWidget {
  const MateriaisScreen({super.key});
  @override
  Widget build(BuildContext context) => const EmBreveScreen(
        titulo: 'Materiais',
        icone: Icons.folder_open,
        descricao: 'PDFs, vídeos e áudios por módulo (Fase 3).',
        rota: '/materiais',
      );
}
