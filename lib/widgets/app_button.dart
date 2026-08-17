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

  Color _backgroundColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (variant) {
      AppButtonVariant.primary => cs.primary,
      AppButtonVariant.secondary => cs.surface,
      AppButtonVariant.danger => cs.error,
      AppButtonVariant.ghost => Colors.transparent,
    };
  }

  Color _foregroundColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (variant) {
      AppButtonVariant.primary => cs.onPrimary,
      AppButtonVariant.secondary => cs.primary,
      AppButtonVariant.danger => cs.onError,
      AppButtonVariant.ghost => cs.primary,
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
      AppButtonSize.small =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      AppButtonSize.medium =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      AppButtonSize.large =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
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
    final bg = _backgroundColor(context);
    final fg = _foregroundColor(context);

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        // A label too wide for the button overflows rather than shrinking, and
        // the margins here are thin: 'GET VERIFICATION CODE' and its icon
        // measure about 199pt into the 224pt the sign-in card allows on a 360pt
        // phone. That fits today, but roughly 12% of font scaling spends the
        // difference, and a member who has turned text size up is exactly the
        // member who cannot afford a clipped instruction. Scaling down beats
        // clipping a call to action — shrinking the words is recoverable,
        // losing them is not. It does nothing to a label that already fits.
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label, style: _textStyle().copyWith(color: fg)),
              ],
            ),
          );

    final button = variant == AppButtonVariant.secondary
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
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
                  minimumSize:
                      Size(isFullWidth ? double.infinity : 0, _height()),
                ),
                child: child,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: fg,
                  elevation: 0,
                  padding: _padding(),
                  minimumSize:
                      Size(isFullWidth ? double.infinity : 0, _height()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: child,
              );

    return button;
  }
}