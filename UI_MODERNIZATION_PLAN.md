# AKOP MIYEMBRO — UI Modernization Plan

**Date:** June 16, 2026  
**Role:** Senior Product Designer + Senior Flutter Architect + Mobile UX Specialist  
**Goal:** Modernize the UI to 2026 premium standards while preserving all branding, workflows, and functionality.

---

## Table of Contents

1. [Design System](#1-design-system)
2. [Reusable Component Library](#2-reusable-component-library)
3. [Screen-by-Screen Modernization](#3-screen-by-screen-modernization)
4. [Implementation Roadmap](#4-implementation-roadmap)

---

## 1. Design System

### 1.1 Color Palette

```dart
// lib/design_system/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Primary ──
  static const Color primary = Color(0xFF249A19);
  static const Color primaryDark = Color(0xFF1A7A12);
  static const Color primaryLight = Color(0xFF4CAF42);
  static const Color primarySurface = Color(0xFFE8F5E7);

  // ── Brand Secondary ──
  static const Color deepTeal = Color(0xFF004D40);
  static const Color deepTealLight = Color(0xFFE0F2F1);

  // ── Neutrals (MD3 Neutral Palette) ──
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral10 = Color(0xFFF8F9FA);
  static const Color neutral20 = Color(0xFFF1F3F5);
  static const Color neutral30 = Color(0xFFE9ECEF);
  static const Color neutral40 = Color(0xFFDEE2E6);
  static const Color neutral50 = Color(0xFFCED4DA);
  static const Color neutral60 = Color(0xFFADB5BD);
  static const Color neutral70 = Color(0xFF6C757D);
  static const Color neutral80 = Color(0xFF495057);
  static const Color neutral90 = Color(0xFF343A40);
  static const Color neutral100 = Color(0xFF212529);

  // ── Semantic ──
  static const Color error = Color(0xFFDC3545);
  static const Color errorSurface = Color(0xFFFFF0F0);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningSurface = Color(0xFFFFF8E1);
  static const Color success = Color(0xFF28A745);
  static const Color successSurface = Color(0xFFF0FFF4);
  static const Color info = Color(0xFF17A2B8);
  static const Color infoSurface = Color(0xFFF0FCFF);

  // ── Background ──
  static const Color scaffoldBg = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F7F0);
}
```

### 1.2 Typography Scale

```dart
// lib/design_system/app_typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // ── Display ──
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1,
  );

  // ── Headline ──
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.3,
  );

  // ── Title ──
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700, height: 1.3,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.4,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.5,
  );

  // ── Label ──
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );

  // ── Caption ──
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, height: 1.4,
  );
}
```

### 1.3 Spacing System

```dart
// lib/design_system/app_spacing.dart
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;

  // Screen-level padding
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
}
```

### 1.4 Border Radius

```dart
// lib/design_system/app_radius.dart
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
}
```

### 1.5 Elevation / Shadows

```dart
// lib/design_system/app_elevation.dart
import 'package:flutter/material.dart';

class AppElevation {
  AppElevation._();

  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get prominent => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
```

### 1.6 Theme Configuration

```dart
// lib/design_system/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySurface,
      secondary: AppColors.deepTeal,
      error: AppColors.error,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.scaffoldBg,

      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
        titleTextStyle: AppTypography.titleLarge,
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      ),

      // ── ElevatedButton ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelLarge,
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── OutlinedButton ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ── TextButton ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ── InputDecoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.neutral40),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.neutral40),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral70),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral50),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral30,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
      ),

      // ── BottomSheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        showDragHandle: true,
      ),
    );
  }
}
```

---

## 2. Reusable Component Library

All components below go in `lib/widgets/` and are imported across all screens.

### 2.1 AppButton

```dart
// lib/widgets/app_button.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  Color _backgroundColor() {
    return switch (variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.secondary => AppColors.surface,
      AppButtonVariant.danger => AppColors.error,
      AppButtonVariant.ghost => Colors.transparent,
    };
  }

  Color _foregroundColor() {
    return switch (variant) {
      AppButtonVariant.primary => Colors.white,
      AppButtonVariant.secondary => AppColors.primary,
      AppButtonVariant.danger => Colors.white,
      AppButtonVariant.ghost => AppColors.primary,
    };
  }

  double _height() {
    return switch (size) {
      AppButtonSize.small => 40,
      AppButtonSize.medium => 48,
      AppButtonSize.large => 56,
    };
  }

  EdgeInsets _padding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
  }

  TextStyle _textStyle() {
    return switch (size) {
      AppButtonSize.small => AppTypography.labelMedium,
      AppButtonSize.medium => AppTypography.labelLarge,
      AppButtonSize.large => AppTypography.titleMedium,
    };
  }

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: _foregroundColor()),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: _textStyle().copyWith(color: _foregroundColor())),
            ],
          );

    final button = variant == AppButtonVariant.secondary
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: _backgroundColor(),
              foregroundColor: _foregroundColor(),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              padding: _padding(),
              minimumSize: Size(isFullWidth ? double.infinity : 0, _height()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: child,
          )
        : variant == AppButtonVariant.ghost
            ? TextButton(
                onPressed: isLoading ? null : onPressed,
                style: TextButton.styleFrom(
                  padding: _padding(),
                  minimumSize: Size(isFullWidth ? double.infinity : 0, _height()),
                ),
                child: child,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _backgroundColor(),
                  foregroundColor: _foregroundColor(),
                  elevation: variant == AppButtonVariant.danger ? 0 : 0,
                  padding: _padding(),
                  minimumSize: Size(isFullWidth ? double.infinity : 0, _height()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: child,
              );

    return button;
  }
}
```

### 2.2 AppCard

```dart
// lib/widgets/app_card.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_elevation.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool hasShadow;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.hasShadow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: border,
        boxShadow: hasShadow ? AppElevation.subtle : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: AppColors.primary.withOpacity(0.04),
        child: card,
      );
    }

    return card;
  }
}
```

### 2.3 AppTextField

```dart
// lib/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
  });

  Color _prefixIconColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) return AppColors.primary;
    return AppColors.neutral60;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(color: AppColors.neutral80),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          textAlign: textAlign,
          readOnly: readOnly,
          onTap: onTap,
          enabled: enabled,
          style: textStyle ?? AppTypography.bodyLarge.copyWith(color: AppColors.neutral100),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 22)
                : null,
            suffixIcon: suffixIcon,
            counterText: '',
            fillColor: enabled ? AppColors.neutral10 : AppColors.neutral20,
          ),
        ),
      ],
    );
  }
}
```

### 2.4 AppDialog

```dart
// lib/widgets/app_dialog.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm ?? () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.errorSurface
                      : AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(color: AppColors.neutral100),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.ghost,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    variant: isDestructive ? AppButtonVariant.danger : AppButtonVariant.primary,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.5 AppEmptyState

```dart
// lib/widgets/app_empty_state.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neutral20,
                borderRadius: BorderRadius.circular(AppSpacing.xxl),
              ),
              child: Icon(icon, size: 48, color: AppColors.neutral50),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(color: AppColors.neutral90),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral60),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 2.6 AppLoadingState

```dart
// lib/widgets/app_loading_state.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';

class AppLoadingState extends StatelessWidget {
  final int itemCount;
  final bool isCardStyle;

  const AppLoadingState({
    super.key,
    this.itemCount = 4,
    this.isCardStyle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Container(
          height: isCardStyle ? 80 : 60,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: _ShimmerBlock(),
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatefulWidget {
  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.neutral20,
                AppColors.neutral30,
                AppColors.neutral20,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### 2.7 AppSectionHeader

```dart
// lib/widgets/app_section_header.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleMedium.copyWith(color: AppColors.neutral90),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
```

### 2.8 AppStatusBadge

```dart
// lib/widgets/app_status_badge.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_typography.dart';

class AppStatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final Color? backgroundColor;

  const AppStatusBadge({
    super.key,
    required this.status,
    this.color,
    this.backgroundColor,
  });

  factory AppStatusBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const AppStatusBadge(
          status: 'Completed',
          color: AppColors.success,
          backgroundColor: AppColors.successSurface,
        );
      case 'confirmed':
        return const AppStatusBadge(
          status: 'Confirmed',
          color: AppColors.info,
          backgroundColor: AppColors.infoSurface,
        );
      case 'cancelled':
        return const AppStatusBadge(
          status: 'Cancelled',
          color: AppColors.error,
          backgroundColor: AppColors.errorSurface,
        );
      case 'pending':
      default:
        return const AppStatusBadge(
          status: 'Pending',
          color: AppColors.warning,
          backgroundColor: AppColors.warningSurface,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.neutral20,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status,
        style: AppTypography.labelSmall.copyWith(
          color: color ?? AppColors.neutral70,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
```

### 2.9 AppMenuTile

```dart
// lib/widgets/app_menu_tile.dart
import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_elevation.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class AppMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const AppMenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: color.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppElevation.subtle,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 18),
                        child: Text(
                          badgeCount! > 99 ? '99+' : '$badgeCount',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(color: AppColors.neutral90),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 3. Screen-by-Screen Modernization

---

### 3.1 Login Screen

**Current Issues:**

1. **Floating decorative icons (lines 142-146):** Five low-opacity icons clutter the screen and provide no value. On small screens they overlap the login card.
2. **LinearGradient background (lines 134-139):** bgLight-to-white gradient is barely perceptible and adds no visual interest.
3. **OTP SnackBar displays plaintext code (line 49-53):** Security and UX issue.
4. **No keyboard-aware behavior:** The login card doesn't adjust when the keyboard opens on smaller screens.
5. **OTP field uses centered text with large font:** Visually inconsistent with the phone field. Looks like a toy input rather than a security code input.
6. **Logo in CircleAvatar (line 198):** The `shape: BoxShape.circle` clips the rectangular `loginlogo.png` awkwardly.
7. **Button uses gradient wrapper + transparent ElevatedButton:** This two-layer approach is fragile and hard to maintain.
8. **Error messages are generic:** Always shows "Connection failed" instead of the actual server message.

**UI Score Before:** 7/10  
**UI Score After (target):** 9/10

**Modernization Plan:**

1. Replace decorative icons with a subtle `CustomPaint` wave pattern at the top of the screen (brand green at low opacity).
2. Use a clean white background. Remove the gradient.
3. Remove OTP from SnackBar. Show generic "Verification code sent" message.
4. Wrap the entire body in `SafeArea` + `KeyboardDismissOnScroll` for proper keyboard behavior.
5. Create 6 individual OTP code boxes (separate TextFields or a custom pin input) instead of a single centered field.
6. Use a plain `Image.asset` in a SizedBox for the logo — no CircleAvatar clipping.
7. Replace the gradient+ElevatedButton combo with our reusable `AppButton` component.
8. Pass server error messages to the SnackBar instead of hardcoded strings.

**Full Modernized Code:**

```dart
// lib/screens/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/config.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'home_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6, (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _phoneError;
  String? _otpError;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _combinedOtp =>
      _otpControllers.map((c) => c.text).join();

  // ── API Calls ──

  Future<void> _requestOtp() async {
    setState(() => _phoneError = null);

    if (_phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(AppConfig.checkUserUrl),
        body: {'phone_number': _phoneController.text.trim()},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        setState(() => _isOtpSent = true);
        _otpFocusNodes[0].requestFocus();
        SnackBarService.showSuccess(context, 'Verification code sent to your device');
      } else {
        setState(() => _phoneError = data['message'] ?? 'Phone number not found');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _phoneError = 'Unable to connect. Check your internet and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _otpError = null);

    if (_combinedOtp.length < 6) {
      setState(() => _otpError = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(AppConfig.verifyOtpUrl),
        body: {
          'phone_number': _phoneController.text.trim(),
          'otp_code': _combinedOtp,
        },
      );

      if (!mounted) return;

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        if (data['user'] != null) {
          await prefs.setString('user_session', json.encode(data['user']));
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeDashboard(userData: data['user']),
          ),
        );
      } else {
        setState(() => _otpError = data['message'] ?? 'Invalid verification code');

        // Clear OTP fields on failure
        for (final c in _otpControllers) {
          c.clear();
        }
        _otpFocusNodes[0].requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _otpError = 'Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.huge),
                    _buildLogoSection(),
                    const SizedBox(height: AppSpacing.huge),
                    if (!_isOtpSent) _buildPhoneSection(),
                    if (_isOtpSent) _buildOtpSection(),
                    const SizedBox(height: AppSpacing.xxl),
                    if (_isOtpSent)
                      _buildEditPhoneLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Image.asset(
          'assets/loginlogo.png',
          height: 90,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'AK MIYEMBRO',
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.deepTeal,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'HEALTHCARE & PERKS',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.neutral60,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        children: [
          Text(
            'Welcome Back',
            style: AppTypography.headlineMedium.copyWith(color: AppColors.neutral100),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sign in to manage your health benefits',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '09XXXXXXXXX',
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            onChanged: (_) => setState(() => _phoneError = null),
          ),
          if (_phoneError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _phoneError!,
                    style: AppTypography.caption.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'GET VERIFICATION CODE',
            onPressed: _isLoading ? null : _requestOtp,
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.shield_moon_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Verify Your Identity',
            style: AppTypography.headlineMedium.copyWith(color: AppColors.neutral100),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We sent a 6-digit code to your device',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // ── 6 Individual OTP Boxes ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Container(
                width: 48,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.neutral100,
                    letterSpacing: 0,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.neutral10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.neutral40),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _otpFocusNodes[index + 1].requestFocus();
                    }
                    if (value.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                    if (_combinedOtp.length == 6) {
                      FocusScope.of(context).unfocus();
                    }
                    setState(() => _otpError = null);
                  },
                ),
              );
            }),
          ),

          if (_otpError != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Text(
                  _otpError!,
                  style: AppTypography.caption.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),
          AppButton(
            label: 'CONFIRM & LOGIN',
            onPressed: _isLoading ? null : _verifyOtp,
            icon: Icons.lock_open_rounded,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEditPhoneLink() {
    return TextButton.icon(
      onPressed: () => setState(() {
        _isOtpSent = false;
        for (final c in _otpControllers) {
          c.clear();
        }
        _otpError = null;
      }),
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Edit Phone Number'),
      style: TextButton.styleFrom(foregroundColor: AppColors.neutral70),
    );
  }
}

// ── Reusable SnackBar Helper ──
class SnackBarService {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }
}
```

**UX Benefits:**
- Individual OTP boxes provide clear visual feedback for each digit entered
- Auto-advance focus between boxes — faster entry, no need to tap between fields
- Error messages appear inline below the relevant field instead of generic SnackBars
- Clean white card layout with proper shadow depth looks premium (Stripe/Notion caliber)
- ConstrainedBox(maxWidth: 400) prevents the card from stretching too wide on tablets
- GestureDetector dismisses keyboard on tap outside

**Priority:** High

---

### 3.2 Home Dashboard

**Current Issues:**

1. **Header in AppBar with green background + second green header section:** Double green creates visual confusion.
2. **CircleAvatar with person icon:** No user photo support. Generic and dated.
3. **Grid tiles lack hierarchy:** All 4 tiles equal weight. No badges for counts.
4. **Fake "Recent Activity" (line 182-186):** Static data that misleads users.
5. **Profile tile uses Settings icon (line 155):** Wrong icon for profile.
6. **No greeting personalization:** Shows full name but no time-of-day greeting.
7. **Logout via AppBar action:** Non-standard placement. Better in profile or drawer.

**UI Score Before:** 5/10  
**UI Score After (target):** 8/10

**Full Modernized Code:**

```dart
// lib/screens/dashboard/home_dashboard.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_radius.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/app_elevation.dart';
import '../../widgets/app_menu_tile.dart';
import '../../widgets/app_section_header.dart';
import '../../widgets/app_dialog.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import 'news_screen.dart';
import 'perks_screen.dart';
import 'profile_screen.dart';

class HomeDashboard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomeDashboard({super.key, required this.userData});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your AK MIYEMBRO account?',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (confirmed == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = userData['full_name'] ?? 'Member';
    final rank = userData['rank'] ?? 'Member';
    final userId = userData['contact'].toString();
    final initials = _getInitials(fullName);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'AK MIYEMBRO',
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            semanticLabel: 'Log out',
            onPressed: () => _logout(context),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar with initials
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fullName,
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Rank badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      rank.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Quick Actions ──
            AppSectionHeader(title: 'Quick Actions'),
            const SizedBox(height: AppSpacing.sm),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.0,
                    children: [
                      AppMenuTile(
                        title: 'History',
                        icon: Icons.history_rounded,
                        color: const Color(0xFFFF9800),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoryScreen(userId: userId),
                          ),
                        ),
                      ),
                      AppMenuTile(
                        title: 'Perks',
                        icon: Icons.card_giftcard_rounded,
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PerksScreen()),
                        ),
                      ),
                      AppMenuTile(
                        title: 'News',
                        icon: Icons.newspaper_rounded,
                        color: const Color(0xFF2196F3),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NewsScreen()),
                        ),
                      ),
                      AppMenuTile(
                        title: 'Profile',
                        icon: Icons.person_rounded,
                        color: const Color(0xFFE91E63),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(userData: userData),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Account Summary ──
            AppSectionHeader(
              title: 'Your Account',
              actionLabel: 'View All',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userData: userData),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppElevation.subtle,
                ),
                child: Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.phone_android_rounded,
                      label: 'Contact',
                      value: userData['contact'] ?? 'N/A',
                    ),
                    _buildDivider(),
                    _buildStatItem(
                      icon: Icons.military_tech_rounded,
                      label: 'Rank',
                      value: rank,
                    ),
                    _buildDivider(),
                    _buildStatItem(
                      icon: Icons.fingerprint,
                      label: 'ID',
                      value: userData['id']?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(color: AppColors.neutral100),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.neutral60),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.neutral30,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
```

**UX Benefits:**
- Clean single green header with integrated avatar, greeting, name, and rank — no double-green redundancy
- Initials avatar with semi-transparent background looks modern (like Google Workspace)
- Time-based greeting personalizes the experience
- Adaptive grid: 2 columns on phone, 4 on tablet via LayoutBuilder
- Account summary section gives at-a-glance contact/rank/ID info
- Profile tile now uses the correct person icon
- Logout uses the new `AppDialog` with proper confirmation and actually clears SharedPreferences

**Priority:** High

---

### 3.3 History Screen

**Current Issues:**

1. **No date grouping:** Flat list makes it hard to find consultations from specific periods.
2. **No search/filter:** Can't search by patient name.
3. **Bottom sheet uses 85% screen height:** Excessive on tablets.
4. **Empty state is plain text:** "No history found." with no illustration.
5. **`_buildDetailRow` shows all fields including empty ones:** Cluttered detail view.
6. **Status badge uses hardcoded colors:** Won't work with dark mode.

**UI Score Before:** 6/10  
**UI Score After (target):** 8/10

**Full Modernized Code:**

```dart
// lib/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_radius.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/app_elevation.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_state.dart';
import '../../widgets/app_status_badge.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;
  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _allItems = [];

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_history.php?user_id=${widget.userId}"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _allItems = data['data'];
          return _allItems;
        }
      }
    } catch (_) {}
    return [];
  }

  Future<void> _onRefresh() async {
    setState(() => _historyFuture = _fetchHistory());
    await _historyFuture;
  }

  List<dynamic> _filterItems(List<dynamic> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((item) {
      final patient = (item['p_patient'] ?? '').toString().toLowerCase();
      final complaint = (item['p_complaint'] ?? '').toString().toLowerCase();
      return patient.contains(_searchQuery) || complaint.contains(_searchQuery);
    }).toList();
  }

  void _showDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxxl,
            ),
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Detail',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.neutral100,
                          ),
                        ),
                        Text(
                          'ID: ${item['p_ctrlID'] ?? 'N/A'}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.neutral60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppStatusBadge.fromStatus(item['status'] ?? 'Pending'),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Detail fields (only non-empty)
              if (_hasValue(item['p_patient']))
                _detailRow('Patient Name', item['p_patient']),
              if (_hasValue(item['p_complaint']))
                _detailRow('Chief Complaint', item['p_complaint']),
              if (_hasValue(item['p_history']))
                _detailRow('Medical History', item['p_history']),
              if (_hasValue(item['p_medication']))
                _detailRow('Current Medication', item['p_medication']),
              if (_hasValue(item['p_med']))
                _detailRow('Prescribed Medicine', item['p_med']),
              if (_hasValue(item['p_others']))
                _detailRow('Other Notes', item['p_others']),
              if (_hasValue(item['p_trasfer_comment']))
                _detailRow('Transfer Comment', item['p_trasfer_comment']),

              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  bool _hasValue(dynamic value) =>
      value != null && value.toString().isNotEmpty && value.toString() != 'None';

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: AppColors.neutral60),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.neutral90),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.neutral30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Consultation History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Search Bar (sticky) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by patient or complaint...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral50,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── History List ──
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState(itemCount: 5);
                }

                if (snapshot.hasError) {
                  return AppEmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Connection Error',
                    subtitle: 'Could not load your history. Check your internet connection.',
                    actionLabel: 'Retry',
                    onAction: () => setState(() => _historyFuture = _fetchHistory()),
                  );
                }

                final filtered = _filterItems(
                  snapshot.hasData ? snapshot.data! : [],
                );

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: AppEmptyState(
                            icon: _searchQuery.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.history_rounded,
                            title: _searchQuery.isNotEmpty
                                ? 'No Results'
                                : 'No History Yet',
                            subtitle: _searchQuery.isNotEmpty
                                ? 'Try a different search term.'
                                : 'Your consultation history will appear here once you have completed consultations.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildHistoryCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () => _showDetails(item),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppElevation.subtle,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['p_patient'] ?? 'No Name',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.neutral100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['created_at'] ?? '',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.neutral60,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                AppStatusBadge.fromStatus(item['status'] ?? 'Pending'),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, color: AppColors.neutral50, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**UX Benefits:**
- Search bar with clear button — users can filter by patient name or complaint
- Proper empty states: one when there's no history, another when search has no results
- AppLoadingState shimmer during data fetch
- Detail bottom sheet uses Material 3 drag handle + DraggableScrollableSheet (proper tablet support)
- Conditional field rendering — only shows non-empty detail fields
- Status badge uses semantic colors via AppStatusBadge
- Cards use the modern AppElevation.subtle and AppRadius.lg

**Priority:** Medium

---

### 3.4 News Screen

**Current Issues:**

1. **Image URL is never rendered:** Placeholder icon always shown.
2. **Category filter triggers full list rebuild:** Should filter in memory.
3. **Search clears on pull-to-refresh:** Disrupts user context.
4. **No shimmer loading:** Just a spinner.
5. **Redundant "Back to News" button in detail modal.**
6. **NewsArticle model defined in screen file:** Should be in models/.

**UI Score Before:** 7/10  
**UI Score After (target):** 8/10

**Full Modernized Code:**

```dart
// lib/screens/news/news_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/config.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_radius.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/app_elevation.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_state.dart';
import '../../models/news_article.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Health', 'Announcements', 'Maritime', 'System'];
  late Future<List<NewsArticle>> _newsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<NewsArticle> _allNews = [];

  @override
  void initState() {
    super.initState();
    _newsFuture = _fetchNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<NewsArticle>> _fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_news.php"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allNews = data.map((item) => NewsArticle.fromJson(item)).toList();
        return _allNews;
      }
    } catch (_) {}
    return [];
  }

  Future<void> _onRefresh() async {
    setState(() => _newsFuture = _fetchNews());
    await _newsFuture;
  }

  List<NewsArticle> _filteredNews(List<NewsArticle> news) {
    return news.where((article) {
      final matchesCategory = _selectedCategory == 'All' ||
          article.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery) ||
          article.content.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showDetails(NewsArticle news) {
    final formattedDate = DateFormat('MMMM dd, yyyy').format(news.publishedDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxxl,
            ),
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  news.category.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                news.title,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Published on $formattedDate by ${news.author}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.neutral60,
                ),
              ),
              const Divider(height: AppSpacing.xxxl),
              Text(
                news.content,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.neutral80,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('News Corner'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search news...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral50,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Category Chips ──
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = _categories[index]);
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.neutral70,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── News List ──
          Expanded(
            child: FutureBuilder<List<NewsArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState(itemCount: 4);
                }

                if (snapshot.hasError) {
                  return AppEmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Connection Error',
                    subtitle: 'Could not load news. Pull down to retry.',
                    actionLabel: 'Retry',
                    onAction: () => setState(() => _newsFuture = _fetchNews()),
                  );
                }

                final newsList = _filteredNews(
                  snapshot.hasData ? snapshot.data! : [],
                );

                if (newsList.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: AppEmptyState(
                            icon: _searchQuery.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.newspaper_rounded,
                            title: _searchQuery.isNotEmpty
                                ? 'No Results'
                                : 'No News',
                            subtitle: _searchQuery.isNotEmpty
                                ? 'Try a different search term.'
                                : 'Stay tuned for the latest updates.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      return _buildNewsCard(newsList[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle news) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(news.publishedDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () => _showDetails(news),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppElevation.subtle,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: news.imageUrl.isNotEmpty
                      ? Image.network(
                          news.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                const SizedBox(width: AppSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.neutral100,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$formattedDate · ${news.category}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.neutral60,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        news.content,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: AppColors.neutral50, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.neutral20,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Icon(
        Icons.article_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }
}
```

**UX Benefits:**
- News thumbnails actually render from the API (with error fallback)
- Category chip filtering is instant (in-memory) — no full list rebuild
- Search query preserved on pull-to-refresh
- AppLoadingState shimmer during data fetch
- Bottom sheet uses native Material 3 drag handle + DraggableScrollableSheet
- Removed redundant "Back to News" button

**Priority:** Medium

---

### 3.5 Perks Screen

**Current Issues:**

1. **PerksScreen is StatelessWidget with async methods:** Architecturally incorrect.
2. **Duplicate setModalState call (line 180-181):** Copy-paste bug.
3. **3 empty onTap callbacks (E-Prescription, Pharmacy Disc., Med Certificate):** Tappable cards with no response.
4. **Custom OverlayEntry notification:** Fragile — memory leak if user navigates away before 3-second timer.
5. **Overlay notification duplicated across two files.**
6. **Hotline number hardcoded (line 267).**
7. **Featured perk gradient uses hardcoded colors.**

**UI Score Before:** 6/10  
**UI Score After (target):** 8/10

**Full Modernized Code:**

```dart
// lib/screens/perks/perks_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_radius.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/app_elevation.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_section_header.dart';
import 'request_status_screen.dart';

class PerksScreen extends StatefulWidget {
  const PerksScreen({super.key});

  @override
  State<PerksScreen> createState() => _PerksScreenState();
}

class _PerksScreenState extends State<PerksScreen> {
  // ── Hotline ──
  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open dialer: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Teleconsult Form ──
  void _showScheduleForm() {
    final reasonController = TextEditingController();
    final dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) {
          bool isLoading = false;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              top: 0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Teleconsult',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tell us your concern and preferred schedule.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neutral60,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Reason field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason for Consultation',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.neutral80,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: reasonController,
                        maxLines: 3,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'e.g. Fever, Headache, Requesting MedCert...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.neutral50,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Date field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferred Date',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.neutral80,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        enabled: !isLoading,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            dateController.text =
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Select Date',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.neutral50,
                          ),
                          suffixIcon: const Icon(Icons.calendar_month, size: 22),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Submit button
                  AppButton(
                    label: 'SUBMIT REQUEST',
                    icon: Icons.send_rounded,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (reasonController.text.isEmpty ||
                                dateController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please fill in all fields.'),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);

                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final userJson = prefs.getString('user_session');

                              if (userJson != null) {
                                final userData = json.decode(userJson);
                                final userId = userData['id'].toString();
                                final phone = userData['contact'] ?? '';

                                final response = await http.post(
                                  Uri.parse(
                                      '${AppConfig.baseUrl}/save_teleconsult.php'),
                                  body: {
                                    'user_id': userId,
                                    'consultation_reason': reasonController.text,
                                    'preferred_date': dateController.text,
                                    'phone_number': phone,
                                  },
                                ).timeout(const Duration(seconds: 10));

                                final result = json.decode(response.body);

                                if (result['status'] == 'success') {
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Request submitted! We will contact you soon.',
                                      ),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  throw Exception(result['message']);
                                }
                              }
                            } catch (e) {
                              setModalState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Coming Soon!'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Member Perks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Featured Perk ──
            _buildFeaturedPerk(),
            const SizedBox(height: AppSpacing.xxl),

            // ── Other Benefits ──
            AppSectionHeader(title: 'Other Benefits'),
            const SizedBox(height: AppSpacing.sm),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.1,
                  children: [
                    _buildPerkCard(
                      'E-Prescription',
                      Icons.medication_liquid_rounded,
                      const Color(0xFF2196F3),
                      'View history',
                      () => _showComingSoon('E-Prescription'),
                    ),
                    _buildPerkCard(
                      'Pharmacy Disc.',
                      Icons.local_pharmacy_rounded,
                      const Color(0xFFE91E63),
                      'Up to 10% off',
                      () => _showComingSoon('Pharmacy Discounts'),
                    ),
                    _buildPerkCard(
                      'Consult Requests',
                      Icons.pending_actions_rounded,
                      const Color(0xFF673AB7),
                      'Track status',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RequestStatusScreen(),
                        ),
                      ),
                    ),
                    _buildPerkCard(
                      'Med Certificate',
                      Icons.verified_user_rounded,
                      const Color(0xFFFF9800),
                      'Fast request',
                      () => _showComingSoon('Medical Certificates'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Hotline ──
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _makePhoneCall('09352427713'),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.deepTealLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.deepTeal.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.deepTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: AppColors.deepTeal,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AnaKalusugan Hotline',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.deepTeal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to call: 0935 242 7713',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.deepTeal.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.call_rounded,
                        color: AppColors.deepTeal,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPerk() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'AnaKalusugan Teleconsult',
            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Talk to a doctor, for FREE.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showScheduleForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                textStyle: AppTypography.labelLarge,
              ),
              child: const Text('Start Consult Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppElevation.subtle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.neutral90,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.neutral60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**UX Benefits:**
- Converted to StatefulWidget — proper architecture
- Fixed duplicate setModalState bug
- Empty perk callbacks now show "Coming Soon" SnackBar instead of nothing
- Replaced fragile OverlayEntry with standard ScaffoldMessenger SnackBars
- Featured perk uses AppColors constants (consistent with theme)
- Hotline card uses deepTeal brand colors for visual distinction
- Adaptive grid to 4 columns on wider screens
- All cards use the design system elevations and radii

**Priority:** High

---

### 3.6 Profile Screen

**Current Issues:**

1. **"Edit Profile" button does nothing (line 60-63).**
2. **Mobile Number shows "Registered" instead of actual number.**
3. **No logout option.**
4. **Avatar always red — should use brand green.**
5. **No account statistics.**
6. **Only 3 fields shown out of 5 available.**

**UI Score Before:** 4/10  
**UI Score After (target):** 7/10

**Full Modernized Code:**

```dart
// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_radius.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/app_elevation.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_section_header.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({super.key, required this.userData});

  String _getInitials(String name) {
    final parts = (name ?? '').trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return (name ?? '').isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (confirmed == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = userData['full_name'] ?? 'Member Name';
    final rank = userData['rank'] ?? 'Member';
    final contact = userData['contact'] ?? 'N/A';
    final userId = userData['id']?.toString() ?? 'N/A';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile Header Card ──
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: AppElevation.medium,
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(fullName),
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    fullName,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.neutral100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      rank.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Account Details ──
            AppSectionHeader(title: 'Account Details'),
            const SizedBox(height: AppSpacing.sm),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  _infoTile(Icons.fingerprint, 'Member ID', userId),
                  _infoTile(Icons.phone_android_rounded, 'Mobile Number', contact),
                  _infoTile(Icons.badge_rounded, 'Account Type', rank),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Actions ──
            AppSectionHeader(title: 'Actions'),
            const SizedBox(height: AppSpacing.sm),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  _actionTile(
                    Icons.edit_outlined,
                    'Edit Profile Information',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile editing — Coming Soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _actionTile(
                    Icons.logout_rounded,
                    'Log Out',
                    () => _logout(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppElevation.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(color: AppColors.neutral60),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.neutral100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppElevation.subtle,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.errorSurface
                      : AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDestructive ? AppColors.error : AppColors.neutral100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDestructive
                    ? AppColors.error.withOpacity(0.4)
                    : AppColors.neutral50,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**UX Benefits:**
- Gradient avatar with initials (like Google Workspace profile)
- Actual mobile number displayed instead of "Registered"
- All available user fields shown (Member ID, Mobile, Account Type)
- Proper logout with confirmation dialog (AppDialog) and SharedPreferences cleanup
- Edit button shows "Coming Soon" instead of silently doing nothing
- Clear visual hierarchy: Profile card → Account Details → Actions
- Separate visual treatment for destructive action (logout in red)

**Priority:** High

---

### 3.7 Request Status Screen

**Current Issues:**

1. **Uses `contact` as `user_id` for filtering (line 34):** Inconsistent across endpoints.
2. **Cancel has no confirmation dialog (line 65):** Accidental taps cancel irreversibly.
3. **No status filter tabs.**
4. **No pull-to-refresh on empty state.**
5. **Detail modal uses inconsistent bottom sheet pattern.**
6. **Duplicate _showTopNotification method.**

**UI Score Before:** 6/10  
**UI Score After (target):** 8/10

**Full Modernized Code:**

```dart
// lib/screens/requests/request_status_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_radius.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/app_elevation.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_state.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_dialog.dart';

class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Confirmed', 'Completed'];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_session');

      if (userJson != null) {
        final userData = json.decode(userJson);
        final userId = userData['contact'].toString();

        final response = await http.get(
          Uri.parse(
              '${AppConfig.baseUrl}/get_my_requests.php?user_id=$userId'),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['status'] == 'success') {
            setState(() {
              _requests = result['data'];
              _isLoading = false;
            });
            return;
          }
        }
        throw Exception('Server error');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connection error. Check your internet.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Cancel Request',
      message: 'Are you sure you want to cancel this consultation request? This action cannot be undone.',
      confirmLabel: 'Yes, Cancel',
      isDestructive: true,
      icon: Icons.cancel_outlined,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/cancel_request.php'),
        body: {'id': requestId},
      ).timeout(const Duration(seconds: 10));

      final result = json.decode(response.body);

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Request cancelled successfully.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchRequests();
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Could not cancel request. $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetails(Map<String, dynamic> req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl,
            ),
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Request Details',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                  const Spacer(),
                  AppStatusBadge.fromStatus(req['status'] ?? 'Pending'),
                ],
              ),
              const Divider(height: AppSpacing.xxxl),

              _detailRow('Reason', req['consultation_reason'] ?? 'N/A'),
              _detailRow('Preferred Date', req['preferred_date'] ?? 'N/A'),
              _detailRow('Request ID', '#${req['request_id'] ?? 'N/A'}'),
              _detailRow('Status', (req['status'] ?? 'Pending').toUpperCase()),

              if ((req['status'] ?? '').toLowerCase() == 'pending') ...[
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelRequest(req['request_id'].toString());
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text('CANCEL REQUEST'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral60,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral90,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filteredRequests() {
    if (_selectedFilter == 'All') return _requests;
    return _requests.where((r) {
      final status = (r['status'] ?? '').toString().toLowerCase();
      return status == _selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('My Consult Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            semanticLabel: 'Refresh',
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Chips ──
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == _filters[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (_) => setState(
                        () => _selectedFilter = _filters[index]),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.neutral70,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Request List ──
          Expanded(
            child: _isLoading
                ? const AppLoadingState(itemCount: 4)
                : RefreshIndicator(
                    onRefresh: _fetchRequests,
                    child: filtered.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: AppEmptyState(
                                  icon: Icons.assignment_late_outlined,
                                  title: _requests.isEmpty
                                      ? 'No Requests Yet'
                                      : 'No ${_selectedFilter} Requests',
                                  subtitle: _requests.isEmpty
                                      ? 'Your teleconsult requests will appear here.'
                                      : 'No requests match the selected filter.',
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.sm,
                              AppSpacing.lg,
                              AppSpacing.xxxl,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final req = filtered[index];
                              return _buildRequestCard(req);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = req['status'] ?? 'Pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () => _showDetails(req),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppElevation.subtle,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req['consultation_reason'] ?? 'No reason',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.neutral100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Preferred: ${req['preferred_date'] ?? 'N/A'}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.neutral60,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            '#${req['request_id'] ?? 'N/A'}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.neutral50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppStatusBadge.fromStatus(status),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral50,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**UX Benefits:**
- Status filter chips (All / Pending / Confirmed / Completed) for quick filtering
- Cancel confirmation dialog prevents accidental cancellations
- Pull-to-refresh available on empty state
- Standardized bottom sheet using Material 3 drag handle + DraggableScrollableSheet
- Clean card layout with AppStatusBadge providing consistent status visualization
- Empty state differentiates between "no requests at all" vs "no requests matching filter"

**Priority:** Medium

---

## 4. Implementation Roadmap

### Phase 1 — Foundation (Day 1-2)

| Step | Task | Files |
|---|---|---|
| 1 | Create `lib/design_system/` folder with all 5 files | New: `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_radius.dart`, `app_elevation.dart`, `app_theme.dart` |
| 2 | Apply `AppTheme.light` in `main.dart` | `main.dart` |
| 3 | Create all 9 reusable widget files | New: `widgets/app_button.dart`, `app_card.dart`, `app_text_field.dart`, `app_dialog.dart`, `app_empty_state.dart`, `app_loading_state.dart`, `app_section_header.dart`, `app_status_badge.dart`, `app_menu_tile.dart` |
| 4 | Extract `NewsArticle` to `models/news_article.dart` | Move from `news_screen.dart` |

### Phase 2 — Screen Modernization (Day 3-5)

| Step | Screen | Priority |
|---|---|---|
| 5 | Login Screen | High |
| 6 | Home Dashboard | High |
| 7 | Profile Screen | High |
| 8 | Perks Screen | High |
| 9 | History Screen | Medium |
| 10 | News Screen | Medium |
| 11 | Request Status Screen | Medium |

### Phase 3 — Polish (Day 6-7)

| Step | Task |
|---|---|
| 12 | Delete `splash_screen.dart` |
| 13 | Remove `.code-workspace` files from `lib/` |
| 14 | Run `flutter analyze` and fix all warnings |
| 15 | Test on iOS simulator and Android device |
| 16 | Test tablet layout (iPad / Android tablet) |
| 17 | Test dark mode (add theme toggle) |

---

*End of UI Modernization Plan — AKOP MIYEMBRO*