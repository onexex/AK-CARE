import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config.dart';
import '../design_system/app_colors.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('user_session');
      if (json != null) {
        final user = jsonDecode(json);
        final res = await http.get(
          Uri.parse('${AppConfig.baseUrl}/medical_certs.php?user_id=${user['id']}'),
        ).timeout(AppConfig.apiTimeout);
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          setState(() {
            _requests = List<Map<String, dynamic>>.from(data['data'] ?? []);
            _isLoading = false;
          });
          return;
        }
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
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.neutral100)),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Reason', style: AppTypography.labelMedium.copyWith(color: AppColors.neutral80)),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: reasonCtrl, maxLines: 3,
                    enabled: !isSaving,
                    decoration: InputDecoration(hintText: 'e.g. Employment, School, Travel...'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: 'SUBMIT REQUEST', icon: Icons.send_rounded,
                    isLoading: isSaving,
                    onPressed: isSaving ? null : () async {
                      if (reasonCtrl.text.trim().isEmpty) return;
                      setModalState(() => isSaving = true);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final json = prefs.getString('user_session');
                        final user = jsonDecode(json!);
                        final res = await http.post(
                          Uri.parse('${AppConfig.baseUrl}/medical_certs.php'),
                          body: {'user_id': user['id'].toString(), 'reason': reasonCtrl.text.trim()},
                        ).timeout(AppConfig.apiTimeout);
                        final result = jsonDecode(res.body);
                        Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result['message'] ?? 'Request submitted'),
                            backgroundColor: result['status'] == 'success' ? AppColors.success : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ));
                          _loadRequests();
                        }
                      } catch (_) {
                        setModalState(() => isSaving = false);
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

  Color _statusColor(String status) {
    return switch (status?.toLowerCase()) {
      'approved' => AppColors.success,
      'pending' => const Color(0xFFFF9800),
      'rejected' => AppColors.error,
      _ => AppColors.neutral60,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Medical Certificates')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRequestForm,
        backgroundColor: AppColors.primary,
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
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.md)),
                              child: const Icon(Icons.verified_user_rounded, color: Color(0xFFFF9800), size: 24),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(r['reason'] ?? '', style: AppTypography.titleMedium.copyWith(color: AppColors.neutral100), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: _statusColor(r['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text((r['status'] ?? 'pending').toUpperCase(), style: AppTypography.labelSmall.copyWith(color: _statusColor(r['status']))),
                                ),
                              ]),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.neutral50, size: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}