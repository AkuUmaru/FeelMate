part of 'emotion_bloc.dart';

abstract class EmotionEvent {
  const EmotionEvent();
}

/// User selected an image file to analyze.
class EmotionImageSelected extends EmotionEvent {
  final dynamic imageFile; // File on mobile, XFile on web
  const EmotionImageSelected(this.imageFile);
}

/// User tapped "Analyze Emotion" button.
class EmotionAnalyzeRequested extends EmotionEvent {
  const EmotionAnalyzeRequested();
}

/// Reset BLoC back to initial state (clear image + result).
class EmotionReset extends EmotionEvent {
  const EmotionReset();
}
