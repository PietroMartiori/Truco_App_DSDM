import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../widgets/modal_truco.dart';
import '../database/database.dart';
import '../widgets/foto_preview.dart';

/// Tela principal do jogo: altera placar, registra rodadas e encerra partida.
class PlacarScreen extends StatefulWidget {
  /// Modelo recebido da tela de configuracao e atualizado durante o jogo.
  final Partida partida;
  const PlacarScreen({super.key, required this.partida});

  @override
  State<PlacarScreen> createState() => _PlacarScreenState();
}

/// Estado que guarda a partida em andamento, o valor do truco e salvamento.
class _PlacarScreenState extends State<PlacarScreen> {
  /// Copia de trabalho da partida que sera persistida no banco.
  late Partida partida;
  /// Controla a exibicao do indicador de salvamento no cabecalho.
  bool _salvando = false;
  /// Quantos pontos o proximo toque no botao + vai adicionar.
  int _valorRodada = 1;

  /// Recebe a partida criada na tela anterior e a salva pela primeira vez.
  @override
  void initState() {
    // Inicializa a infraestrutura do State antes de acessar widget.
    super.initState();
    partida = widget.partida;
    _salvar();
  }

  /// Persiste a partida e atualiza seu id gerado pelo banco.
  Future<void> _salvar() async {
    final id = await DatabaseHelper.instance.salvarPartida(partida);
    if (!mounted) return;
    setState(() => partida.id = id);
  }

  /// Soma ou subtrai pontos respeitando minimo zero e a meta da partida.
  void _alterarPonto(Time time, int delta) {
    setState(
      () =>
          time.pontos = (time.pontos + delta).clamp(0, partida.metaPontos).toInt(),
    );
    DatabaseHelper.instance.salvarPartida(partida);
    if (time.pontos >= partida.metaPontos) _encerrar(time.nome);
  }

  /// Aplica o valor atual da rodada e volta o valor padrao para 1.
  void _pontuar(Time time) {
    _alterarPonto(time, _valorRodada);
    setState(() => _valorRodada = 1);
  }

  /// Abre o modal de truco e registra a decisao devolvida por ele.
  Future<void> _abrirTruco() async {
    final resultado = await showModalBottomSheet<ResultadoTruco>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ModalTruco(valorAtual: _valorRodada),
    );
    if (resultado == null) return;

    setState(() {
      if (resultado.decisao == 'aceitou') _valorRodada = resultado.pontos;
      partida.rodadas.add(Rodada(
        descricao: 'Truco ${resultado.pontos} pts - ${resultado.decisao}',
        pontosTimeA: partida.timeA.pontos,
        pontosTimeB: partida.timeB.pontos,
        data: DateTime.now(),
      ));
    });
    DatabaseHelper.instance.salvarPartida(partida);
  }

  /// Marca data e vencedor, salva e mostra dialogo final sem poder dispensar.
  Future<void> _encerrar(String vencedor) async {
    setState(() => _salvando = true);
    partida.vencedor = vencedor;
    partida.dataFim = DateTime.now();
    await DatabaseHelper.instance.salvarPartida(partida);
    if (!mounted) return;
    setState(() => _salvando = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Partida encerrada!',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '$vencedor venceu!',
          style: const TextStyle(color: AppColors.neonGreen, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Nova partida',
              style: TextStyle(color: AppColors.neonGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // constraints informa espaco disponivel para adaptar retrato/paisagem.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final listHeight = isLandscape
                ? (constraints.maxHeight - 160).clamp(110.0, 260.0).toDouble()
                : (constraints.maxHeight * 0.24).clamp(120.0, 220.0).toDouble();

            final cards = Row(
              children: [
                Expanded(
                  child: _CardTime(
                    time: partida.timeA,
                    cor: AppColors.neonGreen,
                    foto: partida.timeA.fotoPath,
                    onMais: () => _pontuar(partida.timeA),
                    onMenos: () => _alterarPonto(partida.timeA, -1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CardTime(
                    time: partida.timeB,
                    cor: AppColors.redAlert,
                    foto: partida.timeB.fotoPath,
                    onMais: () => _pontuar(partida.timeB),
                    onMenos: () => _alterarPonto(partida.timeB, -1),
                  ),
                ),
              ],
            );

            final truco = Center(
              child: _BotaoTruco(valorRodada: _valorRodada, onTap: _abrirTruco),
            );

            final encerrar = _BotaoEncerrar(
              onTap: () {
                final lider = partida.timeA.pontos >= partida.timeB.pontos
                    ? partida.timeA.nome
                    : partida.timeB.nome;
                _encerrar(lider);
              },
            );

            final rodadas = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RODADAS', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: listHeight,
                  child: _ListaRodadas(rodadas: partida.rodadas),
                ),
              ],
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(0.0, double.infinity),
                ),
                child: isLandscape
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(partida: partida, salvando: _salvando),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    cards,
                                    const SizedBox(height: 12),
                                    _BarraProgresso(partida: partida),
                                    const SizedBox(height: 16),
                                    truco,
                                    const SizedBox(height: 16),
                                    encerrar,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(width: 320, child: rodadas),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(partida: partida, salvando: _salvando),
                          const SizedBox(height: 24),
                          cards,
                          const SizedBox(height: 16),
                          _BarraProgresso(partida: partida),
                          const SizedBox(height: 28),
                          truco,
                          const SizedBox(height: 28),
                          rodadas,
                          const SizedBox(height: 12),
                          encerrar,
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//Widgets privados

/// Cabecalho com botao de voltar, titulo e indicador de salvamento.
class _Header extends StatelessWidget {
  /// Dados usados para formar o titulo e a meta no cabecalho.
  final Partida partida;
  /// Define se o indicador visual de salvamento deve aparecer.
  final bool salvando;
  const _Header({required this.partida, required this.salvando});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'placar',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
            Text(
              '${partida.timeA.nome}  ×  ${partida.timeB.nome}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (salvando)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.neonGreen,
            ),
          ),
      ],
    );
  }
}

/// Cartao de um time: foto, nome, pontos e botoes de mais/menos.
class _CardTime extends StatelessWidget {
  /// Time representado pelo cartao.
  final Time time;
  /// Cor de destaque exclusiva deste lado do placar.
  final Color cor;
  /// Caminho/URL opcional da imagem de perfil.
  final String? foto;
  /// Callbacks que a tela pai executa para somar e subtrair pontos.
  final VoidCallback onMais, onMenos;
  const _CardTime({
    required this.time,
    required this.cor,
    this.foto,
    required this.onMais,
    required this.onMenos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (foto != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: fotoPreview(
                  foto!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Text(
            time.nome,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '${time.pontos}',
              key: ValueKey(time.pontos),
              style: TextStyle(
                color: cor,
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BotaoPonto(
                icon: Icons.remove,
                cor: AppColors.textSecondary,
                fundo: AppColors.surfaceElevated,
                onTap: onMenos,
              ),
              const SizedBox(width: 12),
              _BotaoPonto(
                icon: Icons.add,
                cor: Colors.black,
                fundo: cor,
                onTap: onMais,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botao circular reutilizavel para aumentar ou reduzir pontuacao.
class _BotaoPonto extends StatelessWidget {
  /// Simbolo (+ ou -) desenhado no centro do botao.
  final IconData icon;
  /// Cores do icone/borda e do fundo do botao.
  final Color cor, fundo;
  /// Acao recebida do cartao de time.
  final VoidCallback onTap;
  const _BotaoPonto({
    required this.icon,
    required this.cor,
    required this.fundo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cor, size: 20),
      ),
    );
  }
}

/// Compara visualmente o progresso de cada time ate a meta de pontos.
class _BarraProgresso extends StatelessWidget {
  /// Partida da qual sao lidos os pontos e a meta.
  final Partida partida;
  const _BarraProgresso({required this.partida});

  @override
  Widget build(BuildContext context) {
    final ptsA = partida.timeA.pontos;
    final ptsB = partida.timeB.pontos;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$ptsA pts',
              style: const TextStyle(color: AppColors.neonGreen, fontSize: 12),
            ),
            Text(
              'meta: ${partida.metaPontos}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            Text(
              '$ptsB pts',
              style: const TextStyle(color: AppColors.redAlert, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(
                  flex: ptsA == 0 ? 1 : ptsA,
                  child: Container(color: AppColors.neonGreen),
                ),
                Container(width: 2, color: AppColors.background),
                Expanded(
                  flex: ptsB == 0 ? 1 : ptsB,
                  child: Container(color: AppColors.redAlert),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Botao que abre a escolha do valor da rodada de truco.
class _BotaoTruco extends StatelessWidget {
  /// Valor que aparece no rotulo do botao.
  final int valorRodada;
  /// Abre o modal no widget pai.
  final VoidCallback onTap;
  const _BotaoTruco({required this.valorRodada, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2000),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.amber.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Text(
          valorRodada == 1 ? 'TRUCO' : 'TRUCO $valorRodada',
          style: const TextStyle(
            color: AppColors.amber,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}

/// Lista as rodadas em ordem inversa, deixando a mais nova no topo.
class _ListaRodadas extends StatelessWidget {
  /// Eventos que devem aparecer no historico da partida atual.
  final List<Rodada> rodadas;
  const _ListaRodadas({required this.rodadas});

  @override
  Widget build(BuildContext context) {
    if (rodadas.isEmpty) {
      return Center(
        child: Text(
          'nenhuma rodada ainda',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      itemCount: rodadas.length,
      itemBuilder: (_, i) {
        final r = rodadas[rodadas.length - 1 - i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r.descricao,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${r.pontosTimeA} × ${r.pontosTimeB}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Botao para encerrar manualmente a partida com o lider como vencedor.
class _BotaoEncerrar extends StatelessWidget {
  /// Callback que encerra a partida no estado pai.
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'encerrar partida',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
