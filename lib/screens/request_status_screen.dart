import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_status_badge.dart';
import '../widgets/app_dialog.dart';

class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final _filters = ['All', 'Pending', 'Confirmed', 'Completed'];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('user_session');
      if (json != null) {
        final user = jsonDecode(json);
        final userId = user['contact'].toString();
        final response = await http.get(
          Uri.parse('${AppConfig.baseUrl}/get_my_requests.php?user_id=$userId'),
        ).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['status'] == 'success') {
            setState(() {
              _requests = result['data'] ?? [];
              _isLoading = false;
            });
            return;
          }
        }
        throw Exception('Server error');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Connection error. Check your internet.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Cancel Request',
      message:
          'Are you sure you want to cancel this consultation request? This action cannot be undone.',
      confirmLabel: 'Yes, Cancel',
      isDestructive: true,
      icon: Icons.cancel_outlined,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/cancel_request.php'),
        body: {'id': requestId},
      ).timeout(const Duration(seconds: 10));
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Request cancelled successfully.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating),
        );
        _fetchRequests();
      } else {
        throw Exception(result['message'] ?? 'Failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: Could not cancel request. $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showDetails(Map<String, dynamic> req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl),
          children: [
            Row(
              children: [
                Text('Request Details',
                    style: AppTypography.titleLarge
                        .copyWith(color: AppColors.neutral100)),
                const Spacer(),
                AppStatusBadge.fromStatus(context, req['status'] ?? 'Pending'),
              ],
            ),
            const Divider(height: AppSpacing.xxxl),
            _detailRow('Reason', req['consultation_reason'] ?? 'N/A'),
            _detailRow('Preferred Date', req['preferred_date'] ?? 'N/A'),
            _detailRow('Request ID', '#${req['request_id'] ?? 'N/A'}'),
            _detailRow(
                'Status', (req['status'] ?? 'Pending').toUpperCase()),
            if ((req['status'] ?? '').toString().toLowerCase() == 'pending') ...[
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _cancelRequest(req['request_id'].toString());
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text('CANCEL REQUEST'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.neutral60))),
          Expanded(
              child: Text(value,
                  style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neutral90,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  List<dynamic> _filtered() {
    if (_selectedFilter == 'All') return _requests;
    return _requests.where((r) {
      final s = (r['status'] ?? '').toString().toLowerCase();
      return s == _selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('My Consult Requests'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: _fetchRequests),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              itemCount: _filters.length,
              itemBuilder: (context, i) {
                final sel = _selectedFilter == _filters[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_filters[i]),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _selectedFilter = _filters[i]),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                        color:
                            sel ? AppColors.primary : AppColors.neutral70),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.full)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRequests,
                    child: filtered.isEmpty
                        ? ListView(children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: AppEmptyState(
                                  icon: Icons.assignment_late_outlined,
                                  title: _requests.isEmpty
                                      ? 'No Requests Yet'
                                      : 'No $_selectedFilter Requests',
                                  subtitle: _requests.isEmpty
                                      ? 'Your teleconsult requests will appear here.'
                                      : 'No requests match the selected filter.',
                                )),
                          ])
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                                AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final req = filtered[i];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: Material(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  child: InkWell(
                                    onTap: () => _showDetails(req),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.lg),
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          AppSpacing.lg),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.lg),
                                        boxShadow: AppElevation.subtle,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                                AppSpacing.md),
                                            decoration: BoxDecoration(
                                              color: AppColors.primarySurface,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.md),
                                            ),
                                            child: const Icon(
                                                Icons
                                                    .medical_services_outlined,
                                                color: AppColors.primary,
                                                size: 22),
                                          ),
                                          const SizedBox(
                                              width: AppSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    req['consultation_reason'] ??
                                                        'No reason',
                                                    style: AppTypography
                                                        .titleMedium
                                                        .copyWith(
                                                            color: AppColors
                                                                .neutral100),
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                        'Preferred: ${req['preferred_date'] ?? 'N/A'}',
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                                color: AppColors
                                                                    .neutral60)),
                                                    const SizedBox(
                                                        width:
                                                            AppSpacing.md),
                                                    Text(
                                                        '#${req['request_id'] ?? 'N/A'}',
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                                color: AppColors
                                                                    .neutral50)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          AppStatusBadge.fromStatus(
                                              context, req['status'] ?? 'Pending'),
                                          const SizedBox(
                                              width: AppSpacing.sm),
                                          const Icon(Icons.chevron_right,
                                              color: AppColors.neutral50,
                                              size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}