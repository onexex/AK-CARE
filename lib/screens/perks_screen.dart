import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/config.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_feature_tile.dart';
import 'request_status_screen.dart';
import 'eprescription_screen.dart';
import 'pharmacy_discounts_screen.dart';
import 'medical_certs_screen.dart';
import 'package:http/http.dart' as http;

class PerksScreen extends StatefulWidget {
  const PerksScreen({super.key});

  @override
  State<PerksScreen> createState() => _PerksScreenState();
}

class _PerksScreenState extends State<PerksScreen> {
  Future<void> _makePhoneCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer: $e'),
              backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showScheduleForm() {
    final reasonCtrl = TextEditingController();
    final dateCtrl = TextEditingController();

    // Declared out here, alongside the controllers, so it survives rebuilds.
    // Inside StatefulBuilder's builder it was reset to false on every
    // setModalState, so the submit button never actually disabled.
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final tc = ThemeColors.of(context);
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                top: 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Teleconsult',
                      style: AppTypography.headlineMedium.copyWith(
                          color: tc.neutral100)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Tell us your concern and preferred schedule.',
                      style: AppTypography.bodyMedium.copyWith(
                          color: tc.textSecondary)),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Reason for Consultation',
                      style: AppTypography.labelMedium.copyWith(
                          color: tc.neutral80)),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 3,
                    enabled: !loading,
                    decoration: const InputDecoration(
                        hintText: 'e.g. Fever, Headache'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Preferred Date',
                      style: AppTypography.labelMedium.copyWith(
                          color: tc.neutral80)),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: dateCtrl,
                    readOnly: true,
                    enabled: !loading,
                    decoration: const InputDecoration(
                        hintText: 'Select Date',
                        suffixIcon: Icon(Icons.calendar_month, size: 22)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        dateCtrl.text =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: 'SUBMIT REQUEST',
                    icon: Icons.send_rounded,
                    isLoading: loading,
                    onPressed: loading ? null : () async {
                      if (reasonCtrl.text.isEmpty || dateCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill in all fields.'),
                              backgroundColor: Colors.amber,
                              behavior: SnackBarBehavior.floating),
                        );
                        return;
                      }
                      setModalState(() => loading = true);

                      // Resolved before the async gap. Once the sheet is popped
                      // its context is defunct, so these cannot be read from it
                      // afterwards.
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);

                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final json = prefs.getString('user_session');
                        if (json != null) {
                          final user = jsonDecode(json);
                          final response = await http.post(
                            Uri.parse('${AppConfig.baseUrl}/save_teleconsult.php'),
                            body: {
                              'user_id': user['id'].toString(),
                              'consultation_reason': reasonCtrl.text,
                              'preferred_date': dateCtrl.text,
                              'phone_number': user['contact'] ?? '',
                            },
                          ).timeout(const Duration(seconds: 10));
                          final result = jsonDecode(response.body);
                          if (result['status'] == 'success') {
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('Request submitted! We will contact you soon.'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating),
                            );
                          } else {
                            throw Exception(result['message']);
                          }
                        }
                      } catch (e) {
                        if (ctx.mounted) setModalState(() => loading = false);
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating),
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

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('Member Perks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedPerk(tc),
            const SizedBox(height: AppSpacing.lg),
            const AppSectionHeader(title: 'Other Benefits'),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 500 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  // 1.2 matches the dashboard exactly — same tile, same shape —
                  // and is still above the ~130dp the tile's content needs.
                  childAspectRatio: 1.2,
                  children: [
                    AppFeatureTile(
                        title: 'E-Prescription',
                        subtitle: 'View history',
                        icon: Icons.medication_liquid_rounded,
                        color: AppColors.featureNews,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const EPrescriptionScreen()))),
                    AppFeatureTile(
                        // 'Pharmacy Discounts' ellipsises to 'Pharmacy Disco…'
                        // at this tile width, and 'Pharmacy Disc.' is an
                        // abbreviation nobody says out loud. The subtitle
                        // already carries the discount, so the title doesn't
                        // have to.
                        title: 'Pharmacy',
                        subtitle: 'Up to 10% off',
                        icon: Icons.local_pharmacy_rounded,
                        color: AppColors.featurePharmacy,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const PharmacyDiscountsScreen()))),
                    AppFeatureTile(
                        title: 'Consult Requests',
                        subtitle: 'Track status',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.featureEPrescription,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const RequestStatusScreen()))),
                    AppFeatureTile(
                        title: 'Med Certificate',
                        subtitle: 'Fast request',
                        icon: Icons.verified_user_rounded,
                        color: AppColors.featureCertificate,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const MedicalCertsScreen()))),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _makePhoneCall('09352427713'),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: tc.deepTealLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                        color: tc.deepTeal.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                            color: tc.deepTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Icon(Icons.support_agent_rounded,
                            color: tc.deepTeal, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AnaKalusugan Hotline',
                                style: AppTypography.titleMedium
                                    .copyWith(color: tc.deepTeal)),
                            const SizedBox(height: 2),
                            // Full strength, not 70%: faded it sat at 3.88:1
                            // against the tinted card, under the 4.5 needed.
                            Text('Tap to call: 0935 242 7713',
                                style: AppTypography.bodySmall
                                    .copyWith(color: tc.deepTeal)),
                          ],
                        ),
                      ),
                      Icon(Icons.call_rounded,
                          color: tc.deepTeal, size: 24),
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

  Widget _buildFeaturedPerk(ThemeColors tc) {
    // Trimmed from ~244dp to ~192dp. At its old size this card plus the grid
    // pushed the hotline 74dp below the fold, so the one thing a member wants
    // when something has gone wrong was the one thing they had to hunt for.
    // The button keeps its 16dp vertical padding — anything less drops it under
    // the 48dp touch target.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // Fixed brand greens, not theme-aware ones: in dark mode cs.primary IS
        // primaryLight, so tc.primary and tc.primaryLight resolved to the same
        // value and the gradient flattened to a single flat green.
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.md)),
            child: const Icon(Icons.medical_services_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('AnaKalusugan Teleconsult',
              style: AppTypography.headlineMedium.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.xs),
          Text('Talk to a doctor, for FREE.',
              style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showScheduleForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                // This button sits on white in BOTH themes, so its label must
                // not be theme-aware: tc.primaryText returns the lighter green
                // in dark mode, which is 2.79:1 on white. The fixed dark green
                // is 5.47:1 either way. Brand green alone is only 3.68:1, and
                // labelLarge at 14px counts as normal text, not large.
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                textStyle: AppTypography.labelLarge,
              ),
              // The flow behind this asks for a preferred date and ends in "we
              // will contact you soon", so the label says request, not start.
              child: const Text('Request a Consult'),
            ),
          ),
        ],
      ),
    );
  }

}