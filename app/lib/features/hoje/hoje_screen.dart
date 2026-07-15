import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/plano_providers.dart';
import '../../core/app_drawer.dart';
import '../materiais/materiais_secao.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/models/plano_dia.dart';
import '../../domain/models/licao.dart';

class HojeScreen extends ConsumerStatefulWidget {
  const HojeScreen({super.key});

  @override
  ConsumerState<HojeScreen> createState() => _HojeScreenState();
}

class _HojeScreenState extends ConsumerState<HojeScreen> {
  DateTime? _sel; // dia selecionado (estado local — setState garante rebuild)

  DateTime _normalizar(DateTime d) => DateTime(d.year, d.month, d.day);

  void _mudar(DateTime nova) {
    final d = _normalizar(nova);
    setState(() => _sel = d);
    // mantém o provider sincronizado (para outras telas)
    ref.read(dataSelecionadaProvider.notifier).state = d;
  }

  @override
  Widget build(BuildContext context) {
    final planoAsync = ref.watch(planoProvider);
    final licoesAsync = ref.watch(licoesProvider);

    // Sincroniza quando a data é escolhida em outra tela (ex.: calendário do Plano).
    ref.listen<DateTime>(dataSelecionadaProvider, (_, next) {
      final n = _normalizar(next);
      if (_sel == null || !_mesmoDia(_sel!, n)) setState(() => _sel = n);
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
            onPressed: () => _mudar(DateTime.now()),
          ),
        ],
      ),
      body: planoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Erro(msg: '$e'),
        data: (plano) {
          if (plano.isEmpty) return const _Erro(msg: 'Plano vazio.');
          final licoes = licoesAsync.asData?.value ?? const <String, Licao>{};
          final primeiro = plano.first.data;
          final ultimo = plano.last.data;

          var sel = _sel ?? ref.read(dataSelecionadaProvider);
          sel = _normalizar(sel);
          if (sel.isBefore(primeiro)) sel = primeiro;
          if (sel.isAfter(ultimo)) sel = ultimo;

          final dia = plano.firstWhere(
            (p) => _mesmoDia(p.data, sel),
            orElse: () => plano.first,
          );

          return _Conteudo(
            dia: dia,
            licoes: licoes,
            primeiro: primeiro,
            ultimo: ultimo,
            onMudarDia: _mudar,
          );
        },
      ),
    );
  }

  Future<void> _abrirSeletor(List<PlanoDia>? plano) async {
    if (plano == null || plano.isEmpty) return;
    final primeiro = plano.first.data;
    final ultimo = plano.last.data;
    var inicial = _sel ?? DateTime.now();
    inicial = _normalizar(inicial);
    if (inicial.isBefore(primeiro)) inicial = primeiro;
    if (inicial.isAfter(ultimo)) inicial = ultimo;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primeiro,
      lastDate: ultimo,
      helpText: 'Escolha um dia do plano',
    );
    if (escolhida != null) _mudar(escolhida);
  }
}

bool _mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _Conteudo extends ConsumerWidget {
  final PlanoDia dia;
  final Map<String, Licao> licoes;
  final DateTime primeiro;
  final DateTime ultimo;
  final ValueChanged<DateTime> onMudarDia;

  const _Conteudo({
    required this.dia,
    required this.licoes,
    required this.primeiro,
    required this.ultimo,
    required this.onMudarDia,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessoesAsync = ref.watch(sessoesDoDiaProvider(dia.data));
    final podeVoltar = dia.data.isAfter(primeiro);
    final podeAvancar = dia.data.isBefore(ultimo);
    final faltam = dataProva.difference(dia.data).inDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _NavegacaoDia(
          dia: dia,
          faltamDias: faltam,
          onAnterior: podeVoltar
              ? () => onMudarDia(dia.data.subtract(const Duration(days: 1)))
              : null,
          onProximo: podeAvancar
              ? () => onMudarDia(dia.data.add(const Duration(days: 1)))
              : null,
        ),
        const SizedBox(height: 12),
        _ResumoDia(dia: dia),
        const SizedBox(height: 16),
        Text('Sessões do dia',
            style: Theme.of(context).textTheme.titleMedium),
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
                  _SessaoCard(
                    tipo: s.tipo,
                    minutos: s.minutos,
                    modulo: s.moduloRef,
                    licao: licoes[s.licaoRef],
                  ),
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
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('2 conteúdos'),
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

class _SessaoCard extends StatelessWidget {
  final String tipo;
  final int minutos;
  final String modulo;
  final Licao? licao;
  const _SessaoCard({
    required this.tipo,
    required this.minutos,
    required this.modulo,
    this.licao,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final cor = SessaoCores.de(tipo, s);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: cor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(SessaoCores.rotulo(tipo),
                            style: TextStyle(
                                color: cor, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(Fmt.minutos(minutos),
                            style: TextStyle(color: s.onSurfaceVariant)),
                      ],
                    ),
                    if (modulo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(modulo,
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
          child: Text('Erro ao carregar: $msg',
              textAlign: TextAlign.center),
        ),
      );
}
