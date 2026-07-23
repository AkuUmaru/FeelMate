import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/emotional_log_model.dart';
import 'package:myapp/pages/auth/login_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/emotion_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalLogs = 0;
  String _mostCommon = '—';
  bool _loadingStats = true;
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final logs = await FirestoreService.getAllLogs();
    if (!mounted) return;
    setState(() {
      _totalLogs = logs.length;
      _mostCommon = _computeMostCommon(logs);
      _loadingStats = false;
    });
  }

  String _computeMostCommon(List<EmotionalLogModel> logs) {
    if (logs.isEmpty) return '—';
    final freq = <String, int>{};
    for (final l in logs) {
      freq[l.emotion] = (freq[l.emotion] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: kTextDark)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFDC2626), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = user?.displayName ?? 'FeelMate Friend';
    final email = user?.email ?? 'umaru.bangkit@gmail.com';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'F';
    final topInfo =
        _mostCommon != '—' ? emotionInfoFor(_mostCommon) : null;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Clean White Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
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
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x330D9488),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.nunito(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: kTextDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MY EMOTIONAL SUMMARY',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kTextMuted,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Total Scans',
                            value: _loadingStats ? '...' : '$_totalLogs',
                            icon: Icons.analytics_rounded,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            title: 'Dominant Emotion',
                            value: _loadingStats
                                ? '...'
                                : topInfo != null
                                    ? '${topInfo.emoji} ${topInfo.name}'
                                    : '—',
                            icon: Icons.psychology_rounded,
                            color: topInfo?.color ?? kTextMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text('SETTINGS & ACCOUNT',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kTextMuted,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [kCardShadow],
                      ),
                      child: Column(
                        children: [
                          _settingTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Daily Reminders',
                            subtitle: 'Remind me to check in with my emotions',
                            trailing: Switch.adaptive(
                              value: _notificationsOn,
                              activeThumbColor: kPrimaryColor,
                              activeTrackColor: kPrimaryColor.withValues(alpha: 0.5),
                              onChanged: (v) =>
                                  setState(() => _notificationsOn = v),
                            ),
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFE2E8F0)),
                          _settingTile(
                            icon: Icons.shield_outlined,
                            title: 'Privacy & Data Safe',
                            subtitle: 'Your emotions stay private to you',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Your privacy is our priority. Emotion data is secured locally & in Firebase.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout_rounded,
                            color: Color(0xFFDC2626), size: 20),
                        label: Text('Sign Out',
                            style: GoogleFonts.nunito(
                                color: const Color(0xFFDC2626),
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFFCA5A5), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [kCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: kTextDark)),
          const SizedBox(height: 2),
          Text(title,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextMuted)),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kPrimaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kPrimaryColor, size: 22),
      ),
      title: Text(title,
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: kTextDark)),
      subtitle: Text(subtitle,
          style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextMuted)),
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}
