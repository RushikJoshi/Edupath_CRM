import 'package:flutter/material.dart';

/// GT CRM Brand Palette
/// Primary : #0D4C7D — Dark Blue (AppBar, NavBar, buttons, headers)
/// Accent  : #45E2C8 — Teal     (FAB, highlights, selected states)
/// BgBlue  : #E5F2FF — Light Blue (scaffold background)
/// BgTeal  : #CCF7F0 — Light Teal (chips, section bg, borders)
class AppColors {
  // ─── Primary ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0D4C7D);
  static const Color primaryDark = Color(0xFF08375C); // darker shade of primary
  static const Color primaryLight = Color(0xFF1A6BAD); // lighter shade of primary
  static const Color primarySurface = Color(0xFFE5F2FF);
  static const Color primaryDarkBlue = Color(0xFF0D4C7D);

  // ─── Accent ──────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF45E2C8);
  static const Color accentDark = Color(0xFF2EC4AC); // darker teal
  static const Color accentLight = Color(0xFFCCF7F0);
  static const Color accentSurface = Color(0xFFCCF7F0);

  // ─── Gradients ───────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [Color(0xFF0D4C7D), Color(0xFF1A6BAD)];
  static const List<Color> splashGradient = [Color(0xFF0D4C7D), Color(0xFF1A6BAD)];
  static const List<Color> dashboardGradient = [Color(0xFF08375C), Color(0xFF0D4C7D)];
  static const List<Color> accentGradient = [Color(0xFF45E2C8), Color(0xFF2EC4AC)];

  // ─── Status ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF45E2C8); // teal = success
  static const Color successLight = Color(0xFFCCF7F0);
  static const Color warning = Color(0xFF1A6BAD); // blue-ish warning
  static const Color warningLight = Color(0xFFE5F2FF);
  static const Color error = Color(0xFFE53935); // solid red for errors
  static const Color errorLight = Color(0xFFFFEBEE); // light red background
  static const Color info = Color(0xFF45E2C8);
  static const Color infoLight = Color(0xFFCCF7F0);
  static const Color wonColor = Color(0xFF45E2C8);
  static const Color lostColor = Color(0xFF0D4C7D);

  // ─── Backgrounds ─────────────────────────────────────────────────────
  static const Color background = Color(0xEFEBF1FD); // page scaffold
  static const Color surfaceWhite = Color(0xFFF5FBFF); // card surface (near-white, very light blue)
  static const Color surfaceCard = Color(0xFFF5FBFF); // same as surfaceWhite
  static const Color surfaceLight = Color(0xFFCCF7F0); // teal section bg

  // ─── Text — proper hierarchy ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0D4C7D); // main headings
  static const Color textSecondary = Color(0xFF2D6EA0); // subtext (lighter blue)
  static const Color textMuted = Color(0xFF6B9AB8); // muted / hint text

  // ─── Borders / Dividers ──────────────────────────────────────────────
  static const Color border = Color(0xFFB8E4F5); // soft teal border
  static const Color divider = Color(0xFFCCF7F0);

  // ─── Stage / Pipeline ────────────────────────────────────────────────
  static const Color stageNew = Color(0xFF45E2C8);
  static const Color stageContacted = Color(0xFF1A6BAD);
  static const Color stageInterested = Color(0xFF0D4C7D);
  static const Color stageFollowUp = Color(0xFF2EC4AC);
  static const Color stageNegotiation = Color(0xFF08375C);
  static const Color stageWon = Color(0xFF45E2C8);
  static const Color stageLost = Color(0xFF0D4C7D);
}
