import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/emotional_log_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User Profile ───────────────────────────────────────────────────────────

  static Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  static Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  static Future<void> updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  /// Ensures user profile exists in Firestore when signing in via Google.
  static Future<void> syncGoogleUser(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'FeelMate Friend',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await updateLastLogin(user.uid);
    }
  }

  // ─── Emotional Logs ─────────────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> _logsCollection(
      String uid) {
    return _db.collection('emotional_logs').doc(uid).collection('logs');
  }

  /// Add a new emotional log entry after classification.
  static Future<void> addEmotionalLog(EmotionalLogModel log) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _logsCollection(uid).doc(log.id).set(log.toMap());
  }

  /// Stream of all emotional logs for the current user (newest first).
  static Stream<List<EmotionalLogModel>> emotionalLogsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _logsCollection(uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EmotionalLogModel.fromMap(d.data(), d.id)).toList());
  }

  /// Delete a single emotional log entry.
  static Future<void> deleteEmotionalLog(String logId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _logsCollection(uid).doc(logId).delete();
  }

  /// One-time fetch of all logs (for statistics calculation).
  static Future<List<EmotionalLogModel>> getAllLogs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _logsCollection(uid)
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs
        .map((d) => EmotionalLogModel.fromMap(d.data(), d.id))
        .toList();
  }

  // ─── Mood Diary Impressions ─────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> _impressionsCollection(
      String uid) {
    return _db.collection('impressions').doc(uid).collection('entries');
  }

  /// Sync a mood diary entry to Firestore (source of truth remains SQLite).
  static Future<void> addImpression({
    required int emoticon,
    required String text,
    required String date,
    String? id,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final docId = id ?? const Uuid().v4();
    try {
      await _impressionsCollection(uid).doc(docId).set({
        'id': docId,
        'emoticon': emoticon,
        'text': text,
        'date': date,
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Silently fail if offline — SQLite is primary storage
    }
  }

  /// Delete a mood diary entry from Firestore.
  static Future<void> deleteImpression(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _impressionsCollection(uid).doc(id).delete();
    } catch (_) {}
  }

  /// Update (edit) an existing mood diary entry in Firestore.
  static Future<void> updateImpression({
    required String id,
    required int emoticon,
    required String text,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _impressionsCollection(uid).doc(id).update({
        'emoticon': emoticon,
        'text': text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Fetch all mood diary entries for the current user (used on Web instead of SQLite).
  static Future<List<Map<String, dynamic>>> getImpressions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    try {
      final snap = await _impressionsCollection(uid)
          .orderBy('date', descending: true)
          .get();
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        // Ensure 'id' field is present (may be stored as docId)
        data['id'] ??= d.id;
        // Emoticon stored as int
        data['emoticon'] = (data['emoticon'] as num?)?.toInt() ?? 0;
        return data;
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
