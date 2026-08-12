import 'package:flutter/material.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../design_system/theme_colors.dart';

/// A navigation tile: accent-tinted icon, title, and a line saying what it is.
///
/// The dashboard and the perks screen both list places to go, and each had its
/// own tile — square with a centred one-word label on the dashboard, left
/// aligned with a subtitle on perks. Same job, two designs. This is the perks
/// one, which says more in less height, used by both.
///
/// Sizing note: at [AppSpacing.lg] padding the content needs about 130dp of
/// height, so the enclosing grid's childAspectRatio must not exceed ~1.2 for a
/// two-column phone layout. Above that the icon and text overflow the tile.
class AppFeatureTile extends StatelessWidget {
  final String title;

  /// What the destination holds, e.g. 'Past consultations'. Omit for a tile
  /// whose title is already self-evident.
  final String? subtitle;

  final IconData icon;

  /// The module's accent, from AppColors.feature*. Tints the icon chip and the
  /// splash so the tile reads as belonging to that part of the app.
  final Color color;

  final VoidCallback onTap;

  /// Icon beside the text rather than above it. Used by [AppFeatureTile.row].
  final bool _horizontal;

  const AppFeatureTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  }) : _horizontal = false;

  /// Full-width variant, for a tile that spans the row instead of sitting in a
  /// grid cell. The icon moves beside the text and a chevron marks it as a way
  /// onward — stacked vertically at full width the same content would be a
  /// 130dp slab, which reads as a banner rather than one entry among several.
  const AppFeatureTile.row({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  }) : _horizontal = true;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    final chip = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: 24, color: color),
    );

    // Flexible rather than bare Text: in the grid the tile is a fixed height,
    // so at large system font sizes the labels have to give way instead of
    // overflowing it.
    final titleText = Flexible(
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(color: tc.neutral90),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final subtitleText = subtitle == null
        ? null
        : Flexible(
            child: Text(
              subtitle!,
              style: AppTypography.caption.copyWith(color: tc.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: color.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppElevation.subtle,
          ),
          child: _horizontal
              ? Row(
                  children: [
                    chip,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText,
                          if (subtitleText != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            subtitleText,
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 20, color: tc.textMuted),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chip,
                    const SizedBox(height: AppSpacing.md),
                    titleText,
                    if (subtitleText != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      subtitleText,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
