import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/emotional_log_model.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/emotion_data.dart';

class EmotionalLogsScreen extends StatefulWidget {
  const EmotionalLogsScreen({super.key});

  @override
  State<EmotionalLogsScreen> createState() => _EmotionalLogsScreenState();
}

class _EmotionalLogsScreenState extends State<EmotionalLogsScreen> {
  void _showStats(List<EmotionalLogModel> logs) {
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to display yet.')),
      );
      return;
    }

    final total = logs.length;
    final avgConf =
        logs.fold(0.0, (s, l) => s + l.confidence) / total;
    final freq = <String, int>{};
    for (final l in logs) {
      freq[l.emotion] = (freq[l.emotion] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmotion = sorted.first.key;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatsSheet(
        total: total,
        avgConf: avgConf,
        topEmotion: topEmotion,
        freq: freq,
      ),
    );
  }

  Future<void> _deleteLog(String id) async {
    await FirestoreService.deleteEmotionalLog(id);
  }

  Future<void> _clearAll(List<EmotionalLogModel> logs) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear All Logs',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: kTextDark)),
        content: Text(
          'This will permanently delete all ${logs.length} emotion scan records. Are you sure?',
          style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear All',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    for (final log in logs) {
      await FirestoreService.deleteEmotionalLog(log.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emotion Scans 📸',
                            style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: kTextDark)),
                        Text('Facial emotion recognition history',
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kTextMuted)),
                      ],
                    ),
                  ),
                  StreamBuilder<List<EmotionalLogModel>>(
                    stream: FirestoreService.emotionalLogsStream(),
                    builder: (ctx, snap) {
                      final logs = snap.data ?? [];
                      return Row(
                        children: [
                          if (logs.isNotEmpty)
                            IconButton(
                              onPressed: () => _clearAll(logs),
                              icon: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFFCA5A5), width: 1),
                                ),
                                child: const Icon(Icons.delete_sweep_rounded,
                                    color: Color(0xFFDC2626), size: 20),
                              ),
                              tooltip: 'Clear All',
                            ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () => _showStats(logs),
                            icon: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.bar_chart_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            tooltip: 'Statistics',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Log list
            Expanded(
              child: StreamBuilder<List<EmotionalLogModel>>(
                stream: FirestoreService.emotionalLogsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: kPrimaryColor));
                  }
                  final logs = snapshot.data ?? [];
                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sentiment_neutral_rounded,
                              size: 72,
                              color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No emotion scan logs yet',
                              style: GoogleFonts.nunito(
                                  color: kTextMuted,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Scan a face expression to get started',
                              style: GoogleFonts.nunito(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final log = logs[i];
                      return _LogCard(
                        log: log,
                        onDelete: () => _deleteLog(log.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Log Card ────────────────────────────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final EmotionalLogModel log;
  final VoidCallback onDelete;

  const _LogCard({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final info = emotionInfoFor(log.emotion);
    final pct = (log.confidence * 100).toStringAsFixed(1);
    final dateStr = DateFormat('MMM d, yyyy · HH:mm').format(log.timestamp);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [kCardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: info.color.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(info.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        info.name,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: kTextDark),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${info.character})',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: info.color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: log.confidence,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(info.color),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$pct%',
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: info.color)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(dateStr,
                      style: GoogleFonts.nunito(
                          fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 22, color: Color(0xFFDC2626)),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Delete Log',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w900, color: kTextDark)),
                    content: Text('Remove this emotion log entry?',
                        style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel', style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w700))),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Delete',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFFDC2626), fontWeight: FontWeight.w800))),
                    ],
                  ),
                );
                if (ok == true) onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Bottom Sheet ───────────────────────────────────────────────────────

class _StatsSheet extends StatelessWidget {
  final int total;
  final double avgConf;
  final String topEmotion;
  final Map<String, int> freq;

  const _StatsSheet({
    required this.total,
    required this.avgConf,
    required this.topEmotion,
    required this.freq,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topInfo = emotionInfoFor(topEmotion);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ListView(
          controller: ctrl,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Emotion Analytics 📊',
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: kTextDark)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                    child: _miniStat(
                        '$total', 'Total\nScans', Icons.analytics_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniStat('${(avgConf * 100).toStringAsFixed(1)}%',
                        'Avg\nConfidence', Icons.speed_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniStat(
                        '${topInfo.emoji}\n$topEmotion',
                        'Top\nEmotion',
                        Icons.emoji_emotions_rounded)),
              ],
            ),
            const SizedBox(height: 24),

            Text('Emotion Breakdown',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: kTextDark)),
            const SizedBox(height: 14),

            ...sorted.map((entry) {
              final info = emotionInfoFor(entry.key);
              final frac = total > 0 ? entry.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(info.emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: Text(info.name,
                          style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: frac,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(info.color),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 32,
                      child: Text('${entry.value}',
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: info.color)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryColor, size: 24),
          const SizedBox(height: 6),
          Text(value,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kTextDark)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted)),
        ],
      ),
    );
  }
}
