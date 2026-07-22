import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/models/emotional_log_model.dart';
import 'package:myapp/repositories/emotional_log_repository.dart';

part 'emotional_log_event.dart';
part 'emotional_log_state.dart';

/// Manages the real-time emotional classification log feed.
///
/// Uses [emit.forEach] to keep the Firestore stream active for
/// the lifetime of the BLoC, automatically cancelling on close.
class EmotionalLogBloc extends Bloc<EmotionalLogEvent, EmotionalLogState> {
  final EmotionalLogRepository _repository;

  EmotionalLogBloc({required EmotionalLogRepository repository})
      : _repository = repository,
        super(const EmotionalLogInitial()) {
    on<EmotionalLogStarted>(_onStarted);
    on<EmotionalLogUpdated>(_onUpdated);
    on<EmotionalLogDeleteRequested>(_onDelete);
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onStarted(
      EmotionalLogStarted event, Emitter<EmotionalLogState> emit) async {
    emit(const EmotionalLogLoading());
    try {
      await emit.forEach<List<EmotionalLogModel>>(
        _repository.logsStream(),
        onData: (logs) => EmotionalLogLoaded(logs),
        onError: (_, __) => const EmotionalLogFailure(
            'Failed to load logs. Check your connection.'),
      );
    } catch (e) {
      emit(EmotionalLogFailure(e.toString()));
    }
  }

  void _onUpdated(
      EmotionalLogUpdated event, Emitter<EmotionalLogState> emit) {
    emit(EmotionalLogLoaded(event.logs));
  }

  Future<void> _onDelete(
      EmotionalLogDeleteRequested event, Emitter<EmotionalLogState> emit) async {
    await _repository.deleteLog(event.logId);
    // The Firestore stream will automatically push an updated list
  }
}
