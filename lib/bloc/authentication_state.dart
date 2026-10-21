import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Abstract base class for all authentication states.
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

/// Authentication initial state - before checking auth status.
class AuthenticationInitial extends AuthenticationState {}

/// Authentication state when checking if user is signed in.
class AuthenticationChecking extends AuthenticationState {}

/// Authentication state when user is signed in.
class AuthenticationAuthenticated extends AuthenticationState {
  final User user;

  const AuthenticationAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Authentication state when user is signed out.
class AuthenticationUnauthenticated extends AuthenticationState {}

/// Authentication state when there was an error.
class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object> get props => [message];
}

/// Authentication state when signing in.
class AuthenticationSigningIn extends AuthenticationState {}

/// Authentication state when signing out.
class AuthenticationSigningOut extends AuthenticationState {}
