import 'package:flutter/material.dart';
import '../design_system/theme_colors.dart';
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

  factory AppStatusBadge.fromStatus(BuildContext context, String raw) {
    final tc = ThemeColors.of(context);
    return switch (raw.toLowerCase()) {
      'completed' => AppStatusBadge(
          status: 'Completed',
          color: tc.success,
          backgroundColor: tc.successSurface,
        ),
      'confirmed' => AppStatusBadge(
          status: 'Confirmed',
          color: tc.info,
          backgroundColor: tc.infoSurface,
        ),
      'cancelled' => AppStatusBadge(
          status: 'Cancelled',
          color: tc.error,
          backgroundColor: tc.errorSurface,
        ),
      _ => AppStatusBadge(
          status: 'Pending',
          color: tc.warning,
          backgroundColor: tc.warningSurface,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? tc.neutral20,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status,
        style: AppTypography.labelSmall.copyWith(
          color: color ?? tc.neutral70,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}