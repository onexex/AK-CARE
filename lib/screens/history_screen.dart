import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/format.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_status_badge.dart';

class HistoryScreen extends StatefulWidget {
  // No userId: the history returned is the token holder's, decided server-side.
  // Passing one in only ever fed it back as the identity claim.
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _allItems = [];

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchHistory() async {
    try {
      // Whose history this is, is the server's decision now — it used to be
      // decided by a phone number in the query string.
      final data = await Api.get('get_history.php');
      if (data['status'] == 'success') {
        _allItems = data['data'];
        return _allItems;
      }
    } catch (_) {}
    return [];
  }

  Future<void> _onRefresh() async {
    setState(() => _historyFuture = _fetchHistory());
    await _historyFuture;
  }

  List<dynamic> _filtered(List<dynamic> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((i) {
      return (i['p_patient'] ?? '').toString().toLowerCase().contains(q) ||
          (i['p_complaint'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  void _showDetails(Map<String, dynamic> item) {
    // Resolved from this State's context so the whole sheet closure, including
    // the _detailRow helpers, can colour itself for the active theme.
    final tc = ThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: tc.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.medical_services_rounded,
                      color: tc.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Consultation Detail',
                          style: AppTypography.titleLarge
                              .copyWith(color: tc.neutral100)),
                      Text('ID: ${item['p_ctrlID'] ?? 'N/A'}',
                          style: AppTypography.caption
                              .copyWith(color: tc.textSecondary)),
                    ],
                  ),
                ),
                // Same rule as the list row: shown only when a doctor reviewed
                // this consultation, absent when that is unknown.
                if (item['review_status'] == 'reviewed') _reviewedBadge(tc),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_hasValue(item['p_patient']))
              _detailRow(tc, 'Patient Name', item['p_patient']),
            if (_hasValue(item['p_complaint']))
              _detailRow(tc, 'Chief Complaint', item['p_complaint']),
            if (_hasValue(item['p_history']))
              _detailRow(tc, 'Medical History', item['p_history']),
            if (_hasValue(item['p_medication']))
              _detailRow(tc, 'Current Medication', item['p_medication']),
            if (_hasValue(item['p_med']))
              _detailRow(tc, 'Prescribed Medicine', item['p_med']),
            if (_hasValue(item['p_others']))
              _detailRow(tc, 'Other Notes', item['p_others']),
            if (_hasValue(item['p_trasfer_comment']))
              _detailRow(tc, 'Transfer Comment', item['p_trasfer_comment']),
          ],
        ),
      ),
    );
  }

  bool _hasValue(dynamic v) =>
      v != null && v.toString().isNotEmpty && v.toString() != 'None';

  /// The one review state this screen can honestly show.
  ///
  /// Built directly rather than through AppStatusBadge.fromStatus(), which maps
  /// the teleconsult_requests workflow states — 'reviewed' is not one of them,
  /// and would come back as a neutral badge reading "reviewed".
  Widget _reviewedBadge(ThemeColors tc) => AppStatusBadge(
        status: 'Reviewed',
        color: tc.successText,
        backgroundColor: tc.successSurface,
      );

  Widget _detailRow(ThemeColors tc, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(color: tc.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTypography.bodyLarge
                  .copyWith(color: tc.neutral90)),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: tc.neutral30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('Consultation History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by patient or complaint...',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: tc.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtered =
                    _filtered(snapshot.hasData ? snapshot.data! : []);
                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: AppEmptyState(
                            icon: _searchQuery.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.history_rounded,
                            title: _searchQuery.isNotEmpty
                                ? 'No Results'
                                : 'No History Yet',
                            subtitle: _searchQuery.isNotEmpty
                                ? 'Try a different search term.'
                                : 'Your consultations will appear here.',
                          )),
                    ]),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Material(
                          color: tc.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          child: InkWell(
                            onTap: () => _showDetails(item),
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
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
                                      color: tc.primarySurface,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                        Icons.medical_services_rounded,
                                        color: tc.primary,
                                        size: 22),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['p_patient'] ?? 'No Name',
                                            style: AppTypography.titleMedium
                                                .copyWith(
                                                    color:
                                                        tc.neutral100),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(
                                            formatRelativeDate(
                                                item['created_at'] ?? ''),
                                            style: AppTypography.caption
                                                .copyWith(
                                                    color:
                                                        tc.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  // Only ever shown for a consultation a doctor
                                  // has demonstrably reviewed. The server sends
                                  // review_status as null for everything else,
                                  // including the ambiguous rows that used to
                                  // read 'Pending' — see get_history.php.
                                  if (item['review_status'] == 'reviewed') ...[
                                    _reviewedBadge(tc),
                                    const SizedBox(width: AppSpacing.sm),
                                  ],
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
              },
            ),
          ),
        ],
      ),
    );
  }
}