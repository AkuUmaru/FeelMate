import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/colors.dart';

// ─── Message model ────────────────────────────────────────────────────────────

class _Msg {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isCrisis;
  _Msg({
    required this.text,
    required this.isUser,
    DateTime? time,
    this.isCrisis = false,
  }) : time = time ?? DateTime.now();
}

// ─── Gemini Basic AI Assistant Screen ──────────────────────────────────────────

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with TickerProviderStateMixin {
  final List<_Msg> _msgs = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _typing = false;
  int _distressCount = 0;
  bool _showQuickReplies = true;
  late AnimationController _dotAnim;

  static const _quickReplies = [
    'I feel anxious lately',
    "I'm really stressed",
    'I feel so sad',
    "I can't sleep well",
    'I need a friendly chat',
    "I'm feeling lonely",
  ];

  static const _crisisKw = [
    'suicide', 'suicidal', 'kill myself', 'end my life', 'want to die',
    'no reason to live', 'better off dead', 'take my own life', 'self harm',
    'hurt myself', "can't live anymore", 'wish i was dead',
  ];
  static const _highStressKw = [
    'overwhelmed', 'panic attack', "can't cope", 'breaking down', 'burnout',
    'completely exhausted', "can't go on", 'no hope', 'nothing matters',
    'pointless', 'hopeless', 'worthless', "can't take it", 'falling apart',
    'give up',
  ];
  static const _sadKw = [
    'sad', 'cry', 'crying', 'depressed', 'depression', 'unhappy', 'lonely',
    'alone', 'empty', 'grief', 'heartbreak', 'heartbroken', 'miserable',
    'down', 'blue', 'gloomy', 'tearful', 'devastated',
  ];
  static const _anxietyKw = [
    'anxious', 'anxiety', 'worried', 'worry', 'nervous', 'scared', 'fear',
    'afraid', 'panic', 'stress', 'stressed', 'tense', 'dread', 'uneasy',
    'restless', 'overthinking',
  ];
  static const _angerKw = [
    'angry', 'anger', 'furious', 'rage', 'frustrated', 'frustration', 'mad',
    'annoyed', 'irritated', 'livid', 'enraged', 'upset',
  ];
  static const _positiveKw = [
    'happy', 'great', 'good', 'amazing', 'wonderful', 'joy', 'joyful',
    'excited', 'grateful', 'thankful', 'blessed', 'fantastic', 'awesome',
    'better', 'improving', 'hopeful', 'okay', 'fine', 'alright',
  ];

  @override
  void initState() {
    super.initState();
    _dotAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(
          text: "Hi there! I'm Gemini Basic ✨\n\nI'm your friendly, empathetic companion. You can talk to me about anything on your mind — no stress, just a calm and supportive conversation.\n\nHow are you feeling today?",
          isUser: false,
        ));
      });
    });
  }

  @override
  void dispose() {
    _dotAnim.dispose();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _containsAny(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    return keywords.any((kw) => lower.contains(kw));
  }

  String _generateResponse(String userMsg) {
    final alwaysRef = _distressCount >= 3;
    const ref =
        "\n\n💙 Gemini Note: Because you're carrying a heavy emotional load right now, please consider talking to a doctor, specialist, or psychiatrist for extra care.";

    if (_containsAny(userMsg, _crisisKw)) {
      _distressCount += 3;
      return '__CRISIS__';
    }

    if (_containsAny(userMsg, _highStressKw)) {
      _distressCount += 2;
      final list = [
        "I hear how overwhelming everything feels right now ✨. Please take a moment to breathe slowly with me.\n\nDeep inhale → slow exhale 🌿.\n\nYou don't have to fix everything today. What is one tiny thing causing you stress right now?",
        "That sounds like a heavy weight to carry alone. I'm here with you, listening with a warm heart.\n\nCan you tell me a little more about what's been stressing you out?",
        "When things pile up, it's completely natural to feel exhausted. Be gentle with yourself today.\n\nWhat can we do to make today just 5% lighter for you?",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : "\n\n💡 Remember: If stress stays this high, speaking to a certified mental health specialist is a wonderful way to care for yourself.");
    }

    if (_containsAny(userMsg, _sadKw)) {
      _distressCount += 1;
      final list = [
        "I'm sending you a warm virtual hug ✨. It's completely okay to feel sad or tearful — feelings come and go like rain.\n\nWould it help to talk about what brought on this sadness?",
        "Thank you for sharing that with me. Your feelings are valid and deserving of kindness.\n\nWhat's one gentle thing you can do for yourself right now, like drinking some warm tea or wrapping up in a blanket?",
        "Sadness often means we care deeply about something. I'm right here listening — take as much time as you need.",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : '');
    }

    if (_containsAny(userMsg, _anxietyKw)) {
      _distressCount += 1;
      final list = [
        "Anxiety can make thoughts feel fast and noisy ✨. Let's ground ourselves together.\n\nLook around and name 3 simple objects near you. I'm here with you, step by step.",
        "It's okay to feel nervous or uncertain. Your mind is trying to protect you, even if it feels uncomfortable.\n\nWhat is the main worry on your mind right now?",
        "Take a slow breath with me 🌿. You're safe right here in this chat. Let's break down whatever you're facing into smaller, easier pieces.",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : '');
    }

    if (_containsAny(userMsg, _angerKw)) {
      _distressCount += 1;
      final list = [
        "I hear how frustrating that situation is ✨. Anger is a sign that something important to you was crossed.\n\nWould you like to vent about what happened? I'm listening without judgment.",
        "That sounds infuriating. It's okay to feel mad — let's give those feelings space to cool down naturally.\n\nWhat triggered this anger today?",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : '');
    }

    if (_containsAny(userMsg, _positiveKw)) {
      final list = [
        "That brings a warm smile to my heart! ✨ What nice moment made you feel good today?",
        "I'm so glad to hear that! 🌟 Celebrating small wins and happy moments is so special. Tell me more!",
        "That's wonderful! Savoring joyful feelings gives us strength. What's been going well?",
      ];
      return list[DateTime.now().millisecond % list.length];
    }

    final defaults = [
      "I'm listening with an open heart ✨. Tell me a bit more about how you're feeling right now.",
      "Thank you for opening up to me! I'm here to chat whenever you need a friendly ear.",
      "That sounds like a lot to hold. Take your time — what's most on your mind right now?",
      "I'm glad we're chatting. How has your day been treating you overall?",
    ];
    return defaults[DateTime.now().millisecond % defaults.length] + (alwaysRef ? ref : '');
  }

  void _send([String? quickReply]) {
    final text = (quickReply ?? _ctrl.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _msgs.add(_Msg(text: text, isUser: true));
      _ctrl.clear();
      _typing = true;
      _showQuickReplies = false;
    });
    _scrollToBottom();

    final delayMs = (700 + text.length * 10).clamp(600, 1800);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      final raw = _generateResponse(text);
      setState(() {
        _typing = false;
        _msgs.add(_Msg(
          text: raw == '__CRISIS__'
              ? "I'm really concerned about how much pain you're in ✨.\n\nPlease know that your life is valuable and you don't have to carry this alone. I strongly encourage you to connect with a crisis counselor or healthcare specialist right away."
              : raw,
          isUser: false,
          isCrisis: raw == '__CRISIS__',
        ));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasQR = _showQuickReplies && _msgs.length == 1;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _msgs.length + (_typing ? 1 : 0) + (hasQR ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (hasQR && i == 1) return _buildQuickReplies();
                if (_typing && i == _msgs.length + (hasQR ? 1 : 0)) return _buildTyping();
                final idx = i - (hasQR && i > 0 ? 1 : 0);
                if (idx < 0 || idx >= _msgs.length) return const SizedBox.shrink();
                return _buildBubble(_msgs[idx]);
              },
            ),
          ),
          if (_distressCount >= 3) _buildReferralBanner(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: const [kCardShadow],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 18, 14),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextDark, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), blurRadius: 8),
                  ],
                ),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gemini Basic', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: kTextDark)),
                    Row(children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Empathetic Emotional Support', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
                ),
                child: Text('Gemini', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: kPrimaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    if (msg.isCrisis) return _buildCrisisCard(msg);
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('✨', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [kCardShadow],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: isUser ? FontWeight.w700 : FontWeight.w600,
                  color: isUser ? Colors.white : kTextDark,
                  height: 1.55,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildCrisisCard(_Msg msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
          boxShadow: const [kCardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.favorite, color: Color(0xFFDC2626), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Immediate Professional Support Needed',
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF991B1B)),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Text(msg.text, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF7F1D1D), height: 1.55)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFCA5A5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🇮🇩 Crisis Hotlines — Indonesia', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF991B1B))),
                  const SizedBox(height: 10),
                  _hotlineRow('☎️', 'Into The Light / Kemenkes', '119 ext 8 (24/7)'),
                  _hotlineRow('☎️', 'Sejiwa Foundation', '119'),
                  _hotlineRow('☎️', 'PDSKJI Helpline', '021-500-454'),
                  _hotlineRow('☎️', 'Yayasan Pulih', '(021) 788-42580'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                icon: const Icon(Icons.medical_services_outlined, size: 18),
                label: Text('Find a Specialist / Psychiatrist', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Visit pdskji.org to locate a certified psychiatrist near you.', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hotlineRow(String emoji, String name, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: kTextDark)),
          Text(number, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
        ]),
      ]),
    );
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('✨', style: TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4)),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [kCardShadow],
          ),
          child: AnimatedBuilder(
            animation: _dotAnim,
            builder: (_, __) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final t = (_dotAnim.value * 3 - i).clamp(0.0, 1.0);
                  final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.translate(
                      offset: Offset(0, -6 * bounce),
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle)),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildQuickReplies() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 44, bottom: 8),
            child: Text('Quick suggestions — tap to start:', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: kTextMuted)),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 44),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickReplies[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: kPrimaryColor.withValues(alpha: 0.4)),
                    boxShadow: const [kCardShadow],
                  ),
                  child: Text(_quickReplies[i], style: GoogleFonts.nunito(fontSize: 13, color: kPrimaryColor, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Gemini Note: Based on our conversation, please consider speaking with a licensed specialist or psychiatrist. You deserve dedicated care 💙',
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF92400E), height: 1.45),
          ),
        ),
      ]),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: const [kCardShadow],
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: kSurfaceLight,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _ctrl,
              maxLines: 3,
              minLines: 1,
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark),
              decoration: InputDecoration(
                hintText: "Talk to Gemini Basic...",
                hintStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: kTextMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _send,
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
