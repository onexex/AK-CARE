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
  Color get primarySurface => isDark ? const Color(0xFF1A3A1A) : const Color(0xFFE8F5E7);
  Color get deepTeal => const Color(0xFF004D40);
  Color get deepTealLight => isDark ? const Color(0xFF1A3A3A) : const Color(0xFFE0F2F1);
  Color get error => cs.error;
  Color get errorSurface => isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFF0F0);
  Color get warning => const Color(0xFFFFC107);
  Color get warningSurface => isDark ? const Color(0xFF3A3A1A) : const Color(0xFFFFF8E1);
  Color get success => const Color(0xFF28A745);
  Color get successSurface => isDark ? const Color(0xFF1A3A1A) : const Color(0xFFF0FFF4);
  Color get info => const Color(0xFF17A2B8);
  Color get infoSurface => isDark ? const Color(0xFF1A2A3A) : const Color(0xFFF0FCFF);
}