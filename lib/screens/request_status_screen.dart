import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/format.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
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
      // Which member's requests these are is settled by the token, not by a
      // member_id this screen looks up and sends.
      final result = await Api.get('get_my_requests.php');
      if (result['status'] == 'success') {
        setState(() {
          _requests = result['data'] ?? [];
          _isLoading = false;
        });
        return;
      }
      throw Exception('Server error');
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
    if (confirmed != true) return;
    // Kept separate from the check above: folded into one condition, the
    // analyser cannot see this as a mounted guard for the context used below.
    if (!mounted) return;

    setState(() => _isLoading = true);

    // Resolved before the request goes out. If the user leaves this screen while
    // it is in flight, reading ScaffoldMessenger from a defunct context throws;
    // the messenger itself lives above the route and stays valid.
    final messenger = ScaffoldMessenger.of(context);

    try {
      // The server cancels only a request belonging to the token holder, so
      // nothing about who is asking needs to be sent.
      final result =
          await Api.post('cancel_request.php', body: {'id': requestId});
      if (result['status'] == 'success') {
        messenger.showSnackBar(
          const SnackBar(
              content: Text('Request cancelled successfully.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating),
        );
        if (mounted) _fetchRequests();
      } else {
        throw Exception(result['message'] ?? 'Failed');
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      messenger.showSnackBar(
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
        builder: (context, scrollController) {
          final tc = ThemeColors.of(context);
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl),
            children: [
              Row(
                children: [
                  Text('Request Details',
                      style: AppTypography.titleLarge
                          .copyWith(color: tc.neutral100)),
                  const Spacer(),
                  AppStatusBadge.fromStatus(context, req['status']?.toString()),
                ],
              ),
              const Divider(height: AppSpacing.xxxl),
              _detailRow(tc, 'Reason', req['consultation_reason'] ?? 'N/A'),
              _detailRow(tc, 'Preferred Date',
                  formatDate(req['preferred_date'] ?? '')),
              _detailRow(tc, 'Request ID', '#${req['request_id'] ?? 'N/A'}'),
              _detailRow(
                  tc, 'Status', (req['status'] ?? 'Pending').toUpperCase()),
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
                      foregroundColor: tc.error,
                      side: BorderSide(color: tc.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(ThemeColors tc, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: AppTypography.bodyMedium
                      .copyWith(color: tc.textSecondary))),
          Expanded(
              child: Text(value,
                  style: AppTypography.bodyMedium.copyWith(
                      color: tc.neutral90,
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
    final tc = ThemeColors.of(context);
    final filtered = _filtered();
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
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
          // Sizes to its children rather than a fixed 48dp box, so the chips
          // grow with the system font instead of clipping. A handful of filters
          // does not need a lazy builder.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: List.generate(_filters.length, (i) {
                final sel = _selectedFilter == _filters[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: FilterChip(
                    label: Text(_filters[i]),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _selectedFilter = _filters[i]),
                    backgroundColor: tc.surface,
                    selectedColor: tc.primarySurface,
                    checkmarkColor: tc.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                        color: sel ? tc.primaryText : tc.textSecondary),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.full)),
                  ),
                );
              }),
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
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height *
                                            0.4),
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
                                  color: tc.surface,
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
                                              color: tc.primarySurface,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.md),
                                            ),
                                            child: Icon(
                                                Icons
                                                    .medical_services_outlined,
                                                color: tc.primary,
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
                                                            color: tc
                                                                .neutral100),
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis),
                                                const SizedBox(height: 4),
                                                // Both labels are Flexible: as
                                                // fixed-width Text they overflowed
                                                // the row by a few pixels once real
                                                // requests loaded, which only showed
                                                // up when this list stopped being
                                                // empty. The date gives way first;
                                                // the id is short and rarely needs to.
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      // No 'Preferred:' prefix.
                                                      // With it, the date lost
                                                      // its year to ellipsis —
                                                      // and in a list of consult
                                                      // requests the label is
                                                      // saying what the reader
                                                      // already knows. The detail
                                                      // sheet names the field.
                                                      child: Text(
                                                          formatDate(req['preferred_date'] ?? ''),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: AppTypography
                                                              .caption
                                                              .copyWith(
                                                                  color: tc
                                                                      .textSecondary)),
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                            AppSpacing.sm),
                                                    // Not Flexible: the id is two
                                                    // or three characters and
                                                    // should take its natural
                                                    // width. Flexing both made
                                                    // them share the space and
                                                    // ellipsised the date away.
                                                    Text(
                                                        '#${req['request_id'] ?? 'N/A'}',
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                                color: tc
                                                                    .textMuted)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          AppStatusBadge.fromStatus(context,
                                              req['status']?.toString()),
                                          const SizedBox(
                                              width: AppSpacing.sm),
                                          Icon(Icons.chevron_right,
                                              color: tc.neutral50,
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