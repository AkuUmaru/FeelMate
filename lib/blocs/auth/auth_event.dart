part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

/// Fired once on app start to check the current Firebase auth session.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// Request sign-in with email and password.
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
}

/// Request account creation.
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

/// Request sign-out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Request a password reset email.
class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested({required this.email});
}
