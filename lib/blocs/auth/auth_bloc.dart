import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Manages the entire authentication lifecycle for FeelMate.
///
/// Responsibilities:
///  - Checking existing auth session on app start
///  - Sign in / sign up / sign out
///  - Password reset
///  - Emitting typed states consumed by UI via BlocConsumer / BlocBuilder
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthPasswordResetRequested>(_onPasswordReset);
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onAuthStarted(
      AuthStarted event, Emitter<AuthState> emit) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(
        uid: user.uid,
        displayName: user.displayName ?? 'FeelMate User',
        email: user.email ?? '',
      ));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(
          uid: user.uid,
          displayName: user.displayName ?? 'FeelMate User',
          email: user.email ?? '',
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_authRepository.errorMessage(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      if (user != null) {
        emit(AuthAuthenticated(
          uid: user.uid,
          displayName: user.displayName ?? event.displayName,
          email: user.email ?? '',
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_authRepository.errorMessage(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onPasswordReset(
      AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordReset(event.email);
      emit(const AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_authRepository.errorMessage(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
