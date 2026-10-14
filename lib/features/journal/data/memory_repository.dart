import 'package:geodiary/core/database/database_helper.dart';
import 'package:geodiary/features/journal/domain/memory.dart';
import 'package:sqflite/sqflite.dart';

/// Repository for accessing memory data from the SQLite database.
class MemoryRepository {
  final DatabaseHelper _dbHelper;

  MemoryRepository(this._dbHelper);

  factory MemoryRepository.instance() =>
      MemoryRepository(DatabaseHelper.instance());

  /// Insert a new memory into the database.
  Future<int> insertMemory(Memory memory) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'memories',
      memory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve a memory by its id.
  Future<Memory?> getMemory(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, Object?>> maps = await db.query(
      'memories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Memory.fromMap(maps.first);
  }

  /// Retrieve all memories, ordered by visitDate descending (newest first).
  Future<List<Memory>> getAllMemories() async {
    final db = await _dbHelper.database;
    final List<Map<String, Object?>> maps = await db.query(
      'memories',
      orderBy: 'visitDate DESC',
    );
    return List.generate(maps.length, (i) {
      return Memory.fromMap(maps[i]);
    });
  }

  /// Update an existing memory.
  Future<int> updateMemory(Memory memory) async {
    final db = await _dbHelper.database;
    return await db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  /// Delete a memory by its id.
  Future<int> deleteMemory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('memories', where: 'id = ?', whereArgs: [id]);
  }
}
