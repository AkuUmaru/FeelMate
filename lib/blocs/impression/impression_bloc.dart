import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/models/impression_model.dart';
import 'package:myapp/repositories/impression_repository.dart';

part 'impression_event.dart';
part 'impression_state.dart';

/// Manages the mood diary (impression) state.
///
/// Uses SQLite as primary offline store with automatic
/// Firestore cloud backup via [ImpressionRepository].
class ImpressionBloc extends Bloc<ImpressionEvent, ImpressionState> {
  final ImpressionRepository _repository;

  ImpressionBloc({required ImpressionRepository repository})
      : _repository = repository,
        super(const ImpressionInitial()) {
    on<ImpressionLoadRequested>(_onLoad);
    on<ImpressionAddRequested>(_onAdd);
    on<ImpressionDeleteRequested>(_onDelete);
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(
      ImpressionLoadRequested event, Emitter<ImpressionState> emit) async {
    emit(const ImpressionLoading());
    try {
      final entries = await _repository.getAllEntries();
      emit(ImpressionLoaded(entries));
    } catch (e) {
      emit(ImpressionFailure('Failed to load diary: $e'));
    }
  }

  Future<void> _onAdd(
      ImpressionAddRequested event, Emitter<ImpressionState> emit) async {
    emit(const ImpressionLoading());
    try {
      await _repository.addEntry(
        emoticon: event.emoticon,
        text: event.text,
        date: event.date,
      );
      final entries = await _repository.getAllEntries();
      emit(ImpressionOperationSuccess('Mood saved! ✓', entries));
    } catch (e) {
      emit(ImpressionFailure('Failed to save diary entry: $e'));
    }
  }

  Future<void> _onDelete(
      ImpressionDeleteRequested event, Emitter<ImpressionState> emit) async {
    try {
      await _repository.deleteEntry(event.id);
      final entries = await _repository.getAllEntries();
      emit(ImpressionOperationSuccess('Entry deleted', entries));
    } catch (e) {
      emit(ImpressionFailure('Failed to delete entry: $e'));
    }
  }
}
