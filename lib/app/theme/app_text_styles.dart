import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Decorative serif for titles / display / headlines
  static TextStyle get _serifFont => GoogleFonts.playfairDisplay();

  // Clean sans-serif for body / labels / buttons
  static TextStyle get _sansFont => GoogleFonts.plusJakartaSans();

  // ─── Display (Serif) ──────────────────────────────────────────
  static TextStyle displayLarge = _serifFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium = _serifFont.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static TextStyle displaySmall = _serifFont.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ─── Headline (Serif) ─────────────────────────────────────────
  static TextStyle headlineLarge = _serifFont.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle headlineMedium = _serifFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle headlineSmall = _serifFont.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // ─── Title (Serif) ────────────────────────────────────────────
  static TextStyle titleLarge = _serifFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle titleMedium = _serifFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle titleSmall = _sansFont.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ─── Body (Sans-serif) ────────────────────────────────────────
  static TextStyle bodyLarge = _sansFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium = _sansFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall = _sansFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Label (Sans-serif) ───────────────────────────────────────
  static TextStyle labelLarge = _sansFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelMedium = _sansFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static TextStyle labelSmall = _sansFont.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ─── Button (Sans-serif) ──────────────────────────────────────
  static TextStyle button = _sansFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.2,
  );
}
