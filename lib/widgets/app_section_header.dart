import 'package:flutter/material.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_spacing.dart';
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
    final tc = ThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleMedium
                  .copyWith(color: tc.neutral90),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                // Keeps the label visually tight while still offering a 48dp
                // touch target, which shrinkWrap + Size.zero denied.
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium
                    .copyWith(color: tc.primaryText),
              ),
            ),
        ],
      ),
    );
  }
}