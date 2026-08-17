import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../core/api.dart';
import '../core/session.dart';
import '../widgets/app_status_badge.dart';
import '../core/format.dart';
import '../core/prescription_pdf.dart';
import '../widgets/app_button.dart';
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

  /// Set when the load failed, so a broken connection cannot be mistaken for a
  /// member who simply has no records.
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await Api.get('eprescriptions/list.php');

      if (data['status'] == 'success') {
        setState(() {
          _prescriptions = (data['data'] as List)
              .map((e) => EPrescription.fromJson(e))
              .toList();
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _error = data['message']?.toString() ?? 'The server could not return your records.';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      // Failing to reach the server used to land on the same empty state as a
      // member who genuinely has no records. On this screen empty is the common,
      // legitimate case — 463 consultations in the whole system carry a doctor's
      // note — so a silent failure here is invisible by design.
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not reach the server. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  /// Hands the rendered PDF to the platform's share sheet, which is also where
  /// "save to Files"/"save to Drive" live — one action covers both.
  Future<void> _downloadPdf(EPrescription entry) async {
    // Resolved before the async gap: the sheet this was tapped from may be gone
    // by the time the PDF is built.
    final messenger = ScaffoldMessenger.of(context);

    try {
      final user = await Session.user();

      final bytes = await buildPrescriptionPdf(
        entry: entry,
        patientName: user?['full_name']?.toString() ?? '',
        memberId: user?['id']?.toString() ?? '',
      );

      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: prescriptionFileName(entry, user?['id']?.toString() ?? 'member'),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not create the PDF. $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                _reviewBadge(tc, prescription),
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
            AppButton(
              label: 'Download PDF',
              icon: Icons.download_rounded,
              isFullWidth: true,
              onPressed: () => _downloadPdf(prescription),
            ),

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

  /// Where the consultation sits in the review workflow, or nothing when the
  /// record does not reliably say. Same rule as History: `doctor_status` is
  /// trusted where it reads reviewed and never inferred from its absence.
  Widget _reviewBadge(ThemeColors tc, EPrescription entry) {
    return switch (entry.reviewStatus) {
      'approved' => AppStatusBadge(
          status: 'Approved',
          color: tc.successText,
          backgroundColor: tc.successSurface,
        ),
      'reviewed' => AppStatusBadge(
          status: 'Reviewed',
          color: tc.infoText,
          backgroundColor: tc.infoSurface,
        ),
      _ => const SizedBox.shrink(),
    };
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
          : _error != null
              ? ListView(children: [
                  // minHeight, not a fixed height. This state carries a button
                  // as well as the message — about 290dp of content — and a
                  // rigid fraction of a short screen clips it. Asking for the
                  // space rather than insisting on it lets it grow with the
                  // message and the system font.
                  ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.5),
                      child: AppEmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load your records',
                        subtitle: _error!,
                        actionLabel: 'Try Again',
                        onAction: _loadPrescriptions,
                      )),
                ])
              : _prescriptions.isEmpty
              ? ListView(children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.5),
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
                                _reviewBadge(tc, p),
                                const SizedBox(width: AppSpacing.sm),
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