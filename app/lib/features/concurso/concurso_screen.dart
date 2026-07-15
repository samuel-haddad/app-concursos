import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/plano_providers.dart';
import '../../core/app_drawer.dart';
import '../../core/format.dart';
import '../../domain/models/concurso.dart';

class ConcursoScreen extends ConsumerWidget {
  const ConcursoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(concursoProvider);
    return Scaffold(
      drawer: const AppDrawer(rotaAtual: '/concurso'),
      appBar: AppBar(title: const Text('Concurso')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (c) => _Conteudo(concurso: c),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final Concurso concurso;
  const _Conteudo({required this.concurso});

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final hoje = DateTime.now();
    final faltam =
        concurso.dataProva.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _CardContagem(dataProva: concurso.dataProva, faltam: faltam),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Linha(rotulo: 'Órgão', valor: concurso.orgao),
                _Linha(rotulo: 'Banca', valor: concurso.banca),
                _Linha(rotulo: 'Cargo', valor: concurso.cargo),
                _Linha(rotulo: 'Vagas', valor: concurso.vagas),
                _Linha(rotulo: 'Escolaridade', valor: concurso.escolaridade),
                _Linha(rotulo: 'Salário', valor: moeda.format(concurso.salario)),
                _Linha(
                  rotulo: 'Inscrições',
                  valor:
                      '${Fmt.dataCurta(concurso.inscricaoIni)} a ${Fmt.dataCurta(concurso.inscricaoFim)}',
                ),
                _Linha(rotulo: 'Taxa', valor: moeda.format(concurso.taxa)),
                _Linha(
                  rotulo: 'Provas (objetivas e discursiva)',
                  valor: Fmt.dataCurta(concurso.dataProva),
                  ultimo: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CardContagem extends StatelessWidget {
  final DateTime dataProva;
  final int faltam;
  const _CardContagem({required this.dataProva, required this.faltam});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Card(
      color: s.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.event, size: 40, color: s.onPrimaryContainer),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faltam >= 0 ? '$faltam dias' : 'Prova realizada',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: s.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text('para a prova · ${Fmt.dataCurta(dataProva)}',
                    style: TextStyle(color: s.onPrimaryContainer)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool ultimo;
  const _Linha({required this.rotulo, required this.valor, this.ultimo = false});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(rotulo,
                    style: TextStyle(color: s.onSurfaceVariant, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(valor,
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ),
        if (!ultimo) Divider(height: 1, color: s.outlineVariant),
      ],
    );
  }
}
