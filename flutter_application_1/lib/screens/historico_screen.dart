import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/partida.dart';
import '../database/database.dart';
import '../theme/app_theme.dart';
import '../widgets/foto_preview.dart';
import 'timeline_screen.dart';
import 'nova_partida_screen.dart';

/// Tela inicial que consulta, filtra, abre e exclui partidas salvas.
class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

/// Estado com o Future da consulta e o texto usado como filtro.
class _HistoricoScreenState extends State<HistoricoScreen> {
  /// Promessa da lista lida no banco; FutureBuilder acompanha seu estado.
  late Future<List<Partida>> _partidasFuture;
  /// Texto normalizado usado para filtrar nomes na lista.
  String _filtro = '';

  /// Carrega a primeira lista sem setState, pois o widget ainda esta nascendo.
  @override
  void initState() {
    super.initState();
    _partidasFuture = DatabaseHelper.instance.buscarPartidas();
  }

  /// Pede uma nova consulta e redesenha os FutureBuilder da tela.
  void _carregarPartidas() {
    setState(() {
      _partidasFuture = DatabaseHelper.instance.buscarPartidas();
    });
  }

  /// Retorna se o nome de algum time contem o texto digitado pelo usuario.
  bool _correspondeAoFiltro(Partida partida) =>
      partida.timeA.nome.toLowerCase().contains(_filtro) ||
      partida.timeB.nome.toLowerCase().contains(_filtro);

  /// Exibe confirmacao; somente apos aceitar remove a partida do banco.
  Future<void> _confirmarExclusao(Partida partida) async {
    final id = partida.id;
    if (id == null) return;

    final excluir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('excluir partida?'),
        content: Text(
          '${partida.timeA.nome} vs ${partida.timeB.nome}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.redAlert),
            child: const Text('excluir'),
          ),
        ],
      ),
    );

    if (excluir != true) return;

    await DatabaseHelper.instance.deletarPartida(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('partida excluida do historico')),
    );
    _carregarPartidas();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold engloba o conteudo seguro e o botao flutuante da tela.
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
              ),              const SizedBox(height: 16),
              
              Expanded(
                child: FutureBuilder<List<Partida>>(
                  future: _partidasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
                    }
                    
                    final partidas = (snapshot.data ?? [])
                        .where(_correspondeAoFiltro)
                        .toList();

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
                          onDelete: () => _confirmarExclusao(partidas[index]),
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

/// Pequeno cartao reutilizavel para uma estatistica do historico.
class _StatChip extends StatelessWidget {
  /// Titulo pequeno da estatistica, por exemplo PARTIDAS.
  final String label, value;
  /// Cor que diferencia visualmente a estatistica.
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

/// Cartao clicavel com resumo de uma partida e acao de excluir.
class _PartidaCard extends StatelessWidget {
  /// Dados que este cartao resume.
  final Partida partida;
  /// Acao de abrir os detalhes ao tocar no cartao.
  final VoidCallback onTap;
  /// Acao de solicitar exclusao pelo icone de lixeira.
  final VoidCallback onDelete;
  const _PartidaCard({
    required this.partida,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final venceu = partida.vencedor == partida.timeA.nome;
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
                          Text(
                            '${partida.numJogadores} jogadores',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: onDelete,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.redAlert,
                                ),
                                iconSize: 18,
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Excluir partida',
                              ),
                            ],
                          ),
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
                              color: (venceu ? AppColors.neonGreen : AppColors.redAlert).withValues(alpha: 0.1),
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

/// Mostra avatar, nome e pontos de um time dentro de um cartao de partida.
class _TimeInfo extends StatelessWidget {
  /// Nome e pontuacao mostrados neste lado do cartao.
  final String nome;
  final int pontos;
  final String? foto;
  /// Quando true, inverte avatar/texto para o alinhamento do segundo time.
  final bool reverse;
  const _TimeInfo({required this.nome, required this.pontos, this.foto, this.reverse = false});

  @override
  Widget build(BuildContext context) {
    final widgets = [
      if (foto != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: fotoPreview(foto!, width: 24, height: 24, fit: BoxFit.cover),
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
