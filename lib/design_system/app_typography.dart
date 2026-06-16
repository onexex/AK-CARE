import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700, height: 1.3,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, height: 1.4,
  );
}