import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geodiary/services/authentication_service.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

/// Bloc for managing authentication state.
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authenticationService;

  AuthenticationBloc(this._authenticationService)
    : super(AuthenticationInitial()) {
    on<AuthenticationCheckStatus>(_onCheckStatus);
    on<AuthenticationSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthenticationSignOut>(_onSignOut);
  }

  Future<void> _onCheckStatus(
    AuthenticationCheckStatus event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationChecking());
    try {
      final User? user = _authenticationService.currentUser;
      if (user != null) {
        emit(AuthenticationAuthenticated(user));
      } else {
        emit(AuthenticationUnauthenticated());
      }
    } catch (e) {
      emit(AuthenticationError('Failed to check authentication status: $e'));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthenticationSignInWithGoogle event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationSigningIn());
    try {
      final UserCredential userCredential = await _authenticationService
          .signInWithGoogle();
      emit(AuthenticationAuthenticated(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (e.code == AuthenticationService.signInCanceledCode) {
        emit(AuthenticationUnauthenticated());
      } else {
        emit(AuthenticationError('Sign in failed: $e'));
      }
    } catch (e) {
      emit(AuthenticationError('Sign in failed: $e'));
    }
  }

  Future<void> _onSignOut(
    AuthenticationSignOut event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationSigningOut());
    try {
      await _authenticationService.signOut();
      emit(AuthenticationUnauthenticated());
    } catch (e) {
      emit(AuthenticationError('Sign out failed: $e'));
    }
  }
}
