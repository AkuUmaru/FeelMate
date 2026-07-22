import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:myapp/models/emotional_log_model.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

/// Parsed result from the ML emotion classification API.
class EmotionResult {
  final String emotion;
  final double confidence;
  final Map<String, double> allScores;
  final String rawJson;

  const EmotionResult({
    required this.emotion,
    required this.confidence,
    required this.allScores,
    required this.rawJson,
  });
}

/// Handles communication with the CNN/MobileNet emotion classification API
/// and persists results to Firestore.
class EmotionRepository {
  static const _apiUrl =
      'https://emotion-based-game-model-185908856851.asia-southeast2.run.app/recommend';

  /// Sends [imageFile] to the ML API and returns a parsed [EmotionResult].
  /// Throws [Exception] on network or parse errors.
  Future<EmotionResult> classifyImage(File imageFile) async {
    final uri = Uri.parse(_apiUrl);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      throw Exception(
          'API error ${streamedResponse.statusCode}: $responseBody');
    }

    return _parseResponse(responseBody);
  }

  /// Parses the raw JSON response into an [EmotionResult].
  EmotionResult _parseResponse(String rawJson) {
    final data = json.decode(rawJson) as Map<String, dynamic>;

    // Support both flat and nested API response structures
    String emotion = '';
    double confidence = 0.0;
    final allScores = <String, double>{};

    if (data.containsKey('predicted_emotion')) {
      emotion = data['predicted_emotion'] as String? ?? 'Unknown';
      final scores = data['emotion_scores'] as Map<String, dynamic>?;
      if (scores != null) {
        scores.forEach((k, v) {
          allScores[k] = (v as num).toDouble();
          if (k.toLowerCase() == emotion.toLowerCase()) {
            confidence = allScores[k]!;
          }
        });
      }
    } else if (data.containsKey('emotion')) {
      emotion = data['emotion'] as String? ?? 'Unknown';
      confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
      allScores[emotion] = confidence;
    } else {
      // Fallback: pick max from any numeric map entries
      data.forEach((k, v) {
        if (v is num) allScores[k] = v.toDouble();
      });
      if (allScores.isNotEmpty) {
        final maxEntry =
            allScores.entries.reduce((a, b) => a.value >= b.value ? a : b);
        emotion = maxEntry.key;
        confidence = maxEntry.value;
      }
    }

    return EmotionResult(
      emotion: emotion,
      confidence: confidence,
      allScores: allScores,
      rawJson: rawJson,
    );
  }

  /// Persists a classification result to Firestore.
  Future<void> saveLog(EmotionResult result) async {
    final log = EmotionalLogModel(
      id: const Uuid().v4(),
      emotion: result.emotion,
      confidence: result.confidence,
      timestamp: DateTime.now(),
    );
    await FirestoreService.addEmotionalLog(log);
  }
}
