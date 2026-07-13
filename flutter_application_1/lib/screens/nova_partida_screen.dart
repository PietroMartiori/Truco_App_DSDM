import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';
import '../widgets/foto_preview.dart';
import 'placar_screen.dart';
import 'foto_screen.dart';

/// Formulario para configurar os times e iniciar uma nova partida.
class NovaPartidaScreen extends StatefulWidget {
  const NovaPartidaScreen({super.key});

  @override
  State<NovaPartidaScreen> createState() => _NovaPartidaScreenState();
}

/// Estado do formulario: jogadores, textos digitados e fotos dos times.
class _NovaPartidaScreenState extends State<NovaPartidaScreen> {
  /// Valor selecionado no cartao de 4 ou 6 jogadores.
  int jogadoresSelecionado = 4;
  /// Controladores usados para ler o texto digitado nos dois TextField.
  final _timeAController = TextEditingController();
  final _timeBController = TextEditingController();
  /// Caminhos/URLs devolvidos pela camera para cada time.
  String? _fotoTimeA;
  String? _fotoTimeB;

  /// Cria o modelo Partida com placar zero e navega para a tela de placar.
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

    // push mantem esta tela na pilha para que o usuario possa voltar.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlacarScreen(partida: partida)),
    );
  }

  /// Abre a camera e usa o callback recebido para salvar a foto do time certo.
  Future<void> _capturarFoto(String titulo, void Function(String) salvar) async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => FotoScreen(titulo: titulo)),
    );
    if (path != null) setState(() => salvar(path));
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold fornece a estrutura de pagina Material.
    // Conteudo rolavel impede overflow quando o teclado aparece.
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    tooltip: 'Voltar',
                  ),
                  const SizedBox(width: 4),
                  Text('nova partida',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          )),
                ],
              ),
              const SizedBox(height: 4),
              Text('configure antes de começar',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              
              // Selecao que tambem define a meta de pontos da partida.
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

              // Campos reutilizaveis para cada um dos dois times.
              _InputTime(
                label: 'TIME A',
                controller: _timeAController,
                hint: 'Ex: Nós',
                fotoPath: _fotoTimeA,
                onFotoTap: () => _capturarFoto('foto time a', (path) => _fotoTimeA = path),
              ),
              const SizedBox(height: 24),
              _InputTime(
                label: 'TIME B',
                controller: _timeBController,
                hint: 'Ex: Eles',
                fotoPath: _fotoTimeB,
                onFotoTap: () => _capturarFoto('foto time b', (path) => _fotoTimeB = path),
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

  /// Cartao clicavel que altera a quantidade de jogadores selecionada.
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
                  color: selecionado ? AppColors.neonGreen.withValues(alpha: 0.7) : AppColors.textSecondary,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }
}

/// Texto informativo que mostra a meta correspondente ao numero de jogadores.
class _MetaInfo extends StatelessWidget {
  /// Quantidade usada para decidir qual mensagem de meta sera exibida.
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

/// Campo composto: botao de foto e TextField para o nome de um time.
class _InputTime extends StatelessWidget {
  /// Rotulo acima do campo, como TIME A ou TIME B.
  final String label;
  /// Controlador que sincroniza o texto digitado com a tela pai.
  final TextEditingController controller;
  /// Exemplo de texto mostrado quando o campo esta vazio.
  final String hint;
  /// Foto opcional a ser mostrada no botao de camera.
  final String? fotoPath;
  /// Acao que pede a captura da foto ao widget pai.
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
                // Com foto, exibe preview; sem foto, exibe o icone de camera.
                child: fotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: fotoPreview(fotoPath!, fit: BoxFit.cover),
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
