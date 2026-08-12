import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/format.dart';
import '../core/config.dart';
import '../models/eprescription.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_empty_state.dart';

class EPrescriptionScreen extends StatefulWidget {
  const EPrescriptionScreen({super.key});

  @override
  State<EPrescriptionScreen> createState() => _EPrescriptionScreenState();
}

class _EPrescriptionScreenState extends State<EPrescriptionScreen> {
  List<EPrescription> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('user_session');
      if (json != null) {
        final user = jsonDecode(json);
        final userId = user['id'].toString();

        final res = await http.get(
          Uri.parse('${AppConfig.baseUrl}/eprescriptions/list.php?user_id=$userId'),
        ).timeout(AppConfig.apiTimeout);

        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          setState(() {
            _prescriptions = (data['data'] as List)
                .map((e) => EPrescription.fromJson(e))
                .toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _showDetails(EPrescription prescription) {
    // Resolved from this State's context so the whole sheet closure, including
    // the card helpers, can colour itself for the active theme.
    final tc = ThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl),
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.featureNews.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.medication_liquid_rounded,
                      color: AppColors.featureNews, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          prescription.hasPrescription
                              ? 'Prescription'
                              : "Doctor's Notes",
                          style: AppTypography.titleLarge
                              .copyWith(color: tc.neutral100)),
                      Text(formatRelativeDate(prescription.consultedOn),
                          style: AppTypography.caption
                              .copyWith(color: tc.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Info cards
            _infoCard(tc, 'Doctor', prescription.doctorName.isNotEmpty
                ? prescription.doctorName
                : 'Not specified'),
            if (prescription.complaint.isNotEmpty)
              _infoCard(tc, 'Complaint', prescription.complaint),

            const SizedBox(height: AppSpacing.lg),

            // The prescription as the doctor wrote it. Free text, not a
            // structured medicine list — there is no dosage or frequency behind
            // it to lay out in columns.
            if (prescription.hasPrescription) ...[
              Text('Prescription',
                  style: AppTypography.titleMedium
                      .copyWith(color: tc.neutral100)),
              const SizedBox(height: AppSpacing.md),
              _textCard(tc, prescription.prescription, accent: true),
              const SizedBox(height: AppSpacing.lg),
            ],

            if (prescription.notes.isNotEmpty) ...[
              Text("Doctor's Notes",
                  style: AppTypography.titleMedium
                      .copyWith(color: tc.neutral100)),
              const SizedBox(height: AppSpacing.md),
              _textCard(tc, prescription.notes),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(ThemeColors tc, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppElevation.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: AppTypography.labelMedium
                    .copyWith(color: tc.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: AppTypography.bodyMedium
                    .copyWith(color: tc.neutral90)),
          ),
        ],
      ),
    );
  }

  /// Free text as written by the doctor, newlines preserved.
  Widget _textCard(ThemeColors tc, String value, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppElevation.subtle,
        border: accent
            ? const Border(
                left: BorderSide(color: AppColors.featureNews, width: 3),
              )
            : null,
      ),
      child: Text(value,
          style: AppTypography.bodyMedium.copyWith(color: tc.neutral90)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('E-Prescriptions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescriptions.isEmpty
              ? ListView(children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const AppEmptyState(
                        icon: Icons.medication_liquid_rounded,
                        title: 'Nothing from a doctor yet',
                        subtitle:
                            'Prescriptions and doctor\'s notes from your consultations will appear here.',
                      )),
                ])
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final p = _prescriptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Material(
                        color: tc.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: InkWell(
                          onTap: () => _showDetails(p),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                              boxShadow: AppElevation.subtle,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.featureNews
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.md),
                                  ),
                                  child: const Icon(
                                      Icons.medication_liquid_rounded,
                                      color: AppColors.featureNews,
                                      size: 24),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          p.doctorName.isNotEmpty
                                              ? p.doctorName
                                              : 'Attending doctor',
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                                  color:
                                                      tc.neutral100)),
                                      const SizedBox(height: 4),
                                      // Says which of the two this record is,
                                      // rather than counting medicines that are
                                      // not itemised anywhere.
                                      Text(
                                          '${p.hasPrescription ? 'Prescription' : "Doctor's notes"} · ${formatRelativeDate(p.consultedOn)}',
                                          style: AppTypography.caption.copyWith(
                                              color: tc.textSecondary)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: tc.neutral50, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

}