/// Represents a memory entry in the GeoDiary app.
class Memory {
  final String? id; // nullable for new memories before insertion
  final String title;
  final String? description;
  final int visitDate; // milliseconds since epoch
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String? address;
  final int createdAt; // milliseconds since epoch
  final int updatedAt; // milliseconds since epoch

  Memory({
    this.id,
    required this.title,
    this.description,
    required this.visitDate,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  }) {
    // Validate that latitude and longitude are both present or both absent
    if ((latitude == null) != (longitude == null)) {
      throw ArgumentError(
        'Latitude and longitude must both be present or both absent.',
      );
    }
    // Validate title is not empty
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty.');
    }
  }

  /// Creates a copy of this memory with the given fields replaced.
  Memory copyWith({
    String? id,
    String? title,
    String? description,
    int? visitDate,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? address,
    int? createdAt,
    int? updatedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      visitDate: visitDate ?? this.visitDate,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this memory to a map suitable for storing in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'visitDate': visitDate,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a memory from a map (typically from the database).
  factory Memory.fromMap(Map<String, Object?> map) {
    return Memory(
      id: map['id']?.toString(),
      title: map['title'] as String,
      description: map['description'] as String?,
      visitDate: (map['visitDate'] as num).toInt(),
      photoPath: map['photoPath'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
      createdAt: (map['createdAt'] as num).toInt(),
      updatedAt: (map['updatedAt'] as num).toInt(),
    );
  }

  @override
  String toString() {
    return 'Memory{id: $id, title: $title, visitDate: $visitDate, ...}';
  }

  @override
  bool operator ==(covariant Memory other) =>
      id == other.id &&
      title == other.title &&
      description == other.description &&
      visitDate == other.visitDate &&
      photoPath == other.photoPath &&
      latitude == other.latitude &&
      longitude == other.longitude &&
      address == other.address &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    visitDate,
    photoPath,
    latitude,
    longitude,
    address,
    createdAt,
    updatedAt,
  );
}
