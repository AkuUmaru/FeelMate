import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/emotion_data.dart';

class EmotionInfoScreen extends StatelessWidget {
  const EmotionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emotion Guide 🧠',
                    style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Meet the 7 emotions from Headquarters',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: kEmotions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final emotion = kEmotions[index];
                  return _EmotionCard(emotion: emotion);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionCard extends StatelessWidget {
  final EmotionInfo emotion;
  const _EmotionCard({required this.emotion});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [kCardShadow],
        ),
        clipBehavior: Clip.hardEdge,
        child: ExpansionTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: emotion.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: emotion.color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(emotion.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          title: Row(
            children: [
              Text(
                emotion.name,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: kTextDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: emotion.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${emotion.charEmoji} ${emotion.character}',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: emotion.color),
                ),
              ),
            ],
          ),
          subtitle: Text(
            'Tap to read details & traits',
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted),
          ),
          iconColor: emotion.color,
          collapsedIconColor: kTextMuted,
          children: [
            Divider(
                color: const Color(0xFFE2E8F0),
                height: 1,
                indent: 16,
                endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: emotion.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    emotion.description,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Facial & Expression Traits',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...emotion.characteristics.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 7),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: emotion.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kTextMuted,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
