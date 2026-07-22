import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:sqflite/sqflite.dart'
    if (dart.library.html) 'package:myapp/utils/sqflite_stub.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';

class ImpressionViewPage extends StatefulWidget {
  final dynamic id;
  final int emoticon;
  final String text;
  final String date;
  final VoidCallback? onDeleteComplete;

  const ImpressionViewPage({
    super.key,
    required this.id,
    required this.emoticon,
    required this.text,
    required this.date,
    this.onDeleteComplete,
  });

  @override
  State<ImpressionViewPage> createState() => _ImpressionViewPageState();
}

class _ImpressionViewPageState extends State<ImpressionViewPage> {
  bool _isEditing = false;
  bool _isSaving = false;
  late int _editRating;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editRating = widget.emoticon;
    _editController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('MMM d, yyyy · HH:mm').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  Future<void> _saveEdit() async {
    final newText = _editController.text.trim();
    if (newText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text cannot be empty.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (!kIsWeb) {
        final intId = widget.id is int ? widget.id : int.tryParse(widget.id.toString());
        if (intId != null) {
          final dbPath = p.join(await getDatabasesPath(), 'mood_log.db');
          final db = await openDatabase(dbPath);
          await db.update(
            'mood_entries',
            {'emoticon': _editRating, 'text': newText},
            where: 'id = ?',
            whereArgs: [intId],
          );
        }
      }

      await FirestoreService.updateImpression(
        id: widget.id.toString(),
        emoticon: _editRating,
        text: newText,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully ✓')),
      );
      setState(() => _isEditing = false);
      widget.onDeleteComplete?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: kAngerColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteEntry() async {
    if (!kIsWeb) {
      final intId = widget.id is int ? widget.id : int.tryParse(widget.id.toString());
      if (intId != null) {
        final dbPath = p.join(await getDatabasesPath(), 'mood_log.db');
        final db = await openDatabase(dbPath);
        await db.delete('mood_entries', where: 'id = ?', whereArgs: [intId]);
      }
    }
    await FirestoreService.deleteImpression(widget.id.toString());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry deleted successfully!')),
    );
    widget.onDeleteComplete?.call();
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Entry',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: kTextDark)),
        content: Text(
          'Are you sure you want to delete this entry?\nThis cannot be undone.',
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
            child: Text('Delete',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) await _deleteEntry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [kCardShadow],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextDark, size: 20),
                    onPressed: widget.onDeleteComplete,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Edit Mood Entry ✍️' : 'Mood Entry 📖',
                          style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: kTextDark),
                        ),
                        Text(
                          _formatDate(widget.date),
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kTextMuted),
                        ),
                      ],
                    ),
                  ),
                  if (!_isEditing)
                    _headerIconBtn(
                      Icons.edit_outlined,
                      kPrimaryColor,
                      () => setState(() {
                        _isEditing = true;
                        _editController.text = widget.text;
                        _editRating = widget.emoticon;
                      }),
                    ),
                  if (_isEditing)
                    _headerIconBtn(Icons.close_rounded, const Color(0xFFDC2626),
                        () => setState(() => _isEditing = false)),
                  const SizedBox(width: 6),
                  _headerIconBtn(Icons.delete_outline_rounded, const Color(0xFFDC2626), _confirmDelete),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      title: 'MOOD RATING',
                      child: EmojiFeedback(
                        initialRating: (_isEditing ? _editRating : widget.emoticon) + 1,
                        emojiPreset: handDrawnEmojiPreset,
                        labelTextStyle: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kTextMuted),
                        onChanged: _isEditing
                            ? (v) => setState(() => _editRating = (v ?? 1) - 1)
                            : (_) {},
                      ),
                    ),
                    const SizedBox(height: 16),

                    _sectionCard(
                      title: 'HOW I FELT',
                      child: _isEditing
                          ? TextField(
                              controller: _editController,
                              maxLines: 6,
                              style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: kTextDark,
                                  height: 1.55),
                              decoration: InputDecoration(
                                hintText: 'Write how you felt...',
                                hintStyle: GoogleFonts.nunito(
                                    color: Colors.grey.shade400),
                                border: InputBorder.none,
                              ),
                            )
                          : Text(
                              widget.text,
                              style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: kTextDark,
                                  height: 1.55),
                            ),
                    ),
                    const SizedBox(height: 28),

                    if (_isEditing) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveEdit,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Icon(Icons.save_rounded, color: Colors.white),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save Changes',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Cancel',
                              style: GoogleFonts.nunito(
                                  color: kTextMuted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: widget.onDeleteComplete,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          label: Text('Back to History',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                            side: const BorderSide(color: kPrimaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: kTextMuted,
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
