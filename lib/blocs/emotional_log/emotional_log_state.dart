part of 'emotional_log_bloc.dart';

abstract class EmotionalLogState {
  const EmotionalLogState();
}

class EmotionalLogInitial extends EmotionalLogState {
  const EmotionalLogInitial();
}

class EmotionalLogLoading extends EmotionalLogState {
  const EmotionalLogLoading();
}

class EmotionalLogLoaded extends EmotionalLogState {
  final List<EmotionalLogModel> logs;
  const EmotionalLogLoaded(this.logs);
}

class EmotionalLogFailure extends EmotionalLogState {
  final String message;
  const EmotionalLogFailure(this.message);
}
