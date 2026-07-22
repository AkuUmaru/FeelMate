import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';

import 'package:sqflite/sqflite.dart' if (dart.library.html) 'package:myapp/utils/sqflite_stub.dart';
import 'package:path/path.dart' as p;

class ImpresionPage extends StatefulWidget {
  final VoidCallback? onSaveComplete;
  const ImpresionPage({super.key, this.onSaveComplete});

  @override
  State<ImpresionPage> createState() => _ImpresionPageState();
}

class _ImpresionPageState extends State<ImpresionPage> {
  Database? _database;
  final Completer<void> _dbReady = Completer<void>();
  int rating = 1;
  final TextEditingController _textController = TextEditingController();
  String formattedDate = '';
  bool textEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _refreshDate();
    if (!kIsWeb) {
      _initializeDatabase();
    } else {
      _dbReady.complete();
    }
  }

  void _refreshDate() {
    formattedDate = DateTime.now().toIso8601String();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = p.join(await getDatabasesPath(), 'mood_log.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE mood_entries('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'emoticon INTEGER, text TEXT, date TEXT)',
      ),
    );
    await _database!.execute(
      'CREATE TABLE IF NOT EXISTS mood_entries('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'emoticon INTEGER, text TEXT, date TEXT)',
    );
    if (!_dbReady.isCompleted) _dbReady.complete();
  }

  Future<void> _saveMoodEntry() async {
    if (rating == 0 || _textController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an emoji and enter how you feel.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      textEnabled = false;
    });

    try {
      await _dbReady.future;

      _refreshDate();
      final text = _textController.text.trim();
      final date = formattedDate;
      final emoticon = rating;

      if (!kIsWeb && _database != null) {
        await _database!.insert(
          'mood_entries',
          {'emoticon': emoticon, 'text': text, 'date': date},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await FirestoreService.addImpression(
        emoticon: emoticon,
        text: text,
        date: date,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved successfully! ✓')),
      );

      _textController.clear();
      setState(() {
        rating = 1;
        textEnabled = true;
      });
      _refreshDate();

      widget.onSaveComplete?.call();

      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      setState(() => textEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: kAngerColor),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write Mood ✍️',
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Record your daily feelings into your memory diary',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Emoji Feedback Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [kCardShadow],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOW ARE YOU FEELING?',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kTextMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EmojiFeedback(
                      initialRating: rating,
                      emojiPreset: handDrawnEmojiPreset,
                      labelTextStyle: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kTextMuted,
                      ),
                      onChanged: (value) =>
                          setState(() => rating = value ?? 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Text Entry Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [kCardShadow],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR THOUGHTS & DIARY',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kTextMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _textController,
                      enabled: textEnabled,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
                        height: 1.55,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'How is your day going? What has affected your mood today?...',
                        hintStyle: GoogleFonts.nunito(
                            fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMoodEntry,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Entry',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
