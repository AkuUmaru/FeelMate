part of 'emotional_log_bloc.dart';

abstract class EmotionalLogEvent {
  const EmotionalLogEvent();
}

/// Subscribe to the real-time Firestore logs stream.
class EmotionalLogStarted extends EmotionalLogEvent {
  const EmotionalLogStarted();
}

/// Internal event emitted when the Firestore stream pushes new data.
class EmotionalLogUpdated extends EmotionalLogEvent {
  final List<EmotionalLogModel> logs;
  const EmotionalLogUpdated(this.logs);
}

/// Delete a single log entry.
class EmotionalLogDeleteRequested extends EmotionalLogEvent {
  final String logId;
  const EmotionalLogDeleteRequested(this.logId);
}
