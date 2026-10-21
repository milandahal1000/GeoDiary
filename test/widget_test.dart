import 'package:flutter_test/flutter_test.dart';
import 'package:geodiary/features/journal/domain/memory.dart';

void main() {
  group('Memory local serialization', () {
    test('round-trips through a map', () {
      final memory = Memory(
        id: '123',
        title: 'Test Memory',
        description: 'A test description',
        visitDate: 1700000000000,
        photoPath: '/path/to/photo.jpg',
        latitude: 10.0,
        longitude: 20.0,
        address: 'Test Address',
        createdAt: 1700000000000,
        updatedAt: 1700000000000,
      );

      final restored = Memory.fromMap(memory.toMap());

      expect(restored, equals(memory));
    });

    test('rejects an empty title', () {
      expect(
        () => Memory(title: '', visitDate: 0, createdAt: 0, updatedAt: 0),
        throwsArgumentError,
      );
    });

    test('requires latitude and longitude together', () {
      expect(
        () => Memory(
          title: 'Test',
          visitDate: 0,
          latitude: 10.0,
          createdAt: 0,
          updatedAt: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
