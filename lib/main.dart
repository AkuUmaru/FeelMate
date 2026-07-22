import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/blocs/auth/auth_bloc.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/pages/auth/splash_screen.dart';
import 'package:myapp/repositories/auth_repository.dart';
import 'package:myapp/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark icons for clean light background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthRepository(),
      child: BlocProvider(
        create: (ctx) => AuthBloc(
          authRepository: ctx.read<AuthRepository>(),
        )..add(const AuthStarted()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FeelMate',
          theme: _buildTheme(),
          home: const SplashScreen(),
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        brightness: Brightness.light,
        primary: kPrimaryColor,
        secondary: kSurpriseColor,
        surface: kSurfaceColor,
      ),
      scaffoldBackgroundColor: kBackgroundColor,
    );

    return base.copyWith(
      // Nunito — high legibility, clean rounded letterforms
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: kTextDark,
        displayColor: kTextDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: kTextDark,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white, // Crisp white text on primary
          elevation: 0,
          shadowColor: kPrimaryGlow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.nunito(color: Colors.grey.shade400, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kAngerColor, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: kTextDark,
        contentTextStyle: GoogleFonts.nunito(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.nunito(
            fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark),
        contentTextStyle: GoogleFonts.nunito(fontSize: 14, color: kTextMuted),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: kPrimaryColor,
        unselectedLabelColor: kTextMuted,
        labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
