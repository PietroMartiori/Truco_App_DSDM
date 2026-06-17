import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../models/rodada.dart';
import '../widgets/modal_truco.dart';

class PlacarScreen extends StatefulWidget {
  final Partida partida;

  const PlacarScreen({super.key, required this.partida});

  @override
  State<PlacarScreen> createState() => _PlacarScreenState();
}

class _PlacarScreenState extends State<PlacarScreen> {
  void _alterarPontoTimeA(int delta) {
    setState(() {
      widget.partida.timeA.pontos =
          (widget.partida.timeA.pontos + delta).clamp(0, widget.partida.metaPontos);
    });
  }

  void _alterarPontoTimeB(int delta) {
    setState(() {
      widget.partida.timeB.pontos =
          (widget.partida.timeB.pontos + delta).clamp(0, widget.partida.metaPontos);
    });
  }

  Future<void> _abrirModalTruco() async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ModalTruco(),
    );

    if (resultado != null) {
      setState(() {
        widget.partida.rodadas.add(
          Rodada(
            descricao: 'Truco: $resultado',
            pontosTimeA: widget.partida.timeA.pontos,
            pontosTimeB: widget.partida.timeB.pontos,
            data: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final partida = widget.partida;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Placar dos dois times lado a lado
              Row(
                children: [
                  Expanded(
                    child: _cardPlacar(
                      nome: partida.timeA.nome,
                      pontos: partida.timeA.pontos,
                      onMais: () => _alterarPontoTimeA(1),
                      onMenos: () => _alterarPontoTimeA(-1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _cardPlacar(
                      nome: partida.timeB.nome,
                      pontos: partida.timeB.pontos,
                      onMais: () => _alterarPontoTimeB(1),
                      onMenos: () => _alterarPontoTimeB(-1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Barra de progresso dupla
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: [
                      Expanded(
                        flex: partida.timeA.pontos == 0 ? 1 : partida.timeA.pontos,
                        child: Container(color: Colors.greenAccent),
                      ),
                      Expanded(
                        flex: partida.timeB.pontos == 0 ? 1 : partida.timeB.pontos,
                        child: Container(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botão TRUCO
              OutlinedButton(
                onPressed: _abrirModalTruco,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.amber, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
                child: const Text(
                  'TRUCO',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'HISTÓRICO',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: partida.rodadas.length,
                  itemBuilder: (context, index) {
                    final rodada = partida.rodadas[partida.rodadas.length - 1 - index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        rodada.descricao,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        '${rodada.pontosTimeA} x ${rodada.pontosTimeB}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: encerrar partida e ir para o histórico
                  },
                  child: const Text('encerrar partida'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardPlacar({
    required String nome,
    required int pontos,
    required VoidCallback onMais,
    required VoidCallback onMenos,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              nome,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '$pontos',
                key: ValueKey(pontos),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onMenos,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onMais,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}