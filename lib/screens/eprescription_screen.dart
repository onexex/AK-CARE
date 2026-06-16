import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/eprescription.dart';
import '../design_system/app_colors.dart';
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
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.medication_liquid_rounded,
                      color: Color(0xFF2196F3), size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prescription',
                          style: AppTypography.titleLarge
                              .copyWith(color: AppColors.neutral100)),
                      Text(_formatDate(prescription.createdAt),
                          style: AppTypography.caption
                              .copyWith(color: AppColors.neutral60)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Info cards
            _infoCard('Doctor', prescription.doctorName.isNotEmpty
                ? prescription.doctorName
                : 'Not specified'),
            _infoCard('Diagnosis', prescription.diagnosis.isNotEmpty
                ? prescription.diagnosis
                : 'Not specified'),
            if (prescription.notes.isNotEmpty)
              _infoCard('Notes', prescription.notes),

            const SizedBox(height: AppSpacing.lg),

            // Medicines list
            Text('Medicines (${prescription.items.length})',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.neutral100)),
            const SizedBox(height: AppSpacing.md),

            if (prescription.items.isEmpty)
              const Text('No medicines listed.',
                  style: TextStyle(color: AppColors.neutral60))
            else
              ...prescription.items.map((item) => _medicineCard(item)),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                    .copyWith(color: AppColors.neutral60)),
          ),
          Expanded(
            child: Text(value,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.neutral90)),
          ),
        ],
      ),
    );
  }

  Widget _medicineCard(EPrescriptionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppElevation.subtle,
        border: const Border(
          left: BorderSide(color: Color(0xFF2196F3), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.medicineName,
              style: AppTypography.titleMedium
                  .copyWith(color: AppColors.neutral100)),
          const SizedBox(height: AppSpacing.sm),
          _medRow('Dosage', item.dosage),
          _medRow('Frequency', item.frequency),
          _medRow('Duration', item.duration),
          _medRow('Quantity', item.quantity),
          if (item.notes.isNotEmpty)
            _medRow('Notes', item.notes),
        ],
      ),
    );
  }

  Widget _medRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral60)),
          ),
          Expanded(
            child: Text(value,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral80)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('E-Prescriptions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescriptions.isEmpty
              ? ListView(children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const AppEmptyState(
                        icon: Icons.medication_liquid_rounded,
                        title: 'No E-Prescriptions',
                        subtitle: 'Your e-prescriptions will appear here.',
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
                        color: AppColors.surface,
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
                                    color: const Color(0xFF2196F3)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.md),
                                  ),
                                  child: const Icon(
                                      Icons.medication_liquid_rounded,
                                      color: Color(0xFF2196F3),
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
                                              : 'E-Prescription',
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                                  color:
                                                      AppColors.neutral100)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${p.itemsCount} medicine(s) · ${_formatDate(p.createdAt)}',
                                          style: AppTypography.caption.copyWith(
                                              color: AppColors.neutral60)),
                                    ],
                                  ),
                                ),
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
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}