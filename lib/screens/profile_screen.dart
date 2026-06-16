import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_button.dart';
import '../core/theme_controller.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _user;

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.userData);
  }

  String _initials(String name) {
    final parts = (name ?? '').trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    return (name ?? '').isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialog.show(context: context, title: 'Log Out', message: 'Are you sure you want to log out?', confirmLabel: 'Log Out', isDestructive: true, icon: Icons.logout_rounded);
    if (confirmed != true || !context.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    if (context.mounted) { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false); }
  }

  void _showEditSheet() {
    final contactCtrl = TextEditingController(text: _user['contact'] ?? '');
    final fullName = _user['full_name'] ?? ''; final nameParts = fullName.split(' ');
    final fnameCtrl = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    final lnameCtrl = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    bool isSaving = false;

    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl, left: AppSpacing.xxl, right: AppSpacing.xxl),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppSpacing.sm),
            Text('Edit Profile', style: AppTypography.headlineMedium.copyWith(color: AppColors.neutral100)),
            const SizedBox(height: AppSpacing.xxl),
            Text('Mobile Number', style: AppTypography.labelMedium.copyWith(color: AppColors.neutral80)), const SizedBox(height: AppSpacing.sm),
            TextField(controller: contactCtrl, enabled: !isSaving, decoration: const InputDecoration(hintText: '09XXXXXXXXX')),
            const SizedBox(height: AppSpacing.lg),
            Text('First Name', style: AppTypography.labelMedium.copyWith(color: AppColors.neutral80)), const SizedBox(height: AppSpacing.sm),
            TextField(controller: fnameCtrl, enabled: !isSaving, decoration: const InputDecoration(hintText: 'Enter first name')),
            const SizedBox(height: AppSpacing.lg),
            Text('Last Name', style: AppTypography.labelMedium.copyWith(color: AppColors.neutral80)), const SizedBox(height: AppSpacing.sm),
            TextField(controller: lnameCtrl, enabled: !isSaving, decoration: const InputDecoration(hintText: 'Enter last name')),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(label: 'SAVE CHANGES', icon: Icons.save_rounded, isLoading: isSaving, onPressed: isSaving ? null : () async {
              setModalState(() => isSaving = true);
              try {
                final res = await http.post(Uri.parse('${AppConfig.baseUrl}/update_profile.php'), body: {'user_id': _user['id']?.toString() ?? '', 'contact': contactCtrl.text.trim(), 'm_fname': fnameCtrl.text.trim(), 'm_surname': lnameCtrl.text.trim()}).timeout(AppConfig.apiTimeout);
                final result = jsonDecode(res.body);
                if (result['status'] == 'success') {
                  setState(() { _user['contact'] = contactCtrl.text.trim(); _user['full_name'] = '${fnameCtrl.text.trim()} ${lnameCtrl.text.trim()}'.trim(); });
                  final prefs = await SharedPreferences.getInstance(); await prefs.setString('user_session', jsonEncode(_user));
                  Navigator.pop(ctx);
                  if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)); }
                } else {
                  setModalState(() => isSaving = false);
                  if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Update failed'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)); }
                }
              } catch (_) { setModalState(() => isSaving = false); if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error. Try again.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)); } }
            }),
          ])));
      }));
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final fullName = _user['full_name'] ?? 'Member Name'; final rank = _user['rank'] ?? 'Member'; final contact = _user['contact'] ?? 'N/A'; final userId = _user['id']?.toString() ?? 'N/A';

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(child: Column(children: [
        Container(width: double.infinity, margin: const EdgeInsets.all(AppSpacing.lg), padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.xxl), boxShadow: AppElevation.medium),
          child: Column(children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(AppRadius.xxl)),
              child: Center(child: Text(_initials(fullName), style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800)))),
            const SizedBox(height: AppSpacing.lg),
            Text(fullName, style: AppTypography.titleLarge.copyWith(color: tc.neutral100), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs), decoration: BoxDecoration(color: tc.primarySurface, borderRadius: BorderRadius.circular(AppRadius.full)),
              child: Text(rank.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: tc.primary, letterSpacing: 1))),
          ])),
        AppSectionHeader(title: 'Account Details'), const SizedBox(height: AppSpacing.sm),
        Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: Column(children: [
          _infoTile(Icons.fingerprint, 'Member ID', userId, tc), _infoTile(Icons.phone_android_rounded, 'Mobile Number', contact, tc), _infoTile(Icons.badge_rounded, 'Account Type', rank, tc),
        ])),
        const SizedBox(height: AppSpacing.xxl),
        AppSectionHeader(title: 'Actions'), const SizedBox(height: AppSpacing.sm),
        Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: Column(children: [
          _actionTile(Icons.dark_mode_outlined, 'Dark Mode', () => themeController.toggle(), tc),
          _actionTile(Icons.edit_outlined, 'Edit Profile Information', _showEditSheet, tc),
          const SizedBox(height: AppSpacing.sm),
          _actionTile(Icons.logout_rounded, 'Log Out', () => _logout(context), tc, isDestructive: true),
        ])),
        const SizedBox(height: AppSpacing.huge),
      ])),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, ThemeColors tc) {
    return Container(margin: const EdgeInsets.only(bottom: AppSpacing.sm), padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(AppSpacing.sm), decoration: BoxDecoration(color: tc.primarySurface, borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(icon, color: tc.primary, size: 20)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTypography.caption.copyWith(color: tc.neutral60)), const SizedBox(height: 2),
          Text(value, style: AppTypography.bodyLarge.copyWith(color: tc.neutral100, fontWeight: FontWeight.w600)),
        ])),
      ]));
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap, ThemeColors tc, {bool isDestructive = false}) {
    return Material(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(AppSpacing.sm), decoration: BoxDecoration(color: isDestructive ? tc.errorSurface : tc.primarySurface, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, color: isDestructive ? tc.error : tc.primary, size: 20)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text(label, style: AppTypography.bodyLarge.copyWith(color: isDestructive ? tc.error : tc.neutral100, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, color: isDestructive ? tc.error.withOpacity(0.4) : tc.neutral50, size: 20),
          ]))));
  }
}