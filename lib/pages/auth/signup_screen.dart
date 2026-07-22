import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/pages/dashboard/db1.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/utils/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await AuthService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
      if (cred.user != null) {
        await FirestoreService.createUserProfile(
            UserModel.fromFirebaseUser(cred.user!));
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Db1()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Decorative accent
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kPrimaryColor.withValues(alpha: 0.18),
                    kPrimaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: kTextDark, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: kTextDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Join FeelMate and start tracking your emotions',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 32),

                            _label('Display Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameCtrl,
                              textCapitalization: TextCapitalization.words,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: kTextDark),
                              decoration: _inputDec(
                                hint: 'Your full name',
                                icon: Icons.person_outline,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            _label('Email address'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: kTextDark),
                              decoration: _inputDec(
                                hint: 'you@example.com',
                                icon: Icons.email_outlined,
                              ),
                              validator: (v) =>
                                  (v == null || !v.contains('@'))
                                      ? 'Enter a valid email'
                                      : null,
                            ),
                            const SizedBox(height: 18),

                            _label('Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscurePass,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: kTextDark),
                              decoration: _inputDec(
                                hint: 'Min 6 characters',
                                icon: Icons.lock_outline,
                                suffix: _eye(_obscurePass,
                                    () => setState(() => _obscurePass = !_obscurePass)),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Min 6 characters'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            _label('Confirm Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscureConfirm,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: kTextDark),
                              decoration: _inputDec(
                                hint: 'Re-enter password',
                                icon: Icons.lock_outline,
                                suffix: _eye(
                                    _obscureConfirm,
                                    () => setState(() =>
                                        _obscureConfirm = !_obscureConfirm)),
                              ),
                              validator: (v) => v != _passCtrl.text
                                  ? 'Passwords do not match'
                                  : null,
                            ),
                            const SizedBox(height: 36),

                            // Create account button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [kPrimaryColor, kPrimaryDark],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kPrimaryColor.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5),
                                        )
                                      : Text(
                                          'Create Account',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Already have an account?  ',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: 'Sign In',
                                        style: GoogleFonts.poppins(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark));

  Widget _eye(bool obs, VoidCallback toggle) => IconButton(
        icon: Icon(
          obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey.shade400,
          size: 20,
        ),
        onPressed: toggle,
      );

  InputDecoration _inputDec(
      {required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kPrimaryColor, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
    );
  }
}
