import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/groq_service.dart';
import 'package:myapp/utils/colors.dart';

// ─── Message model ──────────────────────────────────────────────────────────

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

// ─── AI Assistant Screen ───────────────────────────────────────────────────

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
    'Aku merasa cemas akhir-akhir ini',
    'Aku lagi stres banget',
    'Rasanya sedih dan lelah',
    'Susah tidur belakangan ini',
    'Pengen ngobrol santai aja',
    'Merasa sendirian',
  ];

  static const _crisisKw = [
    'suicide', 'suicidal', 'kill myself', 'end my life', 'want to die',
    'no reason to live', 'better off dead', 'take my own life', 'self harm',
    'hurt myself', "can't live anymore", 'wish i was dead', 'bunuh diri',
    'mati aja', 'mengakhiri hidup', 'melukai diri', 'mau mati', 'nyerah hidup',
  ];
  static const _highStressKw = [
    'overwhelmed', 'panic attack', "can't cope", 'breaking down', 'burnout',
    'completely exhausted', "can't go on", 'no hope', 'nothing matters',
    'pointless', 'hopeless', 'worthless', "can't take it", 'falling apart',
    'give up', 'kewalahan', 'panik', 'beban berat', 'putus asa', 'capek batin',
  ];
  static const _sadKw = [
    'sad', 'cry', 'crying', 'depressed', 'depression', 'unhappy', 'lonely',
    'alone', 'empty', 'grief', 'heartbreak', 'heartbroken', 'miserable',
    'down', 'blue', 'gloomy', 'tearful', 'devastated', 'sedih', 'nangis',
    'menangis', 'hampa', 'kecewa', 'patah hati', 'kesepian',
  ];
  static const _anxietyKw = [
    'anxious', 'anxiety', 'worried', 'worry', 'nervous', 'scared', 'fear',
    'afraid', 'panic', 'stress', 'stressed', 'tense', 'dread', 'uneasy',
    'restless', 'overthinking', 'cemas', 'takut', 'khawatir', 'was-was',
    'gugup', 'stres',
  ];
  static const _angerKw = [
    'angry', 'anger', 'furious', 'rage', 'frustrated', 'frustration', 'mad',
    'annoyed', 'irritated', 'livid', 'enraged', 'upset', 'marah', 'kesal',
    'emosi', 'jengkel', 'frustrasi',
  ];
  static const _positiveKw = [
    'happy', 'great', 'good', 'amazing', 'wonderful', 'joy', 'joyful',
    'excited', 'grateful', 'thankful', 'blessed', 'fantastic', 'awesome',
    'better', 'improving', 'hopeful', 'okay', 'fine', 'alright', 'senang',
    'bahagia', 'lega', 'bersyukur', 'semangat', 'tenang',
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
          text:
              "Hai! Aku FeelMate AI Companion ✨\n\nAku di sini sebagai sahabat yang siap mendengarkan ceritamu dengan hangat, aman, dan tanpa penghakiman.\n\nBagaimana perasaanmu hari ini? Ada hal yang ingin kamu ceritakan?",
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

  String _generateFallbackResponse(String userMsg) {
    final alwaysRef = _distressCount >= 3;
    const ref =
        "\n\n💙 FeelMate Note: Karena beban perasaanmu tampak cukup berat, jangan ragu untuk berbagi dengan konselor, psikolog, atau orang terdekat yang kamu percaya.";

    if (_containsAny(userMsg, _highStressKw)) {
      final list = [
        "Aku mengerti betapa berat dan melelahkannya situasi ini bagimu ✨. Tarik napas perlahan bersamaku yuk.\n\nTarik napas dalam → hembuskan perlahan 🌿.\n\nKamu tidak harus menyelesaikan semuanya sekaligus hari ini. Apa satu hal kecil yang paling membebanimu saat ini?",
        "Membawa beban seberat ini sendirian pasti sangat menguras energimu. Aku di sini menemanimu dan mendengarkan dengan tulus.\n\nMau ceritakan sedikit lagi tentang apa yang sedang kamu rasakan?",
        "Saat semua hal terasa menumpuk, sangat wajar jika kamu merasa lelah. Bersikaplah lembut pada dirimu sendiri hari ini ya.\n\nApa hal kecil yang bisa membuat harimu terasa sedikit lebih ringan?",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : "\n\n💡 Ingat: Luangkan waktu untuk istirahat sejenak, kesehatan mentalmu sangat berharga.");
    }

    if (_containsAny(userMsg, _sadKw)) {
      final list = [
        "Aku kirimkan pelukan hangat untukmu ✨. Sangat wajar untuk merasa sedih atau ingin menangis — emosi hadir untuk dirasakan dan akan berlalu perlahan.\n\nApakah kamu ingin menceritakan apa yang membuatmu bersedih?",
        "Terima kasih sudah mau berbagi cerita denganku. Perasaanmu valid dan pantas mendapatkan ruang yang nyaman.\n\nHal lembut apa yang bisa kamu lakukan untuk dirimu sekarang, seperti minum teh hangat atau beristirahat sejenak?",
        "Rasa sedih sering kali menandakan ada hal yang sangat berharga bagimu. Aku di sini mendengarkan — ambil waktu sebanyak yang kamu butuhkan ya.",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : '');
    }

    if (_containsAny(userMsg, _anxietyKw)) {
      final list = [
        "Rasa cemas bisa membuat pikiran kita berlari cepat dan bising ✨. Mari kita lakukan grounding sederhana bersama.\n\nCoba lihat sekelilingmu dan sebutkan 3 benda sederhana yang kamu lihat. Aku ada di sini bersamamu.",
        "Wajar untuk merasa was-was atau tidak tenang. Pikiranmu sedang berusaha melindungimu, meskipun rasanya tidak nyaman.\n\nApa kekhawatiran utama yang paling berputar di kepalamu saat ini?",
        "Tarik napas perlahan bersamaku 🌿. Di obrolan ini kamu aman. Mari kita urai hal yang membuatmu cemas satu per satu secara perlahan.",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : '');
    }

    if (_containsAny(userMsg, _angerKw)) {
      final list = [
        "Aku paham rasa kesal dan frustrasi yang kamu alami ✨. Marah adalah tanda ada batasan atau hal penting yang terganggu bagimu.\n\nKeluarkan saja apa yang ingin kamu ceritakan, aku mendengarkan tanpa menghakimi.",
        "Situasi seperti itu memang bisa membuat emosi memuncak. Tidak apa-apa merasa kesal — mari kita beri ruang agar perasaanmu perlahan mereda.\n\nApa pemicu utama yang membuatmu merasa sangat marah hari ini?",
      ];
      final r = list[DateTime.now().millisecond % list.length];
      return r + (alwaysRef ? ref : '');
    }

    if (_containsAny(userMsg, _positiveKw)) {
      final list = [
        "Senang sekali mendengarnya! ✨ Momen menyenangkan apa yang membuat harimu terasa indah hari ini?",
        "Alhamdulillah, ikut bahagia mendengarnya! 🌟 Merayakan kabar baik dan perasaan bahagia itu sangat penting. Ceritakan lebih banyak dong!",
        "Luar biasa! Merasakan sukacita memberi kita energi positif baru. Apa yang berjalan lancar hari ini?",
      ];
      return list[DateTime.now().millisecond % list.length];
    }

    final defaults = [
      "Aku mendengarkan dengan penuh perhatian ✨. Ceritakan lebih lanjut apa yang sedang ada di benakmu sekarang ya.",
      "Terima kasih sudah terbuka dan bercerita padaku! Aku selalu ada di sini kapan pun kamu butuh teman mengobrol.",
      "Tampaknya ada banyak hal yang kamu rasakan hari ini. Pelan-pelan saja — apa yang paling ingin kamu sampaikan?",
      "Senang bisa mengobrol denganmu. Bagaimana harimu berjalan sejauh ini?",
    ];
    return defaults[DateTime.now().millisecond % defaults.length] + (alwaysRef ? ref : '');
  }

  void _send([String? quickReply]) async {
    final text = (quickReply ?? _ctrl.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _msgs.add(_Msg(text: text, isUser: true));
      _ctrl.clear();
      _typing = true;
      _showQuickReplies = false;
    });
    _scrollToBottom();

    // 1. Immediate Safety Check: Crisis keywords trigger hotlines directly
    if (_containsAny(text, _crisisKw)) {
      _distressCount += 3;
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _typing = false;
        _msgs.add(_Msg(
          text:
              "Aku sangat peduli dan prihatin dengan rasa sakit yang kamu rasakan saat ini ✨.\n\nKetahuilah bahwa hidupmu sangat berharga dan kamu tidak harus menanggung semua ini sendirian. Aku sangat menyarankanmu untuk segera menghubungi layanan konseling krisis atau profesional kesehatan sekarang.",
          isUser: false,
          isCrisis: true,
        ));
      });
      _scrollToBottom();
      return;
    }

    // 2. Track emotional indicators for supportive care
    if (_containsAny(text, _highStressKw)) {
      _distressCount += 2;
    } else if (_containsAny(text, _sadKw) ||
        _containsAny(text, _anxietyKw) ||
        _containsAny(text, _angerKw)) {
      _distressCount += 1;
    }

    // 3. Dynamic LLM Response via Groq Cloud
    try {
      final history = <Map<String, String>>[];
      for (final m in _msgs.reversed) {
        if (m.isCrisis) continue;
        history.insert(0, {
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.text,
        });
        if (history.length >= 8) break;
      }

      final aiReply = await GroqService.getReply(history);
      if (!mounted) return;

      setState(() {
        _typing = false;
        _msgs.add(_Msg(text: aiReply, isUser: false));
      });
      _scrollToBottom();
    } catch (_) {
      // 4. Graceful Fallback to offline rule-based response
      if (!mounted) return;
      final fallbackReply = _generateFallbackResponse(text);
      setState(() {
        _typing = false;
        _msgs.add(_Msg(text: fallbackReply, isUser: false));
      });
      _scrollToBottom();
    }
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
                    Text('FeelMate AI', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: kTextDark)),
                    Row(children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Empathetic Companion • Online', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
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
                child: Text('Groq AI', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: kPrimaryColor)),
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
                  'Bantuan Profesional & Dukungan Krisis',
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
                  Text('🇮🇩 Hotline Bantuan Krisis — Indonesia', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF991B1B))),
                  const SizedBox(height: 10),
                  _hotlineRow('☎️', 'Kemenkes Sejiwa', '119 ext 8 (24 Jam Bebas Pulsa)'),
                  _hotlineRow('☎️', 'LISA Suicide Prevention', '0811-3855-472 (24 Jam)'),
                  _hotlineRow('☎️', 'PDSKJI Helpline', '021-500-454'),
                  _hotlineRow('☎️', 'Yayasan Pulih Konseling', '(021) 788-42580'),
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
                label: Text('Informasi Psikolog & Psikiater (PDSKJI)', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Kunjungi pdskji.org untuk informasi psikiater & fasilitas kesehatan mental terdekat.', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600)),
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
            child: Text('Saran cepat — ketuk untuk memulai:', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: kTextMuted)),
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
            'Catatan FeelMate: Berdasarkan obrolan kita, jangan ragu untuk berkonsultasi dengan psikolog atau konselor profesional ya. Kamu berhak mendapatkan pendampingan terbaik 💙',
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
                hintText: "Ceritakan apa yang kamu rasakan...",
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
