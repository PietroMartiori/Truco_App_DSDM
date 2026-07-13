import '../models/partida.dart';

/// Banco em memoria usado no navegador, onde sqflite nao esta disponivel.
/// Os dados duram apenas enquanto a pagina permanece aberta.
class DatabaseHelper {
  // Singleton: todas as telas compartilham a mesma colecao em memoria.
  /// Instancia unica acessada pelas telas com DatabaseHelper.instance.
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// Lista que simula a tabela de partidas enquanto o navegador esta aberto.
  final List<Partida> _partidas = [];
  /// Contador que simula a chave primaria auto-incremento do SQLite.
  int _proximoId = 1;

  DatabaseHelper._init();

  /// Insere uma partida nova ou substitui a existente com o mesmo id.
  Future<int> salvarPartida(Partida partida) async {
    // Reutiliza o id existente em update ou cria um novo em insert.
    final id = partida.id ?? _proximoId++;
    partida.id = id;

    // Procura a posicao para decidir entre atualizar e adicionar.
    final index = _partidas.indexWhere((p) => p.id == id);
    // Copia evita que alteracoes posteriores na tela mudem o "banco" sem salvar.
    final copia = _copiarPartida(partida);
    if (index >= 0) {
      _partidas[index] = copia;
    } else {
      _partidas.add(copia);
    }

    return id;
  }

  /// Devolve copias das partidas, da mais recente para a mais antiga.
  Future<List<Partida>> buscarPartidas() async {
    final partidas = _partidas.map(_copiarPartida).toList();
    // Data de seguranca para ordenar partidas que nao possuam inicio.
    final inicio = DateTime.fromMillisecondsSinceEpoch(0);
    partidas.sort((a, b) => (b.dataInicio ?? inicio).compareTo(a.dataInicio ?? inicio));
    return partidas;
  }

  /// Remove da lista a partida cujo id foi informado.
  Future<void> deletarPartida(int id) async {
    _partidas.removeWhere((partida) => partida.id == id);
  }

  /// Faz copia profunda da partida, inclusive da lista de rodadas e dos times.
  Partida _copiarPartida(Partida partida) => Partida(
      id: partida.id,
      timeA: Time(
        nome: partida.timeA.nome,
        pontos: partida.timeA.pontos,
        fotoPath: partida.timeA.fotoPath,
      ),
      timeB: Time(
        nome: partida.timeB.nome,
        pontos: partida.timeB.pontos,
        fotoPath: partida.timeB.fotoPath,
      ),
      metaPontos: partida.metaPontos,
      numJogadores: partida.numJogadores,
      rodadas: partida.rodadas
          .map(
            (rodada) => Rodada(
              descricao: rodada.descricao,
              pontosTimeA: rodada.pontosTimeA,
              pontosTimeB: rodada.pontosTimeB,
              data: rodada.data,
            ),
          )
          .toList(),
      dataInicio: partida.dataInicio,
      dataFim: partida.dataFim,
      vencedor: partida.vencedor,
    );
}
