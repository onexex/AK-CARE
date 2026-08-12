import 'package:flutter/material.dart';

/// Drop-in replacement for AppColors that reads from the current theme.
/// Use this instead of AppColors for surface/background/neutral colors
/// to enable full dark mode support.
class ThemeColors {
  final ColorScheme cs;
  final bool isDark;

  const ThemeColors._(this.cs, this.isDark);

  factory ThemeColors.of(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ThemeColors._(cs, cs.brightness == Brightness.dark);
  }

  // ── Surface colors (theme-aware) ──
  Color get surface => cs.surface;
  Color get scaffoldBg => isDark ? const Color(0xFF121218) : const Color(0xFFF5F7FA);
  Color get neutral10 => isDark ? const Color(0xFF2A2A3A) : const Color(0xFFF8F9FA);
  Color get neutral20 => isDark ? const Color(0xFF333345) : const Color(0xFFF1F3F5);
  Color get neutral30 => isDark ? const Color(0xFF404050) : const Color(0xFFE9ECEF);
  Color get neutral50 => isDark ? const Color(0xFF8888A0) : const Color(0xFFCED4DA);
  Color get neutral60 => isDark ? const Color(0xFF9999B0) : const Color(0xFFADB5BD);
  Color get neutral70 => isDark ? const Color(0xFFBBBBC8) : const Color(0xFF6C757D);
  Color get neutral80 => isDark ? const Color(0xFFCCCCD5) : const Color(0xFF495057);
  Color get neutral90 => isDark ? const Color(0xFFDDDDEE) : const Color(0xFF343A40);
  Color get neutral100 => isDark ? const Color(0xFFEEEEFF) : const Color(0xFF212529);

  // ── Fixed brand colors (same in both modes) ──
  Color get primary => cs.primary;
  Color get primaryLight => const Color(0xFF4CAF42);
  Color get primarySurface => isDark ? const Color(0xFF1A3A1A) : const Color(0xFFE8F5E7);

  /// Deep teal is a *dark* brand colour, so at full strength it is unreadable
  /// on a dark surface (1.67:1). Dark mode gets the light teal from the same
  /// family instead, which keeps the identity and reaches 6.72:1.
  Color get deepTeal => isDark ? const Color(0xFF4DB6AC) : const Color(0xFF004D40);
  Color get deepTealLight => isDark ? const Color(0xFF1A3A3A) : const Color(0xFFE0F2F1);

  // ── Text-safe variants ──
  //
  // The colours above are *fills* — chips, icons, badges, buttons — and are
  // tuned to look right as blocks of colour. Several of them fail WCAG AA when
  // used as text: warning on its own tint is 1.53:1, neutral60 on white 2.07:1.
  //
  // These variants are the same hues darkened (light mode) or lightened (dark)
  // until they clear 4.5:1 against surface, scaffold and their own tint. Use
  // them wherever the colour carries words; keep the originals for fills.

  /// Secondary/caption text. Replaces neutral60, which is a border tone.
  Color get textSecondary => isDark ? const Color(0xFF9999B0) : const Color(0xFF646C73);

  /// Tertiary text — timestamps, ids. Still AA; never lighter than this.
  Color get textMuted => isDark ? const Color(0xFF8888A0) : const Color(0xFF6C757D);

  Color get primaryText => isDark ? const Color(0xFF4CAF42) : const Color(0xFF1A7A12);
  Color get successText => isDark ? const Color(0xFF3DD35C) : const Color(0xFF1E7E34);
  Color get warningText => isDark ? const Color(0xFFFFC107) : const Color(0xFF8A6100);
  Color get errorText => isDark ? const Color(0xFFE4606D) : const Color(0xFFC82333);
  Color get infoText => isDark ? const Color(0xFF17A2B8) : const Color(0xFF0F6C7B);
  Color get error => cs.error;
  Color get errorSurface => isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFF0F0);
  Color get warning => const Color(0xFFFFC107);
  Color get warningSurface => isDark ? const Color(0xFF3A3A1A) : const Color(0xFFFFF8E1);
  Color get success => const Color(0xFF28A745);
  Color get successSurface => isDark ? const Color(0xFF1A3A1A) : const Color(0xFFF0FFF4);
  Color get info => const Color(0xFF17A2B8);
  Color get infoSurface => isDark ? const Color(0xFF1A2A3A) : const Color(0xFFF0FCFF);
}