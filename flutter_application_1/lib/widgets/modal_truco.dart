import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModalTruco extends StatelessWidget {
  const ModalTruco({super.key});

  @override
  Widget build(BuildContext context) {
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
            'o que o outro time decide?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _botaoResposta(
                  context,
                  label: 'Aceitar',
                  valor: 'aceitou',
                  cor: AppColors.neonGreen,
                  fundo: AppColors.neonGreenDim,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _botaoResposta(
                  context,
                  label: 'Recusar',
                  valor: 'recusou',
                  cor: AppColors.redAlert,
                  fundo: const Color(0xFF3D1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context, 'correu'),
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

  Widget _botaoResposta(
    BuildContext context, {
    required String label,
    required String valor,
    required Color cor,
    required Color fundo,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}