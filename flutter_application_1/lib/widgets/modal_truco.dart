import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Valor devolvido ao placar quando o usuario decide o que fazer no truco.
class ResultadoTruco {
  /// Resultado textual usado pelo placar: aceitou, recusou ou correu.
  final String decisao;
  /// Valor que a rodada passa a valer.
  final int pontos;

  const ResultadoTruco({required this.decisao, required this.pontos});
}

/// Bottom sheet onde se escolhe aceitar, recusar ou correr do truco.
class ModalTruco extends StatelessWidget {
  /// Valor atual, usado para nao oferecer valores menores/iguais.
  final int valorAtual;

  const ModalTruco({super.key, required this.valorAtual});

  @override
  Widget build(BuildContext context) {
    // Mantem somente valores maiores que o valor atual da rodada.
    final opcoesDisponiveis = [3, 6, 9, 12].where((pontos) => pontos > valorAtual);

    // SafeArea evita sobreposicao com areas do sistema; Scroll permite telas pequenas.
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          // Cabecalho, opcoes de pontos e acoes de recusa da janela.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                tooltip: 'Fechar',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'TRUCO!',
            style: TextStyle(
              color: AppColors.amber,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'quanto vale a rodada?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: opcoesDisponiveis
                .map((pontos) => _botaoPontuacao(context, pontos))
                .toList(),
          ),
          const SizedBox(height: 24),
          _botaoAcao(context, 'Recusar', 'recusou', const Color(0xFF3D1A1A), AppColors.redAlert, AppColors.redAlert.withValues(alpha: 0.4), FontWeight.w700, 16),
          const SizedBox(height: 12),
          _botaoAcao(context, 'Correr', 'correu', AppColors.surfaceElevated, AppColors.textSecondary, AppColors.border, FontWeight.w600, null),
            ],
          ),
        ),
      ),
    );
  }

  /// Monta os botoes "Recusar" e "Correr" e retorna o resultado ao fechar.
  Widget _botaoAcao(BuildContext context, String texto, String decisao, Color fundo, Color cor, Color borda, FontWeight peso, double? tamanho) => GestureDetector(
        onTap: () => Navigator.pop(context, ResultadoTruco(decisao: decisao, pontos: valorAtual)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(12), border: Border.all(color: borda)),
          child: Center(child: Text(texto, style: TextStyle(color: cor, fontWeight: peso, fontSize: tamanho))),
        ),
      );

  /// Monta uma opcao de pontuacao; aceitar devolve os pontos selecionados.
  Widget _botaoPontuacao(BuildContext context, int pontos) {
    return GestureDetector(
      onTap: () => Navigator.pop(
        context,
        ResultadoTruco(decisao: 'aceitou', pontos: pontos),
      ),
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.neonGreenDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            '$pontos',
            style: const TextStyle(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
