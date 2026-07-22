import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Domain model for a FeelMate user profile.
class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool emailVerified;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLogin,
    this.emailVerified = false,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
        'emailVerified': emailVerified,
      };

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) => UserModel(
        uid: uid,
        email: map['email'] as String? ?? '',
        displayName: map['displayName'] as String? ?? '',
        photoUrl: map['photoUrl'] as String?,
        createdAt:
            (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
        emailVerified: map['emailVerified'] as bool? ?? false,
      );

  factory UserModel.fromFirebaseUser(User user) => UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        emailVerified: user.emailVerified,
      );

  @override
  List<Object?> get props =>
      [uid, email, displayName, photoUrl, createdAt, lastLogin, emailVerified];
}
