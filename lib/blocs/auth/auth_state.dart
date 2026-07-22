part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

/// Before any auth check has been performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An async auth operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// A valid user session exists.
class AuthAuthenticated extends AuthState {
  final String displayName;
  final String email;
  final String uid;
  const AuthAuthenticated({
    required this.uid,
    required this.displayName,
    required this.email,
  });
}

/// No valid session — user must log in.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed.
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}

/// Password reset email was sent successfully.
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}
