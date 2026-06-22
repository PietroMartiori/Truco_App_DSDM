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
        metaPontos INTEGER NOT NULL,
        numJogadores INTEGER NOT NULL,
        dataInicio TEXT NOT NULL,
        dataFim TEXT,
        vencedor TEXT
      )
    ''');
  }

  Future<int> salvarPartida(Partida partida) async {
    final db = await database;
    if (partida.id != null) {
      await db.update(
        'partidas',
        partida.toMap(),
        where: 'id = ?',
        whereArgs: [partida.id],
      );
      return partida.id!;
    } else {
      return await db.insert('partidas', partida.toMap());
    }
  }

  Future<List<Partida>> buscarPartidas() async {
    final db = await database;
    final maps = await db.query(
      'partidas',
      orderBy: 'dataInicio DESC',
    );
    return maps.map((m) => Partida.fromMap(m)).toList();
  }

  Future<void> deletarPartida(int id) async {
    final db = await database;
    await db.delete('partidas', where: 'id = ?', whereArgs: [id]);
  }
}