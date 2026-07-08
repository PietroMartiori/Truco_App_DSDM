import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/partida.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('truco.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
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

  Future<int> salvarPartida(Partida partida) async {
    final db = await database;
    int id;
    if (partida.id != null) {
      await db.update(
        'partidas',
        partida.toMap(),
        where: 'id = ?',
        whereArgs: [partida.id],
      );
      id = partida.id!;
    } else {
      id = await db.insert('partidas', partida.toMap());
    }

    // Salvar rodadas
    await db.delete('rodadas', where: 'partidaId = ?', whereArgs: [id]);
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

  Future<List<Partida>> buscarPartidas() async {
    final db = await database;
    final maps = await db.query(
      'partidas',
      orderBy: 'dataInicio DESC',
    );

    List<Partida> partidas = [];
    for (var map in maps) {
      Partida p = Partida.fromMap(map);
      final rodadasMap = await db.query(
        'rodadas',
        where: 'partidaId = ?',
        whereArgs: [p.id],
        orderBy: 'data ASC',
      );
      p.rodadas = rodadasMap
          .map((rm) => Rodada(
                descricao: rm['descricao'] as String,
                pontosTimeA: rm['pontosTimeA'] as int,
                pontosTimeB: rm['pontosTimeB'] as int,
                data: DateTime.parse(rm['data'] as String),
              ))
          .toList();
      partidas.add(p);
    }
    return partidas;
  }

  Future<void> deletarPartida(int id) async {
    final db = await database;
    await db.delete('rodadas', where: 'partidaId = ?', whereArgs: [id]);
    await db.delete('partidas', where: 'id = ?', whereArgs: [id]);
  }
}
