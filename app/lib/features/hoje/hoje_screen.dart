import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import '../../application/realizacao_providers.dart';
import '../../core/app_drawer.dart';
import '../materiais/materiais_secao.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/models/plano_dia.dart';
import '../../domain/models/licao.dart';
import '../../domain/models/sessao.dart';

class HojeScreen extends ConsumerStatefulWidget {
  const HojeScreen({super.key});

  @override
  ConsumerState<HojeScreen> createState() => _HojeScreenState();
}

class _HojeScreenState extends ConsumerState<HojeScreen> {
  // Índice do dia atual dentro da lista do plano (navegação por índice —
  // aritmética pura, o setState garante o rebuild).
  int? _idx;

  int _indiceHoje(List<PlanoDia> plano) {
    final h = DateTime.now();
    for (var i = 0; i < plano.length; i++) {
      final d = plano[i].data;
      if (d.year == h.year && d.month == h.month && d.day == h.day) return i;
    }
    return 0;
  }

  int? _indiceDaData(List<PlanoDia> plano, DateTime alvo) {
    for (var i = 0; i < plano.length; i++) {
      final d = plano[i].data;
      if (d.year == alvo.year && d.month == alvo.month && d.day == alvo.day) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final planoAsync = ref.watch(planoProvider);
    final licoesAsync = ref.watch(licoesProvider);

    // Dia escolhido em outra tela (calendário do Plano).
    ref.listen<DateTime>(dataSelecionadaProvider, (_, next) {
      final plano = ref.read(planoProvider).asData?.value;
      if (plano == null) return;
      final i = _indiceDaData(plano, next);
      if (i != null) setState(() => _idx = i);
    });

    return Scaffold(
      drawer: const AppDrawer(rotaAtual: '/hoje'),
      appBar: AppBar(
        title: const Text('Hoje'),
        actions: [
          IconButton(
            tooltip: 'Escolher data',
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _abrirSeletor(planoAsync.asData?.value),
          ),
          IconButton(
            tooltip: 'Ir para o dia atual',
            icon: const Icon(Icons.today),
            onPressed: () {
              final plano = planoAsync.asData?.value;
              if (plano != null) {
                setState(() => _idx = _indiceHoje(plano));
              }
            },
          ),
        ],
      ),
      body: planoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Erro(msg: '$e'),
        data: (plano) {
          if (plano.isEmpty) return const _Erro(msg: 'Plano vazio.');
          final licoes = licoesAsync.asData?.value ?? const <String, Licao>{};
          final idx =
              (_idx ?? _indiceHoje(plano)).clamp(0, plano.length - 1);
          final dia = plano[idx];

          return _Conteudo(
            dia: dia,
            licoes: licoes,
            onAnterior:
                idx > 0 ? () => setState(() => _idx = idx - 1) : null,
            onProximo: idx < plano.length - 1
                ? () => setState(() => _idx = idx + 1)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _abrirSeletor(List<PlanoDia>? plano) async {
    if (plano == null || plano.isEmpty) return;
    final idxAtual = (_idx ?? _indiceHoje(plano)).clamp(0, plano.length - 1);
    final escolhida = await showDatePicker(
      context: context,
      initialDate: plano[idxAtual].data,
      firstDate: plano.first.data,
      lastDate: plano.last.data,
      helpText: 'Escolha um dia do plano',
    );
    if (escolhida != null) {
      final i = _indiceDaData(plano, escolhida);
      if (i != null) setState(() => _idx = i);
    }
  }
}

class _Conteudo extends ConsumerWidget {
  final PlanoDia dia;
  final Map<String, Licao> licoes;
  final VoidCallback? onAnterior;
  final VoidCallback? onProximo;

  const _Conteudo({
    required this.dia,
    required this.licoes,
    this.onAnterior,
    this.onProximo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessoesAsync = ref.watch(sessoesDoDiaProvider(dia.data));
    final faltam = dataProva.difference(dia.data).inDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _NavegacaoDia(
          dia: dia,
          faltamDias: faltam,
          onAnterior: onAnterior,
          onProximo: onProximo,
        ),
        const SizedBox(height: 12),
        _ResumoDia(dia: dia),
        const SizedBox(height: 16),
        Text('Sessões do dia', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        sessoesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _Erro(msg: '$e'),
          data: (sessoes) {
            if (sessoes.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Sem sessões neste dia.'),
                ),
              );
            }
            return Column(
              children: [
                for (final s in sessoes)
                  _SessaoCard(sessao: s, licao: licoes[s.licaoRef]),
              ],
            );
          },
        ),
        MateriaisSecao(licaoId: dia.licaoPrincipal),
      ],
    );
  }
}

class _NavegacaoDia extends StatelessWidget {
  final PlanoDia dia;
  final int faltamDias;
  final VoidCallback? onAnterior;
  final VoidCallback? onProximo;
  const _NavegacaoDia({
    required this.dia,
    required this.faltamDias,
    this.onAnterior,
    this.onProximo,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onAnterior,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                Fmt.dataLonga(dia.data),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                faltamDias >= 0
                    ? 'Faltam $faltamDias dias para a prova'
                    : 'Após a prova',
                style: TextStyle(color: s.onSurfaceVariant, fontSize: 12),
              ),
            ],
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

class _ResumoDia extends StatelessWidget {
  final PlanoDia dia;
  const _ResumoDia({required this.dia});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 20, color: s.primary),
                const SizedBox(width: 8),
                Text('Tempo total: ${Fmt.minutos(dia.totalMin)}',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                if (dia.nConteudos >= 2)
                  const Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('2 conteúdos'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Conteúdo do dia',
                style: TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 2),
            Text(dia.moduloDia.isEmpty ? '—' : dia.moduloDia,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _SessaoCard extends ConsumerWidget {
  final Sessao sessao;
  final Licao? licao;
  const _SessaoCard({required this.sessao, this.licao});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = Theme.of(context).colorScheme;
    final cor = SessaoCores.de(sessao.tipo, s);
    final feitas = ref.watch(realizacaoProvider).valueOrNull ?? const <String>{};
    final feita = feitas.contains(sessao.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: cor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(SessaoCores.rotulo(sessao.tipo),
                            style: TextStyle(
                                color: cor, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(Fmt.minutos(sessao.minutos),
                            style: TextStyle(color: s.onSurfaceVariant)),
                      ],
                    ),
                    if (sessao.moduloRef.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(sessao.moduloRef,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    if (licao != null) ...[
                      const SizedBox(height: 2),
                      Text('Lição ${licao!.nLicao}: ${licao!.titulo}',
                          style: TextStyle(
                              color: s.onSurfaceVariant, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            Tooltip(
              message: feita ? 'Feito' : 'Marcar como feito',
              child: Checkbox(
                value: feita,
                onChanged: (_) =>
                    ref.read(realizacaoProvider.notifier).alternar(sessao),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Erro extends StatelessWidget {
  final String msg;
  const _Erro({required this.msg});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Erro ao carregar: $msg', textAlign: TextAlign.center),
        ),
      );
}
