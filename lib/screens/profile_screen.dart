import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/session.dart';
import '../core/format.dart';
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
import 'member_qr_screen.dart';

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
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialog.show(context: context, title: 'Log Out', message: 'Are you sure you want to log out?', confirmLabel: 'Log Out', isDestructive: true, icon: Icons.logout_rounded);
    if (confirmed != true || !context.mounted) return;
    // Revoke on the server first so a copy of the token cannot be replayed; the
    // local clear happens either way, since someone tapping Log Out with no
    // connection should still end up logged out.
    try {
      await Api.post('logout.php');
    } catch (_) {}
    await Session.clear();
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
        final tc = ThemeColors.of(context);
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl, left: AppSpacing.xxl, right: AppSpacing.xxl),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppSpacing.sm),
            Text('Edit Profile', style: AppTypography.headlineMedium.copyWith(color: tc.neutral100)),
            const SizedBox(height: AppSpacing.xxl),
            Text('Mobile Number', style: AppTypography.labelMedium.copyWith(color: tc.neutral80)), const SizedBox(height: AppSpacing.sm),
            TextField(controller: contactCtrl, enabled: !isSaving, decoration: const InputDecoration(hintText: '09XXXXXXXXX')),
            const SizedBox(height: AppSpacing.lg),
            Text('First Name', style: AppTypography.labelMedium.copyWith(color: tc.neutral80)), const SizedBox(height: AppSpacing.sm),
            TextField(controller: fnameCtrl, enabled: !isSaving, decoration: const InputDecoration(hintText: 'Enter first name')),
            const SizedBox(height: AppSpacing.lg),
            Text('Last Name', style: AppTypography.labelMedium.copyWith(color: tc.neutral80)), const SizedBox(height: AppSpacing.sm),
            TextField(controller: lnameCtrl, enabled: !isSaving, decoration: const InputDecoration(hintText: 'Enter last name')),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(label: 'SAVE CHANGES', icon: Icons.save_rounded, isLoading: isSaving, onPressed: isSaving ? null : () async {
              setModalState(() => isSaving = true);
              // Resolved before the async gap; the sheet's context is defunct once popped.
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              try {
                // The profile updated is the token holder's. A user_id here was
                // enough to rewrite any member's name and contact number.
                final result = await Api.post('update_profile.php', body: {'contact': contactCtrl.text.trim(), 'm_fname': fnameCtrl.text.trim(), 'm_surname': lnameCtrl.text.trim()});
                if (result['status'] == 'success') {
                  if (mounted) setState(() { _user['contact'] = contactCtrl.text.trim(); _user['full_name'] = '${fnameCtrl.text.trim()} ${lnameCtrl.text.trim()}'.trim(); });
                  await Session.updateUser(_user);
                  navigator.pop();
                  messenger.showSnackBar(const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                } else {
                  if (ctx.mounted) setModalState(() => isSaving = false);
                  messenger.showSnackBar(SnackBar(content: Text(result['message'] ?? 'Update failed'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                }
              } catch (_) { if (ctx.mounted) setModalState(() => isSaving = false); messenger.showSnackBar(const SnackBar(content: Text('Network error. Try again.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)); }
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
        const AppSectionHeader(title: 'Account Details'), const SizedBox(height: AppSpacing.sm),
        Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: Column(children: [
          _infoTile(Icons.fingerprint, 'Member ID', userId, tc), _infoTile(Icons.phone_android_rounded, 'Mobile Number', formatPhMobile(contact), tc), _infoTile(Icons.badge_rounded, 'Account Type', rank, tc),
        ])),
        const SizedBox(height: AppSpacing.xxl),
        const AppSectionHeader(title: 'Actions'), const SizedBox(height: AppSpacing.sm),
        Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: Column(children: [
          _actionTile(Icons.dark_mode_outlined, 'Dark Mode', () => themeController.toggle(), tc,
              trailing: Switch(
                value: tc.isDark,
                onChanged: (_) => themeController.toggle(),
              )),
          const SizedBox(height: AppSpacing.sm),
          _actionTile(Icons.qr_code_2_rounded, 'My QR Code', () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemberQrScreen(userData: _user))), tc,
              trailing: Icon(Icons.chevron_right, color: tc.neutral50, size: 20)),
          const SizedBox(height: AppSpacing.sm),
          _actionTile(Icons.edit_outlined, 'Edit Profile Information', _showEditSheet, tc,
              trailing: Icon(Icons.chevron_right, color: tc.neutral50, size: 20)),
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
          Text(label, style: AppTypography.caption.copyWith(color: tc.textSecondary)), const SizedBox(height: 2),
          Text(value, style: AppTypography.bodyLarge.copyWith(color: tc.neutral100, fontWeight: FontWeight.w600)),
        ])),
      ]));
  }

  /// A row in Actions. [trailing] says what kind of row it is: a chevron means
  /// it opens something, a switch means it toggles, nothing means it acts on the
  /// spot. Every row used to show a chevron, which promised navigation from a
  /// theme toggle and from Log Out.
  Widget _actionTile(IconData icon, String label, VoidCallback onTap, ThemeColors tc, {bool isDestructive = false, Widget? trailing}) {
    return Material(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(AppSpacing.sm), decoration: BoxDecoration(color: isDestructive ? tc.errorSurface : tc.primarySurface, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, color: isDestructive ? tc.error : tc.primary, size: 20)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text(label, style: AppTypography.bodyLarge.copyWith(color: isDestructive ? tc.error : tc.neutral100, fontWeight: FontWeight.w600))),
            if (trailing != null) trailing,
          ]))));
  }
}