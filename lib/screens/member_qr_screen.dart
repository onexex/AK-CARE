import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../design_system/app_colors.dart';
import '../design_system/app_elevation.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/theme_colors.dart';
import '../widgets/app_empty_state.dart';

/// The member's scannable code.
///
/// The encoded payload is the bare member id and nothing else — no JSON, no
/// URL, no prefix. Partner scanners read it as the lookup key they already use,
/// so anything wrapped around it would only have to be stripped back off.
///
/// Deliberately the code and the identity that goes with it, nothing more. The
/// card design it will eventually sit on is still with the client; putting the
/// code on its own first means the thing that has to work — the scan — is
/// settled before the artwork is.
class MemberQrScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const MemberQrScreen({super.key, required this.userData});

  /// Exactly what gets encoded: the member id, trimmed, and nothing appended.
  /// Named so a test can hold the payload to that promise without having to
  /// decode a rendered code.
  static String qrPayload(Map<String, dynamic> userData) =>
      userData['id']?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final memberId = qrPayload(userData);
    final fullName = (userData['full_name'] ?? '').toString().trim();
    final rank = (userData['rank'] ?? 'Member').toString();

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('My QR Code')),
      body: memberId.isEmpty
          ? const AppEmptyState(
              icon: Icons.qr_code_2_rounded,
              title: 'No member ID yet',
              subtitle:
                  'Your account has no member ID, so there is nothing to scan. '
                  'Log out and back in, or contact AKO support.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(children: [
                _panel(context, tc, memberId, fullName, rank),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Show this code to AKO partner staff. They scan it to pull up '
                  'your membership — no need to spell out your name or ID.',
                  style: AppTypography.bodyMedium.copyWith(color: tc.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Turn your screen brightness up if the scanner struggles.',
                  style: AppTypography.caption.copyWith(color: tc.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
    );
  }

  Widget _panel(BuildContext context, ThemeColors tc, String memberId,
      String fullName, String rank) {
    // As big as the screen allows. The counter scanner is the case that has to
    // work, and a code sized to look tidy is a code someone has to lean over.
    final width = MediaQuery.of(context).size.width;
    final qrSize =
        (width - AppSpacing.lg * 2 - AppSpacing.xxl * 2).clamp(160.0, 320.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppElevation.medium,
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            // The panel stays white and the modules stay black in both themes.
            // A scanner needs the contrast the QR spec assumes; a dark-mode code
            // drawn in surface colours is decoration that does not read.
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.neutral30),
          ),
          child: QrImageView(
            data: memberId,
            size: qrSize,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            // M survives a smudged screen or an off-angle scan; L, the package
            // default, does not leave much room for either.
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square, color: Colors.black),
            dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            semanticsLabel: 'QR code for member ID $memberId',
            errorStateBuilder: (context, error) => SizedBox(
              width: qrSize,
              height: qrSize,
              child: Center(
                child: Text(
                  'This member ID cannot be turned into a QR code.',
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (fullName.isNotEmpty) ...[
          Text(fullName,
              style: AppTypography.titleLarge.copyWith(color: tc.neutral100),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: tc.primarySurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(rank.toUpperCase(),
              style: AppTypography.labelSmall
                  .copyWith(color: tc.primary, letterSpacing: 1)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('MEMBER ID',
            style: AppTypography.caption
                .copyWith(color: tc.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 2),
        // Printed under the code so the counter can still be served when the
        // scanner is down or the screen is too scratched to read.
        SelectableText(
          memberId,
          style: AppTypography.headlineMedium
              .copyWith(color: tc.neutral100, letterSpacing: 2),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
