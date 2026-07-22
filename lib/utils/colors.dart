import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  FeelMate Clean & Easy-on-the-Eyes Color System (Inside Out Theme)
//  Designed for maximum text legibility, high contrast, and soft visual comfort.
// ══════════════════════════════════════════════════════════════════════════════

/// Soft, soothing light background (Easy on the eyes)
const Color kBackgroundColor = Color(0xFFF8FAFC);

/// Clean card & modal surface
const Color kSurfaceColor = Color(0xFFFFFFFF);

/// Elevated/secondary light container surface
const Color kSurfaceLight = Color(0xFFF1F5F9);

// ─── Primary Brand Colors ───────────────────────────────────────────────────
/// Primary action color — Warm Emerald / Mint (gentle, high contrast)
const Color kPrimaryColor = Color(0xFF0D9488);

/// Slightly deeper shade for gradients & pressed states
const Color kPrimaryDark = Color(0xFF0F766E);

/// Light primary tint for soft highlights
const Color kPrimaryLight = Color(0xFFCCFBF1);

/// Primary glow effect
const Color kPrimaryGlow = Color(0x330D9488);

// ─── High Contrast Text Colors ───────────────────────────────────────────────
/// Deep Slate for main headers and body text — 100% crisp legibility
const Color kTextDark = Color(0xFF0F172A);

/// Muted Slate for subtitles — passes WCAG AA contrast against white/light bg
const Color kTextMuted = Color(0xFF475569);

/// White text for dark buttons and headers
const Color kWhiteColor = Colors.white;

// ─── Inside Out Character Emotion Accent Colors ──────────────────────────────
/// 😊 Happy → Joy (Amber Yellow)
const Color kJoyColor      = Color(0xFFD97706);

/// 😢 Sad → Sadness (Sky Blue)
const Color kSadnessColor  = Color(0xFF2563EB);

/// 😠 Angry → Anger (Crimson Red)
const Color kAngerColor    = Color(0xFFDC2626);

/// 😨 Fear → Fear (Soft Purple)
const Color kFearColor     = Color(0xFF7C3AED);

/// 🤮 Disgust → Disgust (Fresh Green)
const Color kDisgustColor  = Color(0xFF059669);

/// 😲 Surprise → Bing Bong (Bubblegum Pink)
const Color kSurpriseColor = Color(0xFFDB2777);

/// 😐 Neutral → Riley Calm (Cool Slate)
const Color kNeutralColor  = Color(0xFF475569);

// ─── Soft Shadows & Borders ──────────────────────────────────────────────────
/// Easy-on-the-eyes subtle card shadow
const BoxShadow kCardShadow = BoxShadow(
  color: Color(0x0F0F172A),
  blurRadius: 16,
  offset: Offset(0, 4),
);

/// Soft border for clean container framing
final Border kSoftBorder = Border.all(
  color: const Color(0xFFE2E8F0),
  width: 1.0,
);
