import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/partida.dart';
import '../database/database.dart';
import '../theme/app_theme.dart';
import 'timeline_screen.dart';
import 'nova_partida_screen.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  late Future<List<Partida>> _partidasFuture;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _carregarPartidas();
  }

  void _carregarPartidas() {
    setState(() {
      _partidasFuture = DatabaseHelper.instance.buscarPartidas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('histórico',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              
              // Estatísticas Rápidas
              FutureBuilder<List<Partida>>(
                future: _partidasFuture,
                builder: (context, snapshot) {
                  int total = snapshot.data?.length ?? 0;
                  int vitorias = snapshot.data?.where((p) => p.vencedor == p.timeA.nome).length ?? 0;
                  int derrotas = total - vitorias;

                  return Row(
                    children: [
                      _StatChip(label: 'PARTIDAS', value: '$total', color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      _StatChip(label: 'VITÓRIAS', value: '$vitorias', color: AppColors.neonGreen),
                      const SizedBox(width: 8),
                      _StatChip(label: 'DERROTAS', value: '$derrotas', color: AppColors.redAlert),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 20),
              TextField(
                onChanged: (v) => setState(() => _filtro = v.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'buscar partidas...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: FutureBuilder<List<Partida>>(
                  future: _partidasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
                    }
                    
                    final partidas = snapshot.data?.where((p) => 
                      p.timeA.nome.toLowerCase().contains(_filtro) || 
                      p.timeB.nome.toLowerCase().contains(_filtro)
                    ).toList() ?? [];

                    if (partidas.isEmpty) {
                      return Center(child: Text('nenhuma partida encontrada', style: Theme.of(context).textTheme.bodyMedium));
                    }

                    return ListView.builder(
                      itemCount: partidas.length,
                      itemBuilder: (context, index) {
                        return _PartidaCard(
                          partida: partidas[index],
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TimelineScreen(partida: partidas[index])),
                            );
                            _carregarPartidas();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const NovaPartidaScreen()));
          _carregarPartidas();
        },
        backgroundColor: AppColors.neonGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _PartidaCard extends StatelessWidget {
  final Partida partida;
  final VoidCallback onTap;
  const _PartidaCard({required this.partida, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool venceu = partida.vencedor == partida.timeA.nome;
    final dateStr = partida.dataInicio != null ? DateFormat('dd/MM/yyyy').format(partida.dataInicio!) : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: venceu ? AppColors.neonGreen : AppColors.redAlert,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${partida.numJogadores} jogadores', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TimeInfo(nome: partida.timeA.nome, pontos: partida.timeA.pontos, foto: partida.timeA.fotoPath),
                          const Text('vs', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          _TimeInfo(nome: partida.timeB.nome, pontos: partida.timeB.pontos, foto: partida.timeB.fotoPath, reverse: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (venceu ? AppColors.neonGreen : AppColors.redAlert).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              venceu ? 'vitória' : 'derrota',
                              style: TextStyle(color: venceu ? AppColors.neonGreen : AppColors.redAlert, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final String nome;
  final int pontos;
  final String? foto;
  final bool reverse;
  const _TimeInfo({required this.nome, required this.pontos, this.foto, this.reverse = false});

  @override
  Widget build(BuildContext context) {
    final widgets = [
      if (foto != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(File(foto!), width: 24, height: 24, fit: BoxFit.cover),
        )
      else
        const Icon(Icons.person, color: AppColors.textMuted, size: 24),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(nome, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          Text('$pontos pts', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    ];

    return Row(children: reverse ? widgets.reversed.toList() : widgets);
  }
}
