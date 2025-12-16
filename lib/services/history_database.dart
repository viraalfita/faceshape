import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/face_history.dart';

class HistoryDatabase {
  HistoryDatabase._();

  static final HistoryDatabase instance = HistoryDatabase._();
  static const _dbName = 'faceshape_history.db';
  static const _dbVersion = 1;
  static const _table = 'history';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            shape TEXT NOT NULL,
            image_path TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertHistory(FaceHistory history) async {
    final db = await database;
    return db.insert(_table, history.toMap());
  }

  Future<List<FaceHistory>> getHistories() async {
    final db = await database;
    final maps = await db.query(
      _table,
      orderBy: 'datetime(created_at) DESC',
    );
    return maps.map(FaceHistory.fromMap).toList();
  }

  Future<void> deleteHistory(int id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
