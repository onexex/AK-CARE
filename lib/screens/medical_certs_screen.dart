import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../core/api.dart';
import '../core/certificate_pdf.dart';
import '../core/format.dart';
import '../core/session.dart';
import '../models/medical_certificate.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_button.dart';

class MedicalCertsScreen extends StatefulWidget {
  const MedicalCertsScreen({super.key});

  @override
  State<MedicalCertsScreen> createState() => _MedicalCertsScreenState();
}

class _MedicalCertsScreenState extends State<MedicalCertsScreen> {
  List<MedicalCertificate> _requests = [];
  bool _isLoading = true;

  /// Set when the load failed, so an unreachable server is not shown as "you
  /// have never asked for a certificate".
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await Api.get('medical_certs.php');
      if (data['status'] == 'success') {
        setState(() {
          _requests = (data['data'] as List? ?? [])
              .map((e) => MedicalCertificate.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList();
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _error = data['message']?.toString() ??
            'The server could not return your certificates.';
        _isLoading = false;
      });
    } on ApiException catch (e) {
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

  /// Renders the certificate and hands it to the platform share sheet, which is
  /// also where "save to Files" lives.
  Future<void> _downloadPdf(MedicalCertificate cert) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final bytes = await buildCertificatePdf(
        cert: cert,
        memberId: await Session.memberId(),
      );

      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: certificateFileName(cert),
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

  void _showDetails(MedicalCertificate cert) {
    final tc = ThemeColors.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl),
          children: [
            Text(
                cert.isIssued
                    ? 'Medical Certificate'
                    : cert.isRejected
                        ? 'Request Declined'
                        : 'Request Submitted',
                style: AppTypography.titleLarge.copyWith(color: tc.neutral100)),
            if (cert.certificateNo.isNotEmpty)
              Text('No. ${cert.certificateNo}',
                  style: AppTypography.caption.copyWith(color: tc.textSecondary)),
            const SizedBox(height: AppSpacing.xxl),

            _detailRow(tc, 'Your reason', cert.reason),

            if (cert.isIssued) ...[
              if (cert.patientName.isNotEmpty)
                _detailRow(tc, 'Patient', cert.patientName),
              if (cert.examinedOn.isNotEmpty)
                _detailRow(tc, 'Date examined', formatDate(cert.examinedOn)),
              if (cert.diagnosis.isNotEmpty)
                _detailRow(tc, 'Diagnosis', cert.diagnosis),
              if (cert.fitnessLabel.isNotEmpty)
                _detailRow(tc, 'Assessment', cert.fitnessLabel),
              if (cert.restrictions.isNotEmpty)
                _detailRow(tc, 'Restrictions', cert.restrictions),
              if (cert.hasRestPeriod)
                _detailRow(tc, 'Advised rest',
                    '${formatDate(cert.restFrom)} to ${formatDate(cert.restTo)}'),
              if (cert.remarks.isNotEmpty)
                _detailRow(tc, 'Remarks', cert.remarks),
              _detailRow(
                  tc,
                  'Issued by',
                  cert.issuedLicense.isNotEmpty
                      ? '${cert.issuedBy} — PRC ${cert.issuedLicense}'
                      : cert.issuedBy),
              if (cert.issuedAt.isNotEmpty)
                _detailRow(tc, 'Issued on', formatDate(cert.issuedAt)),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'DOWNLOAD PDF',
                icon: Icons.download_rounded,
                isFullWidth: true,
                onPressed: () => _downloadPdf(cert),
              ),
            ] else if (cert.isRejected) ...[
              if (cert.rejectionReason.isNotEmpty)
                _detailRow(tc, 'Reason given', cert.rejectionReason),
              const SizedBox(height: AppSpacing.md),
              Text(
                  'You can submit a new request once the reason above has been addressed.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: tc.textSecondary)),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                  'A doctor will review this request. You will be able to download the certificate here once it has been issued.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: tc.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(ThemeColors tc, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  AppTypography.labelMedium.copyWith(color: tc.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTypography.bodyLarge.copyWith(color: tc.neutral90)),
        ],
      ),
    );
  }

  void _showRequestForm() {
    final reasonCtrl = TextEditingController();
    bool isSaving = false;

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
                left: AppSpacing.xxl, right: AppSpacing.xxl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Medical Certificate',
                      style: AppTypography.headlineMedium.copyWith(color: tc.neutral100)),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Reason', style: AppTypography.labelMedium.copyWith(color: tc.neutral80)),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: reasonCtrl, maxLines: 3,
                    enabled: !isSaving,
                    decoration: const InputDecoration(hintText: 'e.g. Employment, School, Travel...'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: 'SUBMIT REQUEST', icon: Icons.send_rounded,
                    isLoading: isSaving,
                    onPressed: isSaving ? null : () async {
                      if (reasonCtrl.text.trim().isEmpty) return;
                      setModalState(() => isSaving = true);

                      // Resolved before the async gap; the sheet's context is
                      // defunct once it has been popped.
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);

                      try {
                        final result = await Api.post(
                          'medical_certs.php',
                          body: {'reason': reasonCtrl.text.trim()},
                        );
                        navigator.pop();
                        messenger.showSnackBar(SnackBar(
                          content: Text(result['message'] ?? 'Request submitted'),
                          backgroundColor: result['status'] == 'success' ? tc.success : tc.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                        if (mounted) _loadRequests();
                      } catch (_) {
                        if (ctx.mounted) setModalState(() => isSaving = false);
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

  /// Colour and wording come from the server's `stage`, so a request cannot be
  /// described one way in the list and another in the sheet.
  (Color, String) _stageStyle(ThemeColors tc, MedicalCertificate cert) {
    return switch (cert.stage) {
      'issued' => (tc.success, 'ISSUED'),
      'rejected' => (tc.error, 'DECLINED'),
      _ => (AppColors.featureCertificate, 'AWAITING A DOCTOR'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('Medical Certificates')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRequestForm,
        backgroundColor: tc.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ListView(children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: AppEmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load your certificates',
                        subtitle: _error!,
                        actionLabel: 'Try Again',
                        onAction: _loadRequests,
                      ))
                ])
              : _requests.isEmpty
              ? ListView(children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4,
                      child: const AppEmptyState(icon: Icons.verified_user_rounded, title: 'No Requests', subtitle: 'Tap + to request a medical certificate.'))
                ])
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _requests.length,
                    itemBuilder: (context, i) {
                      final r = _requests[i];
                      final (stageColor, stageLabel) = _stageStyle(tc, r);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Material(
                          color: tc.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: InkWell(
                            // The row has always had a chevron; until now it led
                            // nowhere, because there was nothing behind a request
                            // to show.
                            onTap: () => _showDetails(r),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.featureCertificate.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.md)),
                              child: const Icon(Icons.verified_user_rounded, color: AppColors.featureCertificate, size: 24),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(r.reason, style: AppTypography.titleMedium.copyWith(color: tc.neutral100), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                    decoration: BoxDecoration(color: stageColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text(stageLabel, style: AppTypography.labelSmall.copyWith(color: stageColor)),
                                  ),
                                  if (r.downloadable) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(Icons.picture_as_pdf_rounded, size: 14, color: tc.textSecondary),
                                  ],
                                ]),
                              ]),
                            ),
                            Icon(Icons.chevron_right, color: tc.neutral50, size: 20),
                          ],
                        ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}