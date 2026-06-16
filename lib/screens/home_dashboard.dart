import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_section_header.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import 'news_screen.dart';
import 'perks_screen.dart';
import 'profile_screen.dart';
import 'community_feed_screen.dart';
import 'notifications_screen.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import 'dart:convert';

class HomeDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeDashboard({super.key, required this.userData});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _unreadNotifs = 0;
  int _pendingRequests = 0;
  String? _latestActivity;
  bool _activityLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final userId = widget.userData['id']?.toString() ?? '';
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/community/dashboard_activity.php?user_id=$userId'),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() {
          _unreadNotifs = data['data']['unread_notifications'] ?? 0;
          _pendingRequests = data['data']['pending_requests'] ?? 0;
          _latestActivity = data['data']['latest_post'] != null
              ? data['data']['latest_post']['content']
              : data['data']['latest_history'] != null
                  ? 'Consultation: ${data['data']['latest_history']['patient']}'
                  : null;
          _activityLoaded = true;
        });
      }
    } catch (_) {}
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your AK MIYEMBRO account?',
      confirmLabel: 'Log Out',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed != true || !context.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final fullName = widget.userData['full_name'] ?? 'Member';
    final rank = widget.userData['rank'] ?? 'Member';
    final userId = widget.userData['contact'].toString();

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(
        title: Text('AK MIYEMBRO',
            style: AppTypography.titleLarge.copyWith(color: Colors.white, letterSpacing: 1)),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              tooltip: 'Notifications',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            if (_unreadNotifs > 0)
              Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 16, minHeight: 16), child: Text('$_unreadNotifs', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
          ]),
          IconButton(icon: const Icon(Icons.logout_rounded, size: 22), tooltip: 'Log out', onPressed: () => _logout(context)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxxl),
            decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xxl))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.lg)), alignment: Alignment.center,
                  child: Text(_initials(fullName), style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_greeting, style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 2),
                  Text(fullName, style: AppTypography.titleLarge.copyWith(color: Colors.white)),
                ])),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Text(rank.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: Colors.white, letterSpacing: 1))),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_activityLoaded && (_unreadNotifs > 0 || _pendingRequests > 0))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
                child: Row(children: [
                  if (_pendingRequests > 0) _MiniStat(icon: Icons.pending_actions_rounded, count: _pendingRequests, label: 'Pending', color: tc.warning, tc: tc),
                  if (_unreadNotifs > 0) _MiniStat(icon: Icons.notifications_rounded, count: _unreadNotifs, label: 'Alerts', color: tc.error, tc: tc),
                ])),
            ),
          const SizedBox(height: AppSpacing.xxl),
          AppSectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
              return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: crossAxisCount, crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md, childAspectRatio: 1.0, children: [
                _MenuTile(title: 'History', icon: Icons.history_rounded, color: const Color(0xFFFF9800), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(userId: userId)))),
                _MenuTile(title: 'Perks', icon: Icons.card_giftcard_rounded, color: tc.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerksScreen()))),
                _MenuTile(title: 'News', icon: Icons.newspaper_rounded, color: const Color(0xFF2196F3), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen()))),
                _MenuTile(title: 'Community', icon: Icons.people_rounded, color: const Color(0xFF9C27B0), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityFeedScreen()))),
                _MenuTile(title: 'Profile', icon: Icons.person_rounded, color: const Color(0xFFE91E63), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userData: widget.userData)))),
              ]);
            }),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppSectionHeader(title: 'Your Account', actionLabel: 'View All', onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userData: widget.userData)))),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
              child: Row(children: [
                _StatItem(icon: Icons.phone_android_rounded, label: 'Contact', value: widget.userData['contact'] ?? 'N/A', tc: tc),
                _buildDivider(tc),
                _StatItem(icon: Icons.military_tech_rounded, label: 'Rank', value: rank, tc: tc),
                _buildDivider(tc),
                _StatItem(icon: Icons.fingerprint, label: 'ID', value: widget.userData['id']?.toString() ?? 'N/A', tc: tc),
              ])),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ]),
      ),
    );
  }

  Widget _buildDivider(ThemeColors tc) => Container(width: 1, height: 40, color: tc.neutral30);
}

class _MiniStat extends StatelessWidget {
  final IconData icon; final int count; final String label; final Color color; final ThemeColors tc;
  const _MiniStat({required this.icon, required this.count, required this.label, required this.color, required this.tc});
  @override
  Widget build(BuildContext context) => Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text('$count $label', style: AppTypography.labelSmall.copyWith(color: tc.neutral90))]));
}

class _MenuTile extends StatelessWidget {
  final String title; final IconData icon; final Color color; final VoidCallback onTap;
  const _MenuTile({required this.title, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Material(color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.lg), splashColor: color.withOpacity(0.08),
        child: Container(decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle), padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.md)), child: Icon(icon, size: 28, color: color)),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.labelLarge.copyWith(color: tc.neutral90), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]))));
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon; final String label; final String value; final ThemeColors tc;
  const _StatItem({required this.icon, required this.label, required this.value, required this.tc});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, size: 22, color: tc.primary),
    const SizedBox(height: AppSpacing.sm),
    Text(value, style: AppTypography.titleMedium.copyWith(color: tc.neutral100), maxLines: 1, overflow: TextOverflow.ellipsis),
    const SizedBox(height: 2),
    Text(label, style: AppTypography.caption.copyWith(color: tc.neutral60)),
  ]));
}