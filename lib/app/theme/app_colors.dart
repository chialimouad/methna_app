import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Brand Colors (Rose Pink) ──────────────────────────
  static const Color primary = Color(0xFFE8396B);
  static const Color primaryLight = Color(0xFFFF6B9D);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color primarySurface = Color(0xFFFFF0F3);

  // ─── Secondary / Accent (Deep Plum) ────────────────────────────
  static const Color secondary = Color(0xFF2D2438);
  static const Color secondaryLight = Color(0xFF4A3B5C);
  static const Color secondaryDark = Color(0xFF1A1425);

  // ─── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE8396B), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2D2438), Color(0xFF4A3B5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1425), Color(0xFF2D2438)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE8396B), Color(0xFFFF6B9D), Color(0xFFFFB8D0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [Color(0xFFC2185B), Color(0xFFE8396B), Color(0xFFFF6B9D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ─── Extra Pink Gradients ──────────────────────────────────────
  static const LinearGradient softPinkGradient = LinearGradient(
    colors: [Color(0xFFFFE0E8), Color(0xFFFFF0F3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFE8396B), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient berryGradient = LinearGradient(
    colors: [Color(0xFFC2185B), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF5BA4CF);

  // ─── Neutrals – Light ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFCF8F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1425);
  static const Color textSecondaryLight = Color(0xFF6B5E7B);
  static const Color textHintLight = Color(0xFF9B8FAA);
  static const Color borderLight = Color(0xFFE8DFF0);
  static const Color dividerLight = Color(0xFFF3EEF6);

  // ─── Neutrals – Dark (Deep Plum) ──────────────────────────────
  static const Color backgroundDark = Color(0xFF1A1425);
  static const Color surfaceDark = Color(0xFF2D2438);
  static const Color cardDark = Color(0xFF362D44);
  static const Color textPrimaryDark = Color(0xFFF5F0F8);
  static const Color textSecondaryDark = Color(0xFFBEB0CC);
  static const Color textHintDark = Color(0xFF8A7C9B);
  static const Color borderDark = Color(0xFF4A3B5C);
  static const Color dividerDark = Color(0xFF362D44);

  // ─── Feature Colors ────────────────────────────────────────────
  static const Color like = Color(0xFFE8396B);
  static const Color superLike = Color(0xFFFF6B9D);
  static const Color boost = Color(0xFFFF8A65);
  static const Color pass = Color(0xFF9B8FAA);
  static const Color online = Color(0xFF4CAF50);
  static const Color verified = Color(0xFFE8396B);
  static const Color premium = Color(0xFFFFD700);

  // ─── Islamic / Arabic Aesthetic ───────────────────────────────
  static const Color emerald = Color(0xFFE8396B); // Replaces green with Brand Pink
  static const Color emeraldLight = Color(0xFFFF6B9D);
  static const Color gold = Color(0xFFFFB8C0); // Soft Pink/Rose Gold instead of yellow gold
  static const Color goldLight = Color(0xFFFFF0F3);
  static const Color parchment = Color(0xFFFFF5F7); // Very light pink tint

  static const LinearGradient islamicGradient = LinearGradient(
    colors: [Color(0xFFC2185B), Color(0xFFE8396B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldPremiumGradient = LinearGradient(
    colors: [Color(0xFFE8396B), Color(0xFFFFB8C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
