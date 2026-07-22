import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/pages/dashboard/emotional_logs_screen.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:sqflite/sqflite.dart' if (dart.library.html) 'package:myapp/utils/sqflite_stub.dart';
import 'package:path/path.dart' as p;

/// Combined Log screen with two tabs:
///  - Mood Diary (SQLite / Firestore impression logs)
///  - Emotion Log (Firestore classification history)
class MoodLogPage extends StatefulWidget {
  final Function(dynamic id, int emoticon, String text, String date)? onChoose;
  final Function(dynamic id)? onDelete;

  const MoodLogPage({super.key, this.onChoose, this.onDelete});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Database? _database;
  List<Map<String, dynamic>> _moodEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (!kIsWeb) {
      _initDb();
    } else {
      _loadMoodEntries();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initDb() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'mood_log.db'),
      version: 1,
    );
    _loadMoodEntries();
  }

  Future<void> _loadMoodEntries() async {
    if (kIsWeb) {
      try {
        final entries = await FirestoreService.getImpressions();
        if (!mounted) return;
        setState(() {
          _moodEntries = entries
            ..sort((a, b) =>
                DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
      } catch (_) {}
      return;
    }
    if (_database == null) return;
    final entries = await _database!.query('mood_entries');
    if (!mounted) return;
    setState(() {
      _moodEntries = List<Map<String, dynamic>>.from(entries)
        ..sort((a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    });
  }

  Future<void> _deleteEntry(dynamic id) async {
    if (!kIsWeb && _database != null) {
      final intId = id is int ? id : int.tryParse(id?.toString() ?? '');
      if (intId != null) {
        await _database!
            .delete('mood_entries', where: 'id = ?', whereArgs: [intId]);
      }
    }
    await FirestoreService.deleteImpression(id.toString());
    _loadMoodEntries();
  }

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
              child: Text(
                'History & Logs 📖',
                style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: kTextDark),
              ),
            ),
            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [kCardShadow],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: kTextMuted,
                  labelStyle: GoogleFonts.nunito(
                      fontSize: 13, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: GoogleFonts.nunito(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Mood Diary'),
                    Tab(text: 'Emotion Scans'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MoodDiaryTab(
                    entries: _moodEntries,
                    onChoose: widget.onChoose,
                    onDelete: _deleteEntry,
                  ),
                  const EmotionalLogsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mood Diary Tab ───────────────────────────────────────────────────────────

class _MoodDiaryTab extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final Function(dynamic id, int emoticon, String text, String date)? onChoose;
  final Function(dynamic id)? onDelete;

  const _MoodDiaryTab(
      {required this.entries, this.onChoose, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No diary entries yet',
                style: GoogleFonts.nunito(
                    color: kTextMuted, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Tap "Write Mood" on the home screen',
                style: GoogleFonts.nunito(
                    color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final entry = entries[i];
        final dynamic id = entry['id'] ?? i;
        return Dismissible(
          key: ValueKey(id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 28),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: ctx,
              builder: (d) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text('Delete Entry',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: kTextDark)),
                content: Text(
                  'Remove this diary entry? This cannot be undone.',
                  style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(d, false),
                      child: Text('Cancel',
                          style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w700))),
                  TextButton(
                      onPressed: () => Navigator.pop(d, true),
                      child: Text('Delete',
                          style: GoogleFonts.nunito(
                              color: const Color(0xFFDC2626),
                              fontWeight: FontWeight.w800))),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) => onDelete?.call(id),
          child: GestureDetector(
            onTap: () => onChoose?.call(
                id,
                (entry['emoticon'] as num?)?.toInt() ?? 0,
                entry['text'] as String? ?? '',
                entry['date'] as String? ?? ''),
            child: _MoodCard(entry: entry),
          ),
        );
      },
    );
  }
}

class _MoodCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _MoodCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final emoticonIndex = (entry['emoticon'] as num?)?.toInt() ?? 0;
    final emojis = ['😢', '😞', '😐', '🙂', '😁'];
    String dateStr = '';
    try {
      dateStr = DateFormat('MMM d, yyyy · HH:mm')
          .format(DateTime.parse(entry['date'] as String));
    } catch (_) {
      dateStr = entry['date']?.toString() ?? '';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [kCardShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emojis[emoticonIndex.clamp(0, 4)],
            style: const TextStyle(fontSize: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['text'] as String? ?? '',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                      height: 1.45),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: kTextMuted,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
