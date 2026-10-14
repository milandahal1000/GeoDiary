import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class to manage the SQLite database.
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
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // We'll implement migrations later if needed
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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

  // TODO: Implement onUpgrade for schema migrations when needed.
}
