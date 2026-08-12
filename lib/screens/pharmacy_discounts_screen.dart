import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';

class PharmacyDiscountsScreen extends StatefulWidget {
  const PharmacyDiscountsScreen({super.key});

  @override
  State<PharmacyDiscountsScreen> createState() => _PharmacyDiscountsScreenState();
}

class _PharmacyDiscountsScreenState extends State<PharmacyDiscountsScreen> {
  List<Map<String, dynamic>> _pharmacies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  Future<void> _loadPharmacies() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/pharmacy_discounts.php'),
      ).timeout(AppConfig.apiTimeout);
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() {
          _pharmacies = List<Map<String, dynamic>>.from(data['data']);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('Pharmacy Discounts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pharmacies.isEmpty
              ? ListView(children: [
                  const SizedBox(height: 200),
                  Center(child: Text('No partner pharmacies yet.', style: AppTypography.bodyMedium.copyWith(color: tc.textSecondary))),
                ])
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _pharmacies.length,
                  itemBuilder: (context, index) {
                    final p = _pharmacies[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: tc.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppElevation.subtle,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.featurePharmacy.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.local_pharmacy_rounded, color: AppColors.featurePharmacy, size: 28),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['name'] ?? '', style: AppTypography.titleMedium.copyWith(color: tc.neutral100)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tc.successSurface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${p['discount'] ?? '10%'} OFF', style: AppTypography.labelSmall.copyWith(color: tc.successText)),
                                ),
                                if ((p['address'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(p['address'] ?? '', style: AppTypography.caption.copyWith(color: tc.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: tc.neutral50, size: 20),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}