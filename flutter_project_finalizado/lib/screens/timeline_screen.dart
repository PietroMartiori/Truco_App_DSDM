import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';

class TimelineScreen extends StatelessWidget {
  final Partida partida;
  const TimelineScreen({super.key, required this.partida});

  @override
  Widget build(BuildContext context) {
    final bool venceu = partida.vencedor == partida.timeA.nome;
    final dateStr = partida.dataInicio != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(partida.dataInicio!) 
        : '-';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (venceu ? AppColors.neonGreen : AppColors.redAlert).withOpacity(0.2),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      '${partida.timeA.nome} ${partida.timeA.pontos} × ${partida.timeB.pontos} ${partida.timeB.nome}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        venceu ? 'VOCÊS VENCERAM!' : 'ELES VENCERAM',
                        style: TextStyle(
                          color: venceu ? AppColors.neonGreen : AppColors.redAlert,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DETALHES DA PARTIDA', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Início', value: dateStr),
                  _InfoRow(label: 'Duração', value: _calcularDuracao()),
                  _InfoRow(label: 'Jogadores', value: '${partida.numJogadores}'),
                  _InfoRow(label: 'Meta', value: '${partida.metaPontos} pontos'),
                  const SizedBox(height: 32),
                  Text('LINHA DO TEMPO', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return _buildTimelineTile(
                    isFirst: true,
                    title: 'Partida Iniciada',
                    subtitle: 'O jogo começou!',
                    time: DateFormat('HH:mm').format(partida.dataInicio!),
                    icon: Icons.play_arrow,
                  );
                }
                
                final rodada = partida.rodadas[index - 1];
                return _buildTimelineTile(
                  title: rodada.descricao,
                  subtitle: 'Placar: ${rodada.pontosTimeA} × ${rodada.pontosTimeB}',
                  time: DateFormat('HH:mm').format(rodada.data),
                  icon: Icons.bolt,
                );
              },
              childCount: partida.rodadas.length + 1,
            ),
          ),
          if (partida.vencedor != null)
            SliverToBoxAdapter(
              child: _buildTimelineTile(
                isLast: true,
                title: 'Fim de Jogo',
                subtitle: '${partida.vencedor} venceu a partida!',
                time: partida.dataFim != null ? DateFormat('HH:mm').format(partida.dataFim!) : '',
                icon: Icons.emoji_events,
                color: AppColors.neonGreen,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  String _calcularDuracao() {
    if (partida.dataInicio == null || partida.dataFim == null) return '-';
    final diff = partida.dataFim!.difference(partida.dataInicio!);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    return '${diff.inHours}h ${diff.inMinutes % 60}min';
  }

  Widget _buildTimelineTile({
    bool isFirst = false,
    bool isLast = false,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    Color color = AppColors.border,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: const LineStyle(color: AppColors.border, thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: 32,
        height: 32,
        indicator: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: color == AppColors.border ? AppColors.border : color, width: 2),
          ),
          child: Icon(icon, size: 16, color: color == AppColors.border ? AppColors.textSecondary : color),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
