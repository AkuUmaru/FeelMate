import 'package:myapp/models/emotional_log_model.dart';
import 'package:myapp/services/firestore_service.dart';

/// Provides a reactive Firestore stream of emotional classification logs.
class EmotionalLogRepository {
  /// Real-time stream of all logs for the current user (newest first).
  Stream<List<EmotionalLogModel>> logsStream() =>
      FirestoreService.emotionalLogsStream();

  /// One-shot fetch of all logs (used for statistics).
  Future<List<EmotionalLogModel>> getAllLogs() =>
      FirestoreService.getAllLogs();

  /// Deletes a single log entry by [logId].
  Future<void> deleteLog(String logId) =>
      FirestoreService.deleteEmotionalLog(logId);
}
