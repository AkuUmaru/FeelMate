import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Inside Out × FeelMate — Emotion Character Data
//  Each emotion maps to an Inside Out character with their signature color.
// ══════════════════════════════════════════════════════════════════════════════

/// Emotion metadata used across the app.
class EmotionInfo {
  final String name;
  final String emoji;
  final Color color;
  final String character;     // Inside Out character name
  final String charEmoji;     // Character emoji representation
  final String description;
  final List<String> characteristics;

  const EmotionInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.character,
    required this.charEmoji,
    required this.description,
    required this.characteristics,
  });
}

const List<EmotionInfo> kEmotions = [
  EmotionInfo(
    name: 'Happy',
    emoji: '😊',
    color: Color(0xFFFFD60A),      // Joy's golden yellow
    character: 'Joy',
    charEmoji: '⭐',
    description:
        'Joy is running Headquarters! Happiness is a radiant positive state full of energy, creativity, and connection. When Joy takes the console, everything feels possible.',
    characteristics: [
      'Raised cheeks and sparkling, narrowed eyes',
      'Corners of mouth pulled wide into a glowing smile',
      'Genuine (Duchenne) smile that reaches the eyes',
      'Relaxed brow and open, welcoming expression',
      'Bright, energetic body language',
    ],
  ),
  EmotionInfo(
    name: 'Sad',
    emoji: '😢',
    color: Color(0xFF42A5F5),      // Sadness's sky blue
    character: 'Sadness',
    charEmoji: '💙',
    description:
        'Sadness has stepped up to the console. It\'s okay — she\'s important too. Sadness signals loss or grief, but also invites reflection and the comfort of others.',
    characteristics: [
      'Inner corners of brows raised and pulled together',
      'Corners of mouth drooping downward',
      'Lower lip may tremble or pout softly',
      'Eyes may be glossy, heavy-lidded, or tearful',
      'Slumped, inward posture reaching for comfort',
    ],
  ),
  EmotionInfo(
    name: 'Angry',
    emoji: '😠',
    color: Color(0xFFFF5722),      // Anger's flame red-orange
    character: 'Anger',
    charEmoji: '🔥',
    description:
        'Anger is at the console — steam may be coming from his head! This intense emotion reacts to perceived injustice, threats, or frustration with fiery determination.',
    characteristics: [
      'Brows pulled sharply down and together',
      'Intense, laser-focused stare',
      'Nostrils flaring with each breath',
      'Lips pressed hard together or jaw clenched tight',
      'Face may flush red — literally like Anger in the film!',
    ],
  ),
  EmotionInfo(
    name: 'Surprised',
    emoji: '😲',
    color: Color(0xFFF48FB1),      // Bing Bong's candy pink
    character: 'Bing Bong',
    charEmoji: '🎪',
    description:
        'Something unexpected just happened — like Bing Bong jumping out from the imagination! Surprise is a brief, powerful reaction to the unforeseen.',
    characteristics: [
      'Eyebrows shot high and dramatically curved',
      'Eyes wide open with whites visible above the iris',
      'Jaw drops and mouth forms a wide O',
      'Skin below brows stretches in an instant',
      'A flash reaction — brief and explosive',
    ],
  ),
  EmotionInfo(
    name: 'Disgusted',
    emoji: '🤢',
    color: Color(0xFF66BB6A),      // Disgust's leaf green
    character: 'Disgust',
    charEmoji: '💚',
    description:
        'Disgust is at the helm, keeping Riley\'s standards sky-high. This protective emotion reacts to things that are offensive — physically or morally — and is served with style.',
    characteristics: [
      'Upper lip raised and curled with sophistication',
      'Nose wrinkled in unmistakable disapproval',
      'Brows pulled down slightly with one arched',
      'Eyes may narrow into an unimpressed squint',
      'Head turns away — Disgust knows what she doesn\'t like',
    ],
  ),
  EmotionInfo(
    name: 'Fearful',
    emoji: '😨',
    color: Color(0xFFBA68C8),      // Fear's light purple
    character: 'Fear',
    charEmoji: '💜',
    description:
        'Fear has grabbed the console — probably while trembling! This critical survival emotion activates fight-or-flight to keep Riley safe from any perceived danger.',
    characteristics: [
      'Brows raised high and pulled anxiously together',
      'Upper eyelids wide open, lower eyelids tense',
      'Eyes scanning wide for danger',
      'Mouth stretched back horizontally in alarm',
      'Whole body on high alert — just like Fear in HQ!',
    ],
  ),
  EmotionInfo(
    name: 'Neutral',
    emoji: '😐',
    color: Color(0xFF78909C),      // Calm memory-orb steel blue
    character: 'Riley',
    charEmoji: '😌',
    description:
        'The console is calm — Headquarters is in balance. A neutral expression is the baseline emotional state, with all emotions at rest and no dominant feeling taking control.',
    characteristics: [
      'All facial muscles completely relaxed',
      'Mouth neither raised nor lowered — perfectly level',
      'Eyes at their natural, resting aperture',
      'Brows in their default resting position',
      'Peaceful, composed overall — just like a quiet mind',
    ],
  ),
];

/// Returns the [EmotionInfo] matching the given emotion label (case-insensitive).
/// Falls back to Neutral if not found.
EmotionInfo emotionInfoFor(String label) {
  final lower = label.toLowerCase().trim();
  // Handle common FER model output variants
  final aliases = <String, String>{
    'happy':     'Happy',
    'happiness': 'Happy',
    'joy':       'Happy',
    'sad':       'Sad',
    'sadness':   'Sad',
    'angry':     'Angry',
    'anger':     'Angry',
    'surprised': 'Surprised',
    'surprise':  'Surprised',
    'disgusted': 'Disgusted',
    'disgust':   'Disgusted',
    'fearful':   'Fearful',
    'fear':      'Fearful',
    'scared':    'Fearful',
    'neutral':   'Neutral',
    'calm':      'Neutral',
  };
  final mapped = aliases[lower] ?? label;
  return kEmotions.firstWhere(
    (e) => e.name.toLowerCase() == mapped.toLowerCase(),
    orElse: () => kEmotions.last, // Neutral
  );
}
