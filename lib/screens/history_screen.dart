import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_status_badge.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;
  const HistoryScreen({super.key, required this.userId});

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
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/get_history.php?user_id=${widget.userId}'),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _allItems = data['data'];
          return _allItems;
        }
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Consultation Detail',
                          style: AppTypography.titleLarge
                              .copyWith(color: AppColors.neutral100)),
                      Text('ID: ${item['p_ctrlID'] ?? 'N/A'}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.neutral60)),
                    ],
                  ),
                ),
                AppStatusBadge.fromStatus(context, item['status'] ?? 'Pending'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_hasValue(item['p_patient']))
              _detailRow('Patient Name', item['p_patient']),
            if (_hasValue(item['p_complaint']))
              _detailRow('Chief Complaint', item['p_complaint']),
            if (_hasValue(item['p_history']))
              _detailRow('Medical History', item['p_history']),
            if (_hasValue(item['p_medication']))
              _detailRow('Current Medication', item['p_medication']),
            if (_hasValue(item['p_med']))
              _detailRow('Prescribed Medicine', item['p_med']),
            if (_hasValue(item['p_others']))
              _detailRow('Other Notes', item['p_others']),
            if (_hasValue(item['p_trasfer_comment']))
              _detailRow('Transfer Comment', item['p_trasfer_comment']),
          ],
        ),
      ),
    );
  }

  bool _hasValue(dynamic v) =>
      v != null && v.toString().isNotEmpty && v.toString() != 'None';

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.neutral60)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.neutral90)),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.neutral30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
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
                fillColor: AppColors.surface,
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
                          color: AppColors.surface,
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
                                      color: AppColors.primarySurface,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: const Icon(
                                        Icons.medical_services_rounded,
                                        color: AppColors.primary,
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
                                                        AppColors.neutral100),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(item['created_at'] ?? '',
                                            style: AppTypography.caption
                                                .copyWith(
                                                    color:
                                                        AppColors.neutral60)),
                                      ],
                                    ),
                                  ),
                                  AppStatusBadge.fromStatus(
                                      context, item['status'] ?? 'Pending'),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.neutral50, size: 20),
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