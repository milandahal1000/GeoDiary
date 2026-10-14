import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:geodiary/core/database/database_helper.dart';
import 'package:geodiary/features/journal/data/memory_repository.dart';
import 'package:geodiary/features/journal/domain/memory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late MemoryRepository repository;
  late DatabaseHelper dbHelper;

  setUp(() async {
    // Mock path_provider
    const MethodChannel pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    // ignore: deprecated_member_use
    pathProviderChannel.setMockMethodCallHandler((MethodCall call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        // Return a temporary directory path for testing
        return '/tmp/geodiary_test';
      }
      return null;
    });

    final random = DateTime.now().millisecondsSinceEpoch;
    dbHelper = DatabaseHelper.testInstance(
      databaseName: 'geodiary_test_$random.db',
    );
    repository = MemoryRepository(dbHelper);
  });

  tearDown(() async {
    // Close the database to avoid leaks
    await dbHelper.close();

    // Clear the mocks
    const MethodChannel pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    // ignore: deprecated_member_use
    pathProviderChannel.setMockMethodCallHandler(null);
  });

  test('insert and retrieve a memory', () async {
    // Arrange
    final memory = Memory(
      title: 'Test Memory',
      description: 'A test description',
      visitDate: DateTime.now().millisecondsSinceEpoch,
      photoPath: '/path/to/photo.jpg',
      latitude: 10.0,
      longitude: 20.0,
      address: 'Test Address',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Act
    final id = await repository.insertMemory(memory);
    final retrieved = await repository.getMemory(id);

    // Assert
    expect(id, isNotNull);
    expect(retrieved, isNotNull);
    expect(retrieved?.id, equals(id));
    expect(retrieved?.title, equals(memory.title));
    expect(retrieved?.description, equals(memory.description));
    expect(retrieved?.visitDate, equals(memory.visitDate));
    expect(retrieved?.photoPath, equals(memory.photoPath));
    expect(retrieved?.latitude, equals(memory.latitude));
    expect(retrieved?.longitude, equals(memory.longitude));
    expect(retrieved?.address, equals(memory.address));
    expect(retrieved?.createdAt, equals(memory.createdAt));
    expect(retrieved?.updatedAt, equals(memory.updatedAt));
  });

  test('get all memories returns empty list initially', () async {
    final memories = await repository.getAllMemories();
    expect(memories, isEmpty);
  });

  test('update a memory', () async {
    // Arrange
    final memory = Memory(
      title: 'Original Title',
      description: 'Original Description',
      visitDate: DateTime.now().millisecondsSinceEpoch,
      photoPath: null,
      latitude: null,
      longitude: null,
      address: null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final id = await repository.insertMemory(memory);

    // Act
    final updatedMemory = memory.copyWith(
      id: id,
      title: 'Updated Title',
      description: 'Updated Description',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final rowsUpdated = await repository.updateMemory(updatedMemory);
    final retrieved = await repository.getMemory(id);

    // Assert
    expect(rowsUpdated, equals(1));
    expect(retrieved, isNotNull);
    expect(retrieved?.title, equals('Updated Title'));
    expect(retrieved?.description, equals('Updated Description'));
    expect(retrieved?.updatedAt, greaterThan(memory.updatedAt));
  });

  test('delete a memory', () async {
    // Arrange
    final memory = Memory(
      title: 'Memory to Delete',
      description: '',
      visitDate: DateTime.now().millisecondsSinceEpoch,
      photoPath: null,
      latitude: null,
      longitude: null,
      address: null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final id = await repository.insertMemory(memory);

    // Act
    final rowsDeleted = await repository.deleteMemory(id);
    final retrieved = await repository.getMemory(id);

    // Assert
    expect(rowsDeleted, equals(1));
    expect(retrieved, isNull);
  });

  test('get all memories returns memories in correct order', () async {
    // Arrange
    final now = DateTime.now().millisecondsSinceEpoch;
    final memory1 = Memory(
      title: 'Older Memory',
      description: '',
      visitDate: now - 20000, // older
      photoPath: null,
      latitude: null,
      longitude: null,
      address: null,
      createdAt: now,
      updatedAt: now,
    );
    final memory2 = Memory(
      title: 'Newer Memory',
      description: '',
      visitDate: now, // newer
      photoPath: null,
      latitude: null,
      longitude: null,
      address: null,
      createdAt: now,
      updatedAt: now,
    );

    await repository.insertMemory(memory1);
    await repository.insertMemory(memory2);

    // Act
    final memories = await repository.getAllMemories();

    // Assert
    expect(memories, hasLength(2));
    expect(memories[0].title, equals('Newer Memory')); // newest first
    expect(memories[1].title, equals('Older Memory'));
  });
}
