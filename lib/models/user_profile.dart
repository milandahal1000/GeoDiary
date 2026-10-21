import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model representing a user's document in Firestore.
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl; // Optional as per spec
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp lastLoginAt;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  /// Factory method to create a UserProfile from a Firestore document snapshot
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: data['uid'] as String,
      displayName: data['displayName'] as String,
      email: data['email'] as String,
      photoUrl: data['photoUrl'] as String?,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
      lastLoginAt: data['lastLoginAt'] as Timestamp,
    );
  }

  /// Convert UserProfile to a map suitable for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  /// Create a copy of this profile with optional field updates
  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? lastLoginAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          displayName == other.displayName &&
          email == other.email &&
          photoUrl == other.photoUrl &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          lastLoginAt == other.lastLoginAt;

  @override
  int get hashCode =>
      uid.hashCode ^
      displayName.hashCode ^
      email.hashCode ^
      photoUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      lastLoginAt.hashCode;

  @override
  String toString() {
    return 'UserProfile{uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt}';
  }
}
