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

  /// Badge for a `teleconsult_requests.status` value.
  ///
  /// Every state the column can hold is matched explicitly, 'Pending' included.
  /// It used to be the default branch instead, so anything unrecognised — a
  /// field the server did not send, a value added to the enum later — was
  /// reported to the member as Pending. That is how History came to show
  /// "Pending" on consultations from 2022: the column it read did not exist,
  /// and the fall-through spoke for it.
  ///
  /// Now an unknown value is shown as itself in neutral colours, and an absent
  /// one reads "Unknown". Neither is pretty, which is the point: a badge that
  /// looks wrong sends someone to look, where a plausible wrong one does not.
  factory AppStatusBadge.fromStatus(BuildContext context, String? raw) {
    final tc = ThemeColors.of(context);
    final value = (raw ?? '').trim();

    return switch (value.toLowerCase()) {
      'completed' => AppStatusBadge(
          status: 'Completed',
          color: tc.successText,
          backgroundColor: tc.successSurface,
        ),
      'confirmed' => AppStatusBadge(
          status: 'Confirmed',
          color: tc.infoText,
          backgroundColor: tc.infoSurface,
        ),
      'cancelled' => AppStatusBadge(
          status: 'Cancelled',
          color: tc.errorText,
          backgroundColor: tc.errorSurface,
        ),
      'pending' => AppStatusBadge(
          status: 'Pending',
          color: tc.warningText,
          backgroundColor: tc.warningSurface,
        ),
      '' => AppStatusBadge(
          status: 'Unknown',
          color: tc.textSecondary,
          backgroundColor: tc.neutral20,
        ),
      _ => AppStatusBadge(
          status: value,
          color: tc.textSecondary,
          backgroundColor: tc.neutral20,
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
          color: color ?? tc.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}