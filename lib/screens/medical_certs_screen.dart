import 'package:flutter/material.dart';
import '../core/api.dart';
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
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await Api.get('medical_certs.php');
      if (data['status'] == 'success') {
        setState(() {
          _requests = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _isLoading = false);
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

  Color _statusColor(ThemeColors tc, String status) {
    return switch (status.toLowerCase()) {
      'approved' => tc.success,
      'pending' => AppColors.featureCertificate,
      'rejected' => tc.error,
      _ => tc.neutral60,
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
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
                                Text(r['reason'] ?? '', style: AppTypography.titleMedium.copyWith(color: tc.neutral100), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                  decoration: BoxDecoration(color: _statusColor(tc, r['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text((r['status'] ?? 'pending').toUpperCase(), style: AppTypography.labelSmall.copyWith(color: _statusColor(tc, r['status']))),
                                ),
                              ]),
                            ),
                            Icon(Icons.chevron_right, color: tc.neutral50, size: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}