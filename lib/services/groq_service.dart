import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config/api_keys.dart';

/// Service for generating empathetic conversational AI responses via Groq Cloud.
class GroqService {
  // Uses key from lib/config/api_keys.dart or CLI --dart-define
  static const String _apiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: ApiKeys.groqApiKey,
  );

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  // Primary model: fast, highly capable in Indonesian & emotional understanding
  static const String _primaryModel = 'qwen/qwen3.8-27b';
  // Fallback model if primary experiences rate limits or downtime
  static const String _fallbackModel = 'openai/gpt-oss-120b';

  static const String systemPrompt = '''
Kamu adalah FeelMate AI Companion, sahabat dan pendengar setia yang hangat, penuh empati, suportif, dan menenangkan.
Prinsip utama pendampingan:
1. Validasi emosi: Dengarkan dan hargai perasaan pengguna terlebih dahulu tanpa menghakimi.
2. Gaya bahasa: Gunakan bahasa Indonesia yang santun, ramah, dan bersahabat (gunakan panggilan "aku" dan "kamu"). Jika pengguna bertanya dalam bahasa Inggris, balas dalam bahasa Inggris.
3. Responsif & Praktis: Berikan dorongan semangat lembut atau panduan kecil (misal: teknik pernapasan sederhana, istirahat sejenak, refleksi santai).
4. Singkat & Nyaman: Jaga panjang respons tetap nyaman dibaca di layar HP (sekitar 2-3 paragraf ringkas).
5. Etika: Jangan memberikan diagnosis klinis atau resep obat. Jika pengguna mengalami stres berat, sarankan dengan penuh kehangatan untuk beristirahat atau berkonsultasi dengan profesional.
''';

  /// Sends the conversation history to Groq and returns the generated reply.
  /// Automatically tries the fallback model if the primary model fails.
  static Future<String> getReply(List<Map<String, String>> history) async {
    try {
      return await _requestCompletion(history, _primaryModel);
    } catch (_) {
      // Fallback attempt
      return await _requestCompletion(history, _fallbackModel);
    }
  }

  static Future<String> _requestCompletion(
    List<Map<String, String>> history,
    String model,
  ) async {
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history,
    ];

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'User-Agent': 'FeelMateApp/1.0',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'max_tokens': 380,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final content = choices[0]['message']?['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    }

    throw Exception(
        'Groq API error (${response.statusCode}): ${response.body}');
  }
}
