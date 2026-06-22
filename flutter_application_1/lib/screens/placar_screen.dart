import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../widgets/modal_truco.dart';
import '../database/database.dart';

class PlacarScreen extends StatefulWidget {
  final Partida partida;
  const PlacarScreen({super.key, required this.partida});

  @override
  State<PlacarScreen> createState() => _PlacarScreenState();
}

class _PlacarScreenState extends State<PlacarScreen> {
  late Partida partida;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    partida = widget.partida;
    _salvar();
  }

  Future<void> _salvar() async {
    final id = await DatabaseHelper.instance.salvarPartida(partida);
    setState(() => partida.id = id);
  }

  void _alterarPonto(Time time, int delta) {
    setState(() => time.pontos = (time.pontos + delta).clamp(0, partida.metaPontos));
    DatabaseHelper.instance.salvarPartida(partida);
    if (time.pontos >= partida.metaPontos) _encerrar(time.nome);
  }

  Future<void> _abrirTruco() async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ModalTruco(),
    );
    if (resultado != null) {
      setState(() => partida.rodadas.add(Rodada(
        descricao: 'Truco → $resultado',
        pontosTimeA: partida.timeA.pontos,
        pontosTimeB: partida.timeB.pontos,
        data: DateTime.now(),
      )));
    }
  }

  Future<void> _encerrar(String vencedor) async {
    setState(() => _salvando = true);
    partida.vencedor = vencedor;
    partida.dataFim = DateTime.now();
    await DatabaseHelper.instance.salvarPartida(partida);
    setState(() => _salvando = false);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Partida encerrada!', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('$vencedor venceu!', style: const TextStyle(color: AppColors.neonGreen, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Nova partida', style: TextStyle(color: AppColors.neonGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(partida: partida, salvando: _salvando),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _CardTime(time: partida.timeA, cor: AppColors.neonGreen, onMais: () => _alterarPonto(partida.timeA, 1), onMenos: () => _alterarPonto(partida.timeA, -1))),
                const SizedBox(width: 12),
                Expanded(child: _CardTime(time: partida.timeB, cor: AppColors.redAlert, onMais: () => _alterarPonto(partida.timeB, 1), onMenos: () => _alterarPonto(partida.timeB, -1))),
              ]),
              const SizedBox(height: 16),
              _BarraProgresso(partida: partida),
              const SizedBox(height: 28),
              Center(child: _BotaoTruco(onTap: _abrirTruco)),
              const SizedBox(height: 28),
              Text('RODADAS', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              Expanded(child: _ListaRodadas(rodadas: partida.rodadas)),
              const SizedBox(height: 12),
              _BotaoEncerrar(onTap: () {
                final lider = partida.timeA.pontos >= partida.timeB.pontos
                    ? partida.timeA.nome
                    : partida.timeB.nome;
                _encerrar(lider);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

//Widgets privados

class _Header extends StatelessWidget {
  final Partida partida;
  final bool salvando;
  const _Header({required this.partida, required this.salvando});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('placar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
          Text('${partida.timeA.nome}  ×  ${partida.timeB.nome}', style: Theme.of(context).textTheme.bodyMedium),
        ]),
        if (salvando)
          const SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonGreen)),
      ],
    );
  }
}

class _CardTime extends StatelessWidget {
  final Time time;
  final Color cor;
  final VoidCallback onMais, onMenos;
  const _CardTime({required this.time, required this.cor, required this.onMais, required this.onMenos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(time.nome, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Text('${time.pontos}', key: ValueKey(time.pontos),
            style: TextStyle(color: cor, fontSize: 52, fontWeight: FontWeight.w800, letterSpacing: -2)),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _BotaoPonto(icon: Icons.remove, cor: AppColors.textSecondary, fundo: AppColors.surfaceElevated, onTap: onMenos),
          const SizedBox(width: 12),
          _BotaoPonto(icon: Icons.add, cor: Colors.black, fundo: cor, onTap: onMais),
        ]),
      ]),
    );
  }
}

class _BotaoPonto extends StatelessWidget {
  final IconData icon;
  final Color cor, fundo;
  final VoidCallback onTap;
  const _BotaoPonto({required this.icon, required this.cor, required this.fundo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: cor, size: 20),
      ),
    );
  }
}

class _BarraProgresso extends StatelessWidget {
  final Partida partida;
  const _BarraProgresso({required this.partida});

  @override
  Widget build(BuildContext context) {
    final ptsA = partida.timeA.pontos;
    final ptsB = partida.timeB.pontos;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$ptsA pts', style: const TextStyle(color: AppColors.neonGreen, fontSize: 12)),
        Text('meta: ${partida.metaPontos}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        Text('$ptsB pts', style: const TextStyle(color: AppColors.redAlert, fontSize: 12)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(height: 10, child: Row(children: [
          Expanded(flex: ptsA == 0 ? 1 : ptsA, child: Container(color: AppColors.neonGreen)),
          Container(width: 2, color: AppColors.background),
          Expanded(flex: ptsB == 0 ? 1 : ptsB, child: Container(color: AppColors.redAlert)),
        ])),
      ),
    ]);
  }
}

class _BotaoTruco extends StatelessWidget {
  final VoidCallback onTap;
  const _BotaoTruco({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2000),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.amber.withOpacity(0.6), width: 1.5),
        ),
        child: const Text('TRUCO', style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 3)),
      ),
    );
  }
}

class _ListaRodadas extends StatelessWidget {
  final List<Rodada> rodadas;
  const _ListaRodadas({required this.rodadas});

  @override
  Widget build(BuildContext context) {
    if (rodadas.isEmpty) {
      return Center(child: Text('nenhuma rodada ainda', style: Theme.of(context).textTheme.bodyMedium));
    }
    return ListView.builder(
      itemCount: rodadas.length,
      itemBuilder: (_, i) {
        final r = rodadas[rodadas.length - 1 - i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r.descricao, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              Text('${r.pontosTimeA} × ${r.pontosTimeB}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ),
        );
      },
    );
  }
}

class _BotaoEncerrar extends StatelessWidget {
  final VoidCallback onTap;
  const _BotaoEncerrar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('encerrar partida', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}