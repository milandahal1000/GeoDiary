import 'package:equatable/equatable.dart';

/// Abstract base class for all authentication events.
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

/// Event to check the current authentication status.
class AuthenticationCheckStatus extends AuthenticationEvent {}

/// Event to sign in with Google.
class AuthenticationSignInWithGoogle extends AuthenticationEvent {}

/// Event to sign out.
class AuthenticationSignOut extends AuthenticationEvent {}
