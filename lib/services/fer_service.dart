import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Facial Expression Recognition service — on-device TFLite inference.
///
/// Model: `assets/models/facialemotionmodel.tflite`, a CNN trained on
/// FER2013 (48x48 grayscale faces), measured at 60.9% test accuracy.
/// 7 classes, label order fixed by training: angry | disgust | fear | happy
/// | neutral | sad | surprise.
///
/// Produces the same normalized JSON that [ResultPage] expects:
/// ```json
/// {
///   "emotion": "happy",
///   "confidence": 0.95,
///   "recommendations": [ {"name": "...", "price": 0}, ... ]
/// }
/// ```
class FerService {
  static const String _modelAsset = 'assets/models/facialemotionmodel.tflite';

  static const List<String> _labels = [
    'angry',
    'disgust',
    'fear',
    'happy',
    'neutral',
    'sad',
    'surprise',
  ];

  static Interpreter? _interpreter;
  static final FaceDetector _faceDetector =
      FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));

  static Future<Interpreter> _getInterpreter() async {
    return _interpreter ??= await Interpreter.fromAsset(_modelAsset);
  }

  // ─── Per-emotion activity recommendations ───────────────────────────────────

  static const Map<String, List<Map<String, dynamic>>> _recommendations = {
    'happy': [
      {'name': 'Share your joy with a friend', 'price': 0},
      {'name': 'Gratitude journaling', 'price': 0},
      {'name': 'Dance to your favorite song', 'price': 0},
      {'name': 'Explore a new hobby', 'price': 0},
      {'name': 'Take a nature walk', 'price': 0},
    ],
    'sad': [
      {'name': 'Self-compassion meditation', 'price': 0},
      {'name': 'Write in your journal', 'price': 0},
      {'name': 'Listen to uplifting music', 'price': 0},
      {'name': 'Light walk outside', 'price': 0},
      {'name': 'Talk to someone you trust', 'price': 0},
    ],
    'angry': [
      {'name': 'Box breathing (4-4-4-4)', 'price': 0},
      {'name': 'Brisk outdoor walk', 'price': 0},
      {'name': 'Write your feelings down', 'price': 0},
      {'name': 'Cold water splash on face', 'price': 0},
      {'name': 'Progressive muscle relaxation', 'price': 0},
    ],
    'fear': [
      {'name': '4-7-8 breathing technique', 'price': 0},
      {'name': 'Grounding: 5-4-3-2-1 senses', 'price': 0},
      {'name': 'Mindfulness meditation', 'price': 0},
      {'name': 'Call a supportive friend', 'price': 0},
      {'name': 'Write about your worries', 'price': 0},
    ],
    'disgust': [
      {'name': 'Fresh air walk', 'price': 0},
      {'name': 'Engage in a pleasant activity', 'price': 0},
      {'name': 'Mindful breathing', 'price': 0},
      {'name': 'Creative art or drawing', 'price': 0},
      {'name': 'Watch a feel-good movie', 'price': 0},
    ],
    'surprise': [
      {'name': 'Journal about the experience', 'price': 0},
      {'name': 'Share your story with someone', 'price': 0},
      {'name': 'Take a quiet moment to process', 'price': 0},
      {'name': 'Deep breathing to centre yourself', 'price': 0},
      {'name': 'Light stretching or yoga', 'price': 0},
    ],
    'neutral': [
      {'name': 'Explore a new hobby or skill', 'price': 0},
      {'name': 'Take a mindful walk', 'price': 0},
      {'name': 'Read an inspiring book', 'price': 0},
      {'name': 'Creative writing or art', 'price': 0},
      {'name': 'Connect with a friend', 'price': 0},
    ],
  };

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Classify facial expression from raw image bytes.
  ///
  /// Returns a normalized JSON string ready for [ResultPage].
  /// Throws a [FerException] on failure.
  static Future<String> classify(List<int> imageBytes, String filename) async {
    // ML Kit's face detector needs a file path, so stage the bytes briefly.
    final tempFile = File(
        '${Directory.systemTemp.path}/fer_${DateTime.now().microsecondsSinceEpoch}_$filename');
    await tempFile.writeAsBytes(imageBytes);
    List<Face> faces;
    try {
      faces = await _faceDetector.processImage(InputImage.fromFilePath(tempFile.path));
    } finally {
      tempFile.delete().ignore();
    }

    if (faces.isEmpty) {
      throw const FerException(
          'No face detected — please retake with a clear, well-lit face.');
    }

    final decoded = img.decodeImage(Uint8List.fromList(imageBytes));
    if (decoded == null) {
      throw const FerException('Could not decode the captured image.');
    }

    final box = faces.first.boundingBox;
    final cropX = box.left.clamp(0, decoded.width - 1).toInt();
    final cropY = box.top.clamp(0, decoded.height - 1).toInt();
    final cropW = box.width.clamp(1, decoded.width - cropX).toInt();
    final cropH = box.height.clamp(1, decoded.height - cropY).toInt();

    final face = img.copyCrop(decoded, x: cropX, y: cropY, width: cropW, height: cropH);
    final gray = img.grayscale(face);
    final resized = img.copyResize(gray, width: 48, height: 48);

    final input = List.generate(
      1,
      (_) => List.generate(
        48,
        (y) => List.generate(
          48,
          (x) => [resized.getPixel(x, y).r / 255.0],
        ),
      ),
    );
    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    final interpreter = await _getInterpreter();
    interpreter.run(input, output);

    final scores = output[0];
    var bestIdx = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[bestIdx]) bestIdx = i;
    }

    final emotion = _labels[bestIdx];
    final confidence = scores[bestIdx];
    final recs = _recommendations[emotion] ?? _recommendations['neutral']!;

    return jsonEncode({
      'emotion': emotion,
      'confidence': confidence,
      'recommendations': recs,
      'source': 'tflite',
    });
  }
}

// ─── Custom exception ────────────────────────────────────────────────────────

class FerException implements Exception {
  final String message;
  const FerException(this.message);

  @override
  String toString() => message;
}
