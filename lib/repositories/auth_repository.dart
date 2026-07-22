import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';

/// Abstracts all authentication operations.
/// BLoCs depend on this repository, not on Firebase directly.
class AuthRepository {
  /// Stream that emits whenever auth state changes.
  Stream<User?> get authStateChanges => AuthService.authStateChanges;

  /// Returns the currently signed-in Firebase [User], or null.
  User? get currentUser => AuthService.currentUser;

  /// Signs in with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await AuthService.signIn(email: email, password: password);
    if (cred.user != null) {
      await FirestoreService.updateLastLogin(cred.user!.uid);
    }
    return cred.user;
  }

  /// Creates a new account, updates display name, and saves Firestore profile.
  /// Throws [FirebaseAuthException] on failure.
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await AuthService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (cred.user != null) {
      await FirestoreService.createUserProfile(
          UserModel.fromFirebaseUser(cred.user!));
    }
    return cred.user;
  }

  /// Signs the current user out.
  Future<void> signOut() => AuthService.signOut();

  /// Sends a password reset email to [email].
  /// Throws [FirebaseAuthException] on failure.
  Future<void> sendPasswordReset(String email) =>
      AuthService.sendPasswordReset(email);

  /// Translates a [FirebaseAuthException] code into a human-readable message.
  String errorMessage(FirebaseAuthException e) =>
      AuthService.errorMessage(e);
}
