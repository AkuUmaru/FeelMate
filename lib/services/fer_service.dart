import 'dart:convert';
import 'package:http/http.dart' as http;

/// Facial Expression Recognition service.
///
/// Primary:  Hugging Face Inference API — `trpakov/vit-face-expression`
///           Free tier, no API key required for basic use.
///           Returns 7 classes: angry | disgust | fear | happy | neutral | sad | surprise
///
/// Fallback: Original Cloud Run endpoint (if it comes back online).
///
/// Both paths produce the same normalized JSON that [ResultPage] expects:
/// ```json
/// {
///   "emotion": "happy",
///   "confidence": 0.95,
///   "recommendations": [ {"name": "...", "price": 0}, ... ]
/// }
/// ```
class FerService {
  // ─── Endpoints ──────────────────────────────────────────────────────────────

  static const String _hfModel = 'trpakov/vit-face-expression';
  static const String _hfEndpoint =
      'https://api-inference.huggingface.co/models/$_hfModel';

  /// Optional: Set a free HuggingFace read-only token to get higher rate limits.
  /// Get yours at https://huggingface.co/settings/tokens (free account).
  /// Leave empty to use the public (anonymous) quota.
  static const String _hfToken = '';

  static const String _legacyEndpoint =
      'https://emotion-based-game-model-185908856851.asia-southeast2.run.app/recommend';

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
    // Try Hugging Face first (primary & more reliable)
    try {
      return await _classifyWithHuggingFace(imageBytes);
    } catch (hfErr) {
      // HF failed — attempt legacy endpoint as secondary fallback
      try {
        return await _classifyWithLegacy(imageBytes, filename);
      } catch (legacyErr) {
        throw FerException(
          'Both FER services are currently unavailable.\n'
          'HuggingFace: $hfErr\n'
          'Legacy: $legacyErr',
        );
      }
    }
  }

  // ─── Hugging Face ────────────────────────────────────────────────────────────

  static Future<String> _classifyWithHuggingFace(List<int> imageBytes) async {
    final headers = <String, String>{
      'Content-Type': 'application/octet-stream',
      if (_hfToken.isNotEmpty) 'Authorization': 'Bearer $_hfToken',
    };

    final response = await http
        .post(
          Uri.parse(_hfEndpoint),
          headers: headers,
          body: imageBytes,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 503) {
      // Model is loading — parse retry time from response
      throw FerException('Model is loading, please try again in ~20 seconds.');
    }

    if (response.statusCode != 200) {
      throw FerException('HuggingFace returned ${response.statusCode}: ${response.body}');
    }

    // HF returns: [{"label":"happy","score":0.95}, {"label":"sad","score":0.03}, ...]
    final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
    if (raw.isEmpty) throw FerException('Empty response from HuggingFace.');

    // Pick the top result
    final top = raw.reduce((a, b) =>
        (a['score'] as num) >= (b['score'] as num) ? a : b);

    final emotion = (top['label'] as String).toLowerCase();
    final confidence = (top['score'] as num).toDouble();
    final recs = _recommendations[emotion] ?? _recommendations['neutral']!;

    return jsonEncode({
      'emotion': emotion,
      'confidence': confidence,
      'recommendations': recs,
      'source': 'huggingface',
    });
  }

  // ─── Legacy endpoint ─────────────────────────────────────────────────────────

  static Future<String> _classifyWithLegacy(
      List<int> imageBytes, String filename) async {
    final request = http.MultipartRequest('POST', Uri.parse(_legacyEndpoint))
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
          filename: filename));

    final streamed = await request.send().timeout(const Duration(seconds: 20));
    if (streamed.statusCode != 200) {
      throw FerException('Legacy API returned ${streamed.statusCode}.');
    }
    final body = await streamed.stream.bytesToString();
    jsonDecode(body); // validate JSON — throws FormatException if invalid
    return body;
  }
}

// ─── Custom exception ────────────────────────────────────────────────────────

class FerException implements Exception {
  final String message;
  const FerException(this.message);

  @override
  String toString() => message;
}
