import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/emotional_log_model.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/emotion_data.dart';
import 'package:uuid/uuid.dart';

class ResultPage extends StatefulWidget {
  final String result;
  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  String _emotion = 'Unknown';
  double _confidence = 0.0;
  List<dynamic> _recommendations = [];
  EmotionInfo? _emotionInfo;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    _parseAndLog();
    _ctrl.forward();
  }

  void _parseAndLog() {
    if (widget.result.isEmpty || widget.result == 'null') return;
    try {
      final data = jsonDecode(widget.result) as Map<String, dynamic>;
      _emotion = (data['emotion'] as String?) ?? 'Unknown';
      final raw = (data['confidence'] as num?)?.toDouble() ?? 0.0;
      _confidence = raw > 1 ? raw / 100 : raw;
      _recommendations = (data['recommendations'] as List?) ?? [];
      _emotionInfo = emotionInfoFor(_emotion);

      final log = EmotionalLogModel(
        id: const Uuid().v4(),
        emotion: _emotion,
        confidence: _confidence,
        timestamp: DateTime.now(),
      );
      FirestoreService.addEmotionalLog(log);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result.isEmpty || widget.result == 'null') {
      return _errorScaffold('No classification results found');
    }
    if (_emotionInfo == null) {
      return _errorScaffold('Could not parse emotion response');
    }

    final info = _emotionInfo!;
    final pct = (_confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emotion Analysis Result 🎯',
                    style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kTextDark)),
                const SizedBox(height: 16),

                // Main Emotion Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: info.color.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: const [kCardShadow],
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Text(
                          info.emoji,
                          style: const TextStyle(fontSize: 84),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: info.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${info.charEmoji} ${info.character}',
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: info.color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        info.name,
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: info.color,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confidence bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Confidence Score',
                              style: GoogleFonts.nunito(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted)),
                          Text('$pct%',
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: info.color)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: _confidence),
                        duration: const Duration(milliseconds: 900),
                        builder: (_, val, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: val,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(info.color),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        info.description,
                        style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kTextDark,
                            height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recommendations
                if (_recommendations.isNotEmpty) ...[
                  Text('Recommended Activities 🌿',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: kTextDark)),
                  const SizedBox(height: 4),
                  Text('Gentle activities tailored for your mood',
                      style: GoogleFonts.nunito(
                          fontSize: 13, fontWeight: FontWeight.w600, color: kTextMuted)),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.85,
                    children: _recommendations
                        .map<Widget>((rec) => _RecommendationCard(rec: rec))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),

                // Auto-logged Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
                    boxShadow: const [kCardShadow],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded,
                          color: kPrimaryColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This scan has been automatically saved to your Emotion Log.',
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kTextDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorScaffold(String msg) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Text(msg,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kTextMuted)),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final dynamic rec;
  const _RecommendationCard({required this.rec});

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('meditat') || n.contains('yoga') || n.contains('breath')) return Icons.self_improvement_rounded;
    if (n.contains('walk') || n.contains('run') || n.contains('exercise') || n.contains('sport')) return Icons.directions_walk_rounded;
    if (n.contains('music') || n.contains('song') || n.contains('listen')) return Icons.music_note_rounded;
    if (n.contains('read') || n.contains('book')) return Icons.menu_book_rounded;
    if (n.contains('journal') || n.contains('write') || n.contains('diary')) return Icons.edit_note_rounded;
    if (n.contains('sleep') || n.contains('rest') || n.contains('nap')) return Icons.bedtime_rounded;
    if (n.contains('friend') || n.contains('social') || n.contains('talk') || n.contains('chat')) return Icons.people_outline_rounded;
    if (n.contains('art') || n.contains('draw') || n.contains('paint') || n.contains('creat')) return Icons.palette_rounded;
    if (n.contains('cook') || n.contains('eat') || n.contains('food')) return Icons.restaurant_rounded;
    if (n.contains('nature') || n.contains('outdoor') || n.contains('garden') || n.contains('park')) return Icons.park_rounded;
    if (n.contains('game') || n.contains('play')) return Icons.sports_esports_rounded;
    if (n.contains('film') || n.contains('movie') || n.contains('watch')) return Icons.movie_rounded;
    return Icons.star_outline_rounded;
  }

  String _formatPrice(dynamic price) {
    if (price == null || price.toString().isEmpty || price.toString() == 'null') return 'Free';
    final s = price.toString();
    if (s == '0' || s == '0.0') return 'Free';
    final d = double.tryParse(s);
    if (d == null) return s;
    return d == d.truncateToDouble() ? '\$${d.toInt()}' : '\$${d.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final name = rec['name']?.toString() ?? 'Activity';
    final priceLabel = _formatPrice(rec['price']);
    final icon = _iconFor(name);
    final isFree = priceLabel == 'Free';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [kCardShadow],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 76,
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 36),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: kTextDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isFree ? kPrimaryLight : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priceLabel,
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isFree ? kPrimaryColor : const Color(0xFFD97706)),
            ),
          ),
        ],
      ),
    );
  }
}
