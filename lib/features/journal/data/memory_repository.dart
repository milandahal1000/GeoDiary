import 'package:geodiary/core/database/database_helper.dart';
import 'package:geodiary/features/journal/domain/memory.dart';
import 'package:sqflite/sqflite.dart';

/// Repository for accessing memory data from the local SQLite database.
class MemoryRepository {
  final DatabaseHelper _dbHelper;

  MemoryRepository(this._dbHelper);

  factory MemoryRepository.instance() =>
      MemoryRepository(DatabaseHelper.instance());

  /// Insert a new memory into the database.
  Future<String> insertMemory(Memory memory) async {
    final db = await _dbHelper.database;
    final String id =
        memory.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final memoryToStore = memory.copyWith(id: id);
    await db.insert(
      'memories',
      memoryToStore.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  /// Retrieve a memory by its id.
  Future<Memory?> getMemory(String id) async {
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

  /// Update an existing memory. Returns the number of rows affected.
  Future<int> updateMemory(Memory memory) async {
    if (memory.id == null) {
      throw ArgumentError('Cannot update a memory without an id.');
    }
    final db = await _dbHelper.database;
    return db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  /// Delete a memory by its id. Returns the number of rows affected.
  Future<int> deleteMemory(String id) async {
    final db = await _dbHelper.database;
    return db.delete('memories', where: 'id = ?', whereArgs: [id]);
  }
}
