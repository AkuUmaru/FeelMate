part of 'emotion_bloc.dart';

abstract class EmotionState {
  const EmotionState();
}

/// No image selected yet.
class EmotionInitial extends EmotionState {
  const EmotionInitial();
}

/// An image has been selected and is ready for analysis.
class EmotionImageReady extends EmotionState {
  final dynamic imageFile;
  const EmotionImageReady(this.imageFile);
}

/// API call is in progress.
class EmotionAnalyzing extends EmotionState {
  final dynamic imageFile;
  const EmotionAnalyzing(this.imageFile);
}

/// API returned a successful classification result.
class EmotionSuccess extends EmotionState {
  final dynamic imageFile;
  final String emotion;
  final double confidence;
  final Map<String, double> allScores;
  final String rawJson;

  const EmotionSuccess({
    required this.imageFile,
    required this.emotion,
    required this.confidence,
    required this.allScores,
    required this.rawJson,
  });
}

/// API call or parsing failed.
class EmotionFailure extends EmotionState {
  final dynamic imageFile;
  final String message;
  const EmotionFailure({required this.imageFile, required this.message});
}
