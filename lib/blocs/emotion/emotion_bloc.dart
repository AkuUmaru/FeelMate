import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/repositories/emotion_repository.dart';

part 'emotion_event.dart';
part 'emotion_state.dart';

/// Manages the emotion scan workflow:
///  1. Image selection
///  2. API classification (MobileNetV1 CNN)
///  3. Auto-persist result to Firestore
///
/// The UI only dispatches events and reacts to states —
/// zero HTTP or IO logic lives in the widget layer.
class EmotionBloc extends Bloc<EmotionEvent, EmotionState> {
  final EmotionRepository _emotionRepository;

  EmotionBloc({required EmotionRepository emotionRepository})
      : _emotionRepository = emotionRepository,
        super(const EmotionInitial()) {
    on<EmotionImageSelected>(_onImageSelected);
    on<EmotionAnalyzeRequested>(_onAnalyzeRequested);
    on<EmotionReset>(_onReset);
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  void _onImageSelected(
      EmotionImageSelected event, Emitter<EmotionState> emit) {
    emit(EmotionImageReady(event.imageFile));
  }

  Future<void> _onAnalyzeRequested(
      EmotionAnalyzeRequested event, Emitter<EmotionState> emit) async {
    // Guard: must have an image
    final currentState = state;
    dynamic imageFile;
    if (currentState is EmotionImageReady) {
      imageFile = currentState.imageFile;
    } else if (currentState is EmotionFailure) {
      imageFile = currentState.imageFile;
    } else {
      return;
    }

    emit(EmotionAnalyzing(imageFile));

    try {
      final file = imageFile is File ? imageFile : File(imageFile.path);
      final result = await _emotionRepository.classifyImage(file);

      // Auto-persist to Firestore after successful classification
      await _emotionRepository.saveLog(result);

      emit(EmotionSuccess(
        imageFile: imageFile,
        emotion: result.emotion,
        confidence: result.confidence,
        allScores: result.allScores,
        rawJson: result.rawJson,
      ));
    } catch (e) {
      emit(EmotionFailure(
        imageFile: imageFile,
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onReset(EmotionReset event, Emitter<EmotionState> emit) {
    emit(const EmotionInitial());
  }
}
