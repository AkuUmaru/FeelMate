import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/pages/dashboard/ai_assistant_screen.dart';
import 'package:myapp/pages/dashboard/emotion_info_screen.dart';
import 'package:myapp/pages/dashboard/impresion.dart';
import 'package:myapp/pages/dashboard/impression_view.dart';
import 'package:myapp/pages/dashboard/input_image.dart';
import 'package:myapp/pages/dashboard/mood_log.dart';
import 'package:myapp/pages/dashboard/profile_screen.dart';
import 'package:myapp/pages/dashboard/resullt.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/utils/colors.dart';

class Db1 extends StatefulWidget {
  const Db1({super.key});

  @override
  State<Db1> createState() => _Db1State();
}

class _Db1State extends State<Db1> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(key: UniqueKey()), // 0
      const EmotionInfoScreen(), // 1
      InputPage(key: UniqueKey(), onFinish: _onClassificationFinish, startWithCamera: true), // 2
      _buildMoodLogPage(), // 3
      const ProfileScreen(), // 4
      Container(), // 5 – ResultPage (lazy)
      Container(), // 6 – ImpressionViewPage (lazy)
      Container(), // 7 – ImpresionPage (lazy)
    ];

    _pages[7] = _buildImpresionPage();
    _pages[3] = _buildMoodLogPage();
  }

  // ─── Builders ──────────────────────────────────────────────────────────────

  Widget _buildMoodLogPage() => MoodLogPage(
        key: UniqueKey(),
        onChoose: (id, emoticon, text, date) => _showImpressionViewPage(
            id: id, emoticon: emoticon, text: text, date: date),
      );

  Widget _buildImpresionPage() => ImpresionPage(
        key: UniqueKey(),
        onSaveComplete: () => setState(() {
          _pages[3] = _buildMoodLogPage();
          _currentIndex = 3;
        }),
      );

  // ─── Callbacks ─────────────────────────────────────────────────────────────

  void _onClassificationFinish(String result) {
    setState(() {
      _pages[5] = ResultPage(key: UniqueKey(), result: result);
      _currentIndex = 5;
    });
  }

  void _showImpressionViewPage(
      {required dynamic id,
      required int emoticon,
      required String text,
      required String date}) {
    void onComplete() => setState(() {
          _pages[3] = _buildMoodLogPage();
          _currentIndex = 3;
        });

    setState(() {
      _pages[6] = ImpressionViewPage(
        key: UniqueKey(),
        id: id,
        emoticon: emoticon,
        text: text,
        date: date,
        onDeleteComplete: onComplete,
      );
      _currentIndex = 6;
    });
  }

  void _navigateTo(int index) {
    setState(() {
      if (index == 0) _pages[0] = HomeContent(key: UniqueKey());
      if (index == 2) {
        _pages[2] = InputPage(
          key: UniqueKey(),
          onFinish: _onClassificationFinish,
          startWithCamera: true,
        );
      }
      if (index == 3) _pages[3] = _buildMoodLogPage();
      if (index == 4) _pages[4] = const ProfileScreen();
      _currentIndex = index;
    });
  }

  // ─── Nav item ──────────────────────────────────────────────────────────────

  Widget _navItem(IconData icon, String label, int index) {
    final active = _currentIndex == index;
    return GestureDetector(
      onTap: () => _navigateTo(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? kPrimaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? kPrimaryColor : const Color(0xFF64748B),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                color: active ? kPrimaryColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: IndexedStack(index: _currentIndex, children: _pages),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            boxShadow: const [kCardShadow],
          ),
          child: SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home_rounded, 'Home', 0),
                      _navItem(Icons.psychology_outlined, 'Emotions', 1),
                      const SizedBox(width: 56),
                      _navItem(Icons.history_rounded, 'Log', 3),
                      _navItem(Icons.person_outline_rounded, 'Me', 4),
                    ],
                  ),
                ),

                // Center FAB — Scan Emotion button
                Positioned(
                  top: -24,
                  child: GestureDetector(
                    onTap: () => _navigateTo(2),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimaryColor, kPrimaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x400D9488),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.center_focus_strong_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Home Content ─────────────────────────────────────────────────────────────

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {

  static const List<Map<String, String>> _quotes = [
    {
      'text': '"Do you ever look at someone and wonder, what is going on inside their head?"',
      'author': 'Joy — Inside Out',
      'char': '⭐',
    },
    {
      'text': '"Crying helps me slow down and feel the emotions that matter."',
      'author': 'Sadness — Inside Out',
      'char': '💙',
    },
    {
      'text': '"All emotions are valuable. Even the uncomfortable ones belong."',
      'author': 'FeelMate',
      'char': '🧠',
    },
    {
      'text': '"Joy and Sadness together make us whole."',
      'author': 'Inside Out',
      'char': '💛',
    },
  ];

  static const List<Map<String, dynamic>> _orbs = [
    {'label': 'Joy',     'emoji': '⭐', 'color': kJoyColor},
    {'label': 'Sadness', 'emoji': '💙', 'color': kSadnessColor},
    {'label': 'Anger',   'emoji': '🔥', 'color': kAngerColor},
    {'label': 'Fear',    'emoji': '💜', 'color': kFearColor},
    {'label': 'Disgust', 'emoji': '💚', 'color': kDisgustColor},
    {'label': 'Bing Bong','emoji': '🎪','color': kSurpriseColor},
    {'label': 'Calm',    'emoji': '😌', 'color': kNeutralColor},
  ];

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  String get _displayName {
    final user = AuthService.currentUser;
    final name = user?.displayName ?? '';
    return name.isNotEmpty ? name.split(' ').first : 'Friend';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _goToPage(int index) {
    final parentState = context.findAncestorStateOfType<_Db1State>();
    if (parentState == null) return;
    parentState._navigateTo(index);
  }

  void _goToWrite() {
    final parentState = context.findAncestorStateOfType<_Db1State>();
    if (parentState == null) return;
    parentState.setState(() {
      parentState._pages[7] = parentState._buildImpresionPage();
      parentState._currentIndex = 7;
    });
  }

  void _goToAiAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Clean Light HQ Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [kCardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: kPrimaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧠', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text('Mind HQ',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: kPrimaryColor)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _goToPage(4),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x330D9488),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _displayName.isNotEmpty
                                ? _displayName[0].toUpperCase()
                                : 'F',
                            style: GoogleFonts.nunito(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$_greeting, $_displayName! ✨',
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kTextDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Which emotion is at the console today?',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextMuted),
                ),
                const SizedBox(height: 22),

                // Memory Orbs Row
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _orbs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, i) {
                      final orb = _orbs[i];
                      final color = orb['color'] as Color;
                      return GestureDetector(
                        onTap: () => _goToPage(2),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  orb['emoji'],
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              orb['label'],
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: color),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Core Memories Quote Carousel ─────────────────────────────
                Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Core Memories',
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kTextDark)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 124,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _quotes.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [kCardShadow],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _quotes[i]['text']!,
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: kTextDark,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_quotes[i]['char']!, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  _quotes[i]['author']!,
                                  style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _quotes.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: _currentPage == i ? 18 : 5,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? kPrimaryColor
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // ── Personality Islands Quick Actions ─────────────────────
                Row(
                  children: [
                    const Text('🏝️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Personality Islands',
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kTextDark)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _IslandCard(
                        emoji: '📸',
                        label: 'Scan\nEmotion',
                        color: kJoyColor,
                        onTap: () => _goToPage(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IslandCard(
                        emoji: '✍️',
                        label: 'Write\nMood',
                        color: kSadnessColor,
                        onTap: _goToWrite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _IslandCard(
                        emoji: '🧠',
                        label: 'Emotion\nGuide',
                        color: kFearColor,
                        onTap: () => _goToPage(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IslandCard(
                        emoji: '📖',
                        label: 'Memory\nLog',
                        color: kDisgustColor,
                        onTap: () => _goToPage(3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // ── Gemini Basic AI Assistant Banner ───────────────────────────────
                GestureDetector(
                  onTap: _goToAiAssistant,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('✨', style: TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gemini Basic AI ✨',
                                style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Talk to Gemini — your safe, empathetic space for simple emotional chats',
                                style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── About FeelMate Card ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [kCardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                            child: Text('🎬', style: TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('About FeelMate',
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: kTextDark)),
                            const SizedBox(height: 2),
                            Text(
                              'AI-powered FER with 7 emotion categories, inspired by Inside Out.',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kTextMuted,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Personality Island Card Widget ───────────────────────────────────────────

class _IslandCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _IslandCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          boxShadow: const [kCardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: kTextDark,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
