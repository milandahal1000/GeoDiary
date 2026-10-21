import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

/// Service responsible for managing user profiles in Firestore.
class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileService({required this._firestore, required this._auth});

  /// Reference to the current user's profile document
  DocumentReference _getProfileRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }
    return _firestore.collection('users').doc(user.uid);
  }

  /// Create or update user profile after successful sign-in
  /// Preserves createdAt on subsequent logins, updates other fields
  Future<UserProfile> createOrUpdateProfileOnSignIn({
    required String displayName,
    required String email,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final profileRef = _getProfileRef();
      final docSnapshot = await profileRef.get();

      if (docSnapshot.exists) {
        // Profile exists - update it, preserving createdAt
        final existingProfile = UserProfile.fromDocument(docSnapshot);
        final updatedProfile = existingProfile.copyWith(
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
          lastLoginAt: Timestamp.now(),
          // updatedAt will be set by Firestore's server timestamp below
        );

        await profileRef.update(updatedProfile.toMap());
        return updatedProfile;
      } else {
        // Profile doesn't exist - create new one
        final now = Timestamp.now();
        final newProfile = UserProfile(
          uid: user.uid,
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
          createdAt: now,
          updatedAt: now,
          lastLoginAt: now,
        );

        await profileRef.set(newProfile.toMap());
        return newProfile;
      }
    } catch (e) {
      throw Exception('Failed to create or update profile: $e');
    }
  }

  /// Retrieve current user's profile from Firestore
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final profileRef = _getProfileRef();
      final docSnapshot = await profileRef.get();

      if (docSnapshot.exists) {
        return UserProfile.fromDocument(docSnapshot);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve profile: $e');
    }
  }

  /// Update specific profile fields (merge strategy)
  Future<void> updateProfileFields(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final profileRef = _getProfileRef();
      await profileRef.update(updates);
    } catch (e) {
      throw Exception('Failed to update profile fields: $e');
    }
  }
}
