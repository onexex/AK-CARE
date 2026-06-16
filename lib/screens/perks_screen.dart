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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          bool loading = false;

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
                          color: AppColors.neutral100)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Tell us your concern and preferred schedule.',
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutral60)),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Reason for Consultation',
                      style: AppTypography.labelMedium.copyWith(
                          color: AppColors.neutral80)),
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
                          color: AppColors.neutral80)),
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
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
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
                        setModalState(() => loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
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
            _buildFeaturedPerk(),
            const SizedBox(height: AppSpacing.xxl),
            AppSectionHeader(title: 'Other Benefits'),
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
                  childAspectRatio: 1.1,
                  children: [
                    _perkCard(
                        'E-Prescription',
                        Icons.medication_liquid_rounded,
                        const Color(0xFF2196F3),
                        'View history',
                        () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const EPrescriptionScreen())),
                        tc),
                    _perkCard(
                        'Pharmacy Disc.',
                        Icons.local_pharmacy_rounded,
                        const Color(0xFFE91E63),
                        'Up to 10% off',
                        () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const PharmacyDiscountsScreen())),
                        tc),
                    _perkCard(
                        'Consult Requests',
                        Icons.pending_actions_rounded,
                        const Color(0xFF673AB7),
                        'Track status',
                        () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const RequestStatusScreen())),
                        tc),
                    _perkCard(
                        'Med Certificate',
                        Icons.verified_user_rounded,
                        const Color(0xFFFF9800),
                        'Fast request',
                        () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const MedicalCertsScreen())),
                        tc),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
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
                        color: AppColors.deepTeal.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.deepTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: const Icon(Icons.support_agent_rounded,
                            color: AppColors.deepTeal, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AnaKalusugan Hotline',
                                style: AppTypography.titleMedium
                                    .copyWith(color: AppColors.deepTeal)),
                            const SizedBox(height: 2),
                            Text('Tap to call: 0935 242 7713',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.deepTeal.withOpacity(0.7))),
                          ],
                        ),
                      ),
                      const Icon(Icons.call_rounded,
                          color: AppColors.deepTeal, size: 24),
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
            end: Alignment.bottomRight),
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
                borderRadius: BorderRadius.circular(AppRadius.md)),
            child: const Icon(Icons.medical_services_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('AnaKalusugan Teleconsult',
              style: AppTypography.headlineMedium.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.xs),
          Text('Talk to a doctor, for FREE.',
              style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8))),
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
                    horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                textStyle: AppTypography.labelLarge,
              ),
              child: const Text('Start Consult Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _perkCard(String title, IconData icon, Color color, String sub,
      VoidCallback onTap, ThemeColors tc) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: tc.surface,
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
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title,
                  style: AppTypography.labelLarge
                      .copyWith(color: tc.neutral90),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.xs),
              Text(sub,
                  style: AppTypography.caption
                      .copyWith(color: tc.neutral60)),
            ],
          ),
        ),
      ),
    );
  }
}