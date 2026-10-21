import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geodiary/services/profile_service.dart';

/// Service responsible for handling authentication operations.
class AuthenticationService {
  static const String signInCanceledCode = 'ERROR_GOOGLE_SIGN_IN_CANCELED';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ProfileService _profileService;
  bool _googleSignInInitialized = false;

  AuthenticationService({
    required this._firebaseAuth,
    required this._googleSignIn,
    required this._profileService,
  });

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Current authenticated user.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is currently signed in.
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Sign in with Google.
  Future<UserCredential> signInWithGoogle() async {
    try {
      final UserCredential userCredential = kIsWeb
          ? await _signInWithGoogleWeb()
          : await _signInWithGoogleMobile();

      await _updateProfile(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == signInCanceledCode) {
        rethrow;
      }
      throw FirebaseAuthException(
        code: e.code,
        message: 'Google Sign-In failed: ${e.message}',
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR_GOOGLE_SIGN_IN_FAILED',
        message: 'Google Sign-In failed: $e',
      );
    }
  }

  /// Uses Firebase Auth's popup flow on web. The google_sign_in web plugin
  /// only supports authentication through its own rendered button, so it
  /// cannot be used with a custom button.
  Future<UserCredential> _signInWithGoogleWeb() {
    return _firebaseAuth.signInWithPopup(GoogleAuthProvider());
  }

  Future<UserCredential> _signInWithGoogleMobile() async {
    await _ensureGoogleSignInInitialized();

    // Prefer the lightweight credential flow first: it reuses an existing
    // authorized account when available, and otherwise shows the device's
    // signed-in Google accounts in the account picker.
    GoogleSignInAccount? googleUser;
    try {
      final Future<GoogleSignInAccount?>? lightweightAttempt = _googleSignIn
          .attemptLightweightAuthentication(reportAllExceptions: true);
      if (lightweightAttempt != null) {
        googleUser = await lightweightAttempt;
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        throw FirebaseAuthException(
          code: signInCanceledCode,
          message: 'Google Sign-In was canceled.',
        );
      }
      // Fall back to the full interactive flow below.
    }

    googleUser ??= await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) {
      return;
    }
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  Future<void> _updateProfile(User? user) async {
    if (user == null) {
      return;
    }
    try {
      await _profileService.createOrUpdateProfileOnSignIn(
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
    } catch (_) {
      // Profile errors should not prevent the user from signing in.
    }
  }

  /// Sign out from Firebase and, on mobile, Google.
  Future<void> signOut() async {
    try {
      if (!kIsWeb && _googleSignInInitialized) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {
          // Ignore Google disconnect failures so Firebase still signs out.
        }
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR_SIGN_OUT_FAILED',
        message: 'Sign out failed: $e',
      );
    }
  }

  /// Get current user's ID token (for backend communication if needed).
  Future<String?> getIdToken() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  /// Reload current user data.
  Future<void> reloadUser() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }
}
