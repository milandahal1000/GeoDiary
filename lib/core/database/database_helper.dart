import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class to manage the local SQLite database.
class DatabaseHelper {
  DatabaseHelper._privateConstructor(this._databaseName);
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor(
    'geodiary.db',
  );

  factory DatabaseHelper.instance() => _instance;
  factory DatabaseHelper.testInstance({
    String databaseName = 'geodiary_test.db',
  }) => DatabaseHelper._privateConstructor(databaseName);

  final String _databaseName;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memories (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        visitDate INTEGER NOT NULL,
        photoPath TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Version 1 used INTEGER primary keys, while the app uses String ids.
      // Rebuild the table and preserve any existing rows.
      await db.execute('ALTER TABLE memories RENAME TO memories_v1');
      await _onCreate(db, newVersion);
      await db.execute('''
        INSERT INTO memories (
          id, title, description, visitDate, photoPath, latitude, longitude,
          address, createdAt, updatedAt
        )
        SELECT
          CAST(id AS TEXT), title, description, visitDate, photoPath, latitude,
          longitude, address, createdAt, updatedAt
        FROM memories_v1
      ''');
      await db.execute('DROP TABLE memories_v1');
    }
  }
}
