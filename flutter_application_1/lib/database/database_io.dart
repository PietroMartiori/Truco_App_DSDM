import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/partida.dart';

/// Camada de acesso ao SQLite usada nas plataformas nativas.
class DatabaseHelper {
  // Singleton e cache da conexao evitam abrir varios bancos ao mesmo tempo.
  /// Instancia unica compartilhada por toda a aplicacao.
  static final DatabaseHelper instance = DatabaseHelper._init();
  /// Referencia em cache ao banco aberto.
  static Database? _database;

  DatabaseHelper._init();

  /// Entrega o banco ja aberto ou o cria na primeira chamada.
  Future<Database> get database async {
    return _database ??= await _initDB('truco.db');
  }

  /// Descobre o diretorio local e abre o arquivo SQLite informado.
  Future<Database> _initDB(String fileName) async {
    // Aguarda o diretorio recomendado pelo sistema operacional.
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    // Define versao e callback que so roda quando o arquivo e criado.
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Cria as tabelas na primeira execucao do aplicativo.
  Future _createDB(Database db, int version) async {
    // Uma linha por partida; guarda placar, nomes, fotos e resultado.
    // Uma linha por rodada; partidaId cria o vinculo com a partida pai.
    await db.execute('''
      CREATE TABLE partidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeTimeA TEXT NOT NULL,
        nomeTimeB TEXT NOT NULL,
        pontosTimeA INTEGER NOT NULL,
        pontosTimeB INTEGER NOT NULL,
        fotoTimeA TEXT,
        fotoTimeB TEXT,
        metaPontos INTEGER NOT NULL,
        numJogadores INTEGER NOT NULL,
        dataInicio TEXT NOT NULL,
        dataFim TEXT,
        vencedor TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE rodadas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partidaId INTEGER NOT NULL,
        descricao TEXT NOT NULL,
        pontosTimeA INTEGER NOT NULL,
        pontosTimeB INTEGER NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (partidaId) REFERENCES partidas (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Insere ou atualiza a partida e regrava suas rodadas no banco.
  Future<int> salvarPartida(Partida partida) async {
    // Aguarda a conexao antes de executar qualquer operacao SQL.
    final db = await database;
    final id = partida.id ?? await db.insert('partidas', partida.toMap());
    // Se ja havia id, a partida ja existe e deve ser atualizada.
    if (partida.id != null) {
      await db.update(
        'partidas',
        partida.toMap(),
        where: 'id = ?',
        whereArgs: [partida.id],
      );
    }

    // Remove as rodadas antigas para salvar a lista atual como fonte da verdade.
    await db.delete('rodadas', where: 'partidaId = ?', whereArgs: [id]);
    // Insere uma linha para cada objeto Rodada da lista em memoria.
    for (var rodada in partida.rodadas) {
      await db.insert('rodadas', {
        'partidaId': id,
        'descricao': rodada.descricao,
        'pontosTimeA': rodada.pontosTimeA,
        'pontosTimeB': rodada.pontosTimeB,
        'data': rodada.data.toIso8601String(),
      });
    }
    return id;
  }

  /// Le partidas por data e, para cada uma, carrega suas rodadas relacionadas.
  Future<List<Partida>> buscarPartidas() async {
    final db = await database;
    // Consulta a tabela ja ordenando as partidas mais recentes primeiro.
    final maps = await db.query(
      'partidas',
      orderBy: 'dataInicio DESC',
    );

    final partidas = <Partida>[];
    // Para cada linha de partida, busca as linhas filhas de rodadas.
    for (var map in maps) {
      final partida = Partida.fromMap(map);
      final rodadasMap = await db.query(
        'rodadas',
        where: 'partidaId = ?',
        whereArgs: [partida.id],
        orderBy: 'data ASC',
      );
      partida.rodadas = rodadasMap
          .map((rm) => Rodada(
                descricao: rm['descricao'] as String,
                pontosTimeA: rm['pontosTimeA'] as int,
                pontosTimeB: rm['pontosTimeB'] as int,
                data: DateTime.parse(rm['data'] as String),
              ))
          .toList();
      partidas.add(partida);
    }
    return partidas;
  }

  /// Exclui primeiro as rodadas e depois a partida selecionada.
  Future<void> deletarPartida(int id) async {
    final db = await database;
    await db.delete('rodadas', where: 'partidaId = ?', whereArgs: [id]);
    await db.delete('partidas', where: 'id = ?', whereArgs: [id]);
  }
}
