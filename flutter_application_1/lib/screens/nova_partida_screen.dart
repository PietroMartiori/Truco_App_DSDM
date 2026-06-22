import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import 'placar_screen.dart';

class NovaPartidaScreen extends StatefulWidget {
  const NovaPartidaScreen({super.key});

  @override
  State<NovaPartidaScreen> createState() => _NovaPartidaScreenState();
}

class _NovaPartidaScreenState extends State<NovaPartidaScreen> {
  int jogadoresSelecionado = 4;
  final TextEditingController _timeAController = TextEditingController();
  final TextEditingController _timeBController = TextEditingController();

  void _iniciarPartida() {
    final partida = Partida(
      timeA: Time(
        nome: _timeAController.text.trim().isEmpty
            ? 'Nós'
            : _timeAController.text.trim(),
      ),
      timeB: Time(
        nome: _timeBController.text.trim().isEmpty
            ? 'Eles'
            : _timeBController.text.trim(),
      ),
      metaPontos: jogadoresSelecionado == 4 ? 12 : 18,
      numJogadores: jogadoresSelecionado,
      dataInicio: DateTime.now(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PlacarScreen(partida: partida)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header
              Text('nova partida',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 4),
              Text('configure antes de começar',
                  style: Theme.of(context).textTheme.bodyMedium),

              const SizedBox(height: 32),

              // Seleção de jogadores
              Text('JOGADORES',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _cardJogadores(4)),
                  const SizedBox(width: 12),
                  Expanded(child: _cardJogadores(6)),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey(jogadoresSelecionado),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreenDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jogadoresSelecionado == 4
                        ? 'meta: 12 pts  ·  muda para 18 com 6 jogadores'
                        : 'meta: 18 pts  ·  muda para 12 com 4 jogadores',
                    style: const TextStyle(
                        color: AppColors.neonGreen, fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Time A
              Text('TIME A', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _timeAController,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(hintText: 'Ex: Nós'),
              ),

              const SizedBox(height: 20),

              // Time B
              Text('TIME B', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _timeBController,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(hintText: 'Ex: Eles'),
              ),

              const SizedBox(height: 36),

              // Botão começar
              ElevatedButton(
                onPressed: _iniciarPartida,
                child: const Text('começar'),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'ao pressionar, o placar é zerado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardJogadores(int valor) {
    final selecionado = jogadoresSelecionado == valor;
    return GestureDetector(
      onTap: () => setState(() => jogadoresSelecionado = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.neonGreenDim : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? AppColors.neonGreen : AppColors.border,
            width: selecionado ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$valor',
              style: TextStyle(
                color: selecionado ? AppColors.neonGreen : AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'jogadores',
              style: TextStyle(
                color: selecionado
                    ? AppColors.neonGreen.withOpacity(0.7)
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}