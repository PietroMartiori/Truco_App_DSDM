import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResultadoTruco {
  final String decisao;
  final int pontos;

  const ResultadoTruco({required this.decisao, required this.pontos});
}

class ModalTruco extends StatelessWidget {
  final int valorAtual;

  const ModalTruco({super.key, required this.valorAtual});

  List<int> get _opcoesPontuacao => const [3, 6, 9, 12];

  @override
  Widget build(BuildContext context) {
    final opcoesDisponiveis = _opcoesPontuacao
        .where((pontos) => pontos > valorAtual)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
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
                .map((pontos) => _botaoPontuacao(context, pontos: pontos))
                .toList(),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(
              context,
              ResultadoTruco(decisao: 'recusou', pontos: valorAtual),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF3D1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.redAlert.withValues(alpha: 0.4),
                ),
              ),
              child: const Center(
                child: Text(
                  'Recusar',
                  style: TextStyle(
                    color: AppColors.redAlert,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(
              context,
              ResultadoTruco(decisao: 'correu', pontos: valorAtual),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'Correr',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoPontuacao(BuildContext context, {required int pontos}) {
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
