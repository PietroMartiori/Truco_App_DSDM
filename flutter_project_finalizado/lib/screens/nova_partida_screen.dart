import 'dart:io';
import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import 'placar_screen.dart';
import 'foto_screen.dart';

class NovaPartidaScreen extends StatefulWidget {
  const NovaPartidaScreen({super.key});

  @override
  State<NovaPartidaScreen> createState() => _NovaPartidaScreenState();
}

class _NovaPartidaScreenState extends State<NovaPartidaScreen> {
  int jogadoresSelecionado = 4;
  final TextEditingController _timeAController = TextEditingController();
  final TextEditingController _timeBController = TextEditingController();
  String? _fotoTimeA;
  String? _fotoTimeB;

  void _iniciarPartida() {
    final partida = Partida(
      timeA: Time(
        nome: _timeAController.text.trim().isEmpty ? 'Nós' : _timeAController.text.trim(),
        fotoPath: _fotoTimeA,
      ),
      timeB: Time(
        nome: _timeBController.text.trim().isEmpty ? 'Eles' : _timeBController.text.trim(),
        fotoPath: _fotoTimeB,
      ),
      metaPontos: jogadoresSelecionado == 4 ? 12 : 18,
      numJogadores: jogadoresSelecionado,
      dataInicio: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlacarScreen(partida: partida)),
    );
  }

  Future<void> _capturarFoto(bool isTimeA) async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FotoScreen(titulo: isTimeA ? 'foto time a' : 'foto time b'),
      ),
    );

    if (path != null) {
      setState(() {
        if (isTimeA) {
          _fotoTimeA = path;
        } else {
          _fotoTimeB = path;
        }
      });
    }
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
              Text('nova partida',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 4),
              Text('configure antes de começar',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              
              Text('JOGADORES', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _cardJogadores(4)),
                  const SizedBox(width: 12),
                  Expanded(child: _cardJogadores(6)),
                ],
              ),
              const SizedBox(height: 10),
              _MetaInfo(jogadores: jogadoresSelecionado),
              const SizedBox(height: 32),

              _InputTime(
                label: 'TIME A',
                controller: _timeAController,
                hint: 'Ex: Nós',
                fotoPath: _fotoTimeA,
                onFotoTap: () => _capturarFoto(true),
              ),
              const SizedBox(height: 24),
              _InputTime(
                label: 'TIME B',
                controller: _timeBController,
                hint: 'Ex: Eles',
                fotoPath: _fotoTimeB,
                onFotoTap: () => _capturarFoto(false),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _iniciarPartida,
                child: const Text('começar'),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'ao pressionar, o placar é zerado',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
            Text('$valor',
                style: TextStyle(
                  color: selecionado ? AppColors.neonGreen : AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                )),
            Text('jogadores',
                style: TextStyle(
                  color: selecionado ? AppColors.neonGreen.withOpacity(0.7) : AppColors.textSecondary,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final int jogadores;
  const _MetaInfo({required this.jogadores});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neonGreenDim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        jogadores == 4
            ? 'meta: 12 pts  ·  muda para 18 com 6 jogadores'
            : 'meta: 18 pts  ·  muda para 12 com 4 jogadores',
        style: const TextStyle(color: AppColors.neonGreen, fontSize: 12),
      ),
    );
  }
}

class _InputTime extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? fotoPath;
  final VoidCallback onFotoTap;

  const _InputTime({
    required this.label,
    required this.controller,
    required this.hint,
    this.fotoPath,
    required this.onFotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: onFotoTap,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: fotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(File(fotoPath!), fit: BoxFit.cover),
                      )
                    : const Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: hint),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
