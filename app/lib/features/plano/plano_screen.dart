import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/plano_providers.dart';
import '../../core/app_drawer.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/models/modulo.dart';
import '../../domain/models/plano_dia.dart';

/// Mês exibido no calendário (primeiro dia do mês). null = usar o 1º mês do plano.
final mesAtivoProvider = StateProvider<DateTime?>((ref) => null);

class PlanoScreen extends ConsumerWidget {
  const PlanoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planoAsync = ref.watch(planoProvider);
    final modsAsync = ref.watch(modulosPorNomeProvider);

    return Scaffold(
      drawer: const AppDrawer(rotaAtual: '/plano'),
      appBar: AppBar(title: const Text('Plano')),
      body: planoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (plano) {
          if (plano.isEmpty) {
            return const Center(child: Text('Plano vazio.'));
          }
          final mods = modsAsync.asData?.value ?? const <String, Modulo>{};
          final porData = {for (final p in plano) Fmt.iso(p.data): p};

          final primeiroMes = DateTime(plano.first.data.year, plano.first.data.month);
          final ultimoMes = DateTime(plano.last.data.year, plano.last.data.month);

          var mes = ref.watch(mesAtivoProvider) ?? primeiroMes;
          if (mes.isBefore(primeiroMes)) mes = primeiroMes;
          if (mes.isAfter(ultimoMes)) mes = ultimoMes;

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              _NavMes(
                mes: mes,
                onAnterior: mes.isAfter(primeiroMes)
                    ? () => ref.read(mesAtivoProvider.notifier).state =
                        DateTime(mes.year, mes.month - 1)
                    : null,
                onProximo: mes.isBefore(ultimoMes)
                    ? () => ref.read(mesAtivoProvider.notifier).state =
                        DateTime(mes.year, mes.month + 1)
                    : null,
              ),
              const SizedBox(height: 8),
              const _CabecalhoSemana(),
              const SizedBox(height: 4),
              _GradeMes(
                mes: mes,
                porData: porData,
                mods: mods,
                onTapDia: (p) {
                  ref.read(dataSelecionadaProvider.notifier).state =
                      DateTime(p.data.year, p.data.month, p.data.day);
                  context.go('/hoje');
                },
              ),
              const SizedBox(height: 16),
              const _Legenda(),
            ],
          );
        },
      ),
    );
  }
}

class _NavMes extends StatelessWidget {
  final DateTime mes;
  final VoidCallback? onAnterior;
  final VoidCallback? onProximo;
  const _NavMes({required this.mes, this.onAnterior, this.onProximo});

  @override
  Widget build(BuildContext context) {
    final titulo = DateFormat('MMMM yyyy', 'pt_BR').format(mes);
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onAnterior,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            titulo[0].toUpperCase() + titulo.substring(1),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          onPressed: onProximo,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _CabecalhoSemana extends StatelessWidget {
  const _CabecalhoSemana();
  @override
  Widget build(BuildContext context) {
    const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final s = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final d in dias)
          Expanded(
            child: Center(
              child: Text(d,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: s.onSurfaceVariant)),
            ),
          ),
      ],
    );
  }
}

class _GradeMes extends StatelessWidget {
  final DateTime mes;
  final Map<String, PlanoDia> porData;
  final Map<String, Modulo> mods;
  final ValueChanged<PlanoDia> onTapDia;
  const _GradeMes({
    required this.mes,
    required this.porData,
    required this.mods,
    required this.onTapDia,
  });

  @override
  Widget build(BuildContext context) {
    final diasNoMes = DateTime(mes.year, mes.month + 1, 0).day;
    final offset = DateTime(mes.year, mes.month, 1).weekday - 1; // Seg=0..Dom=6

    final celulas = <Widget>[];
    for (var i = 0; i < offset; i++) {
      celulas.add(const SizedBox.shrink());
    }
    for (var dia = 1; dia <= diasNoMes; dia++) {
      final data = DateTime(mes.year, mes.month, dia);
      final p = porData[Fmt.iso(data)];
      celulas.add(_CelulaDia(dia: dia, plano: p, mods: mods, onTap: onTapDia));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.72,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: celulas,
    );
  }
}

class _CelulaDia extends StatelessWidget {
  final int dia;
  final PlanoDia? plano;
  final Map<String, Modulo> mods;
  final ValueChanged<PlanoDia> onTap;
  const _CelulaDia({
    required this.dia,
    required this.plano,
    required this.mods,
    required this.onTap,
  });

  List<String> _blocosDoDia() {
    if (plano == null || plano!.moduloDia.isEmpty) return const [];
    return plano!.moduloDia
        .split(' + ')
        .map((nome) => mods[nome]?.bloco ?? 'FORA')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    if (plano == null) {
      return Container(
        decoration: BoxDecoration(
          color: s.surfaceContainerHighest.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 6),
        child: Text('$dia',
            style: TextStyle(color: s.onSurfaceVariant.withOpacity(0.5))),
      );
    }
    final blocos = _blocosDoDia();
    final corPrincipal =
        blocos.isNotEmpty ? BlocoCores.de(blocos.first) : s.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTap(plano!),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: s.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 5, color: corPrincipal),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('$dia',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final b in blocos)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: BlocoCores.de(b),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda();
  @override
  Widget build(BuildContext context) {
    const blocos = ['P1', 'P2', 'P3', 'P4'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final b in blocos)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: BlocoCores.de(b),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('$b · ${BlocoCores.rotulo(b)}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
