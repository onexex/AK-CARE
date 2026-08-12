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
import '../widgets/app_feature_tile.dart';
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
  bool _activityLoaded = false;

  /// The most recent thing this member did. Null when they have no history.
  _Activity? _activity;

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
        final d = data['data'];
        setState(() {
          _unreadNotifs = d['unread_notifications'] ?? 0;
          _pendingRequests = d['pending_requests'] ?? 0;
          _activity = _latestOf(d['latest_post'], d['latest_history']);
          _activityLoaded = true;
        });
      }
    } catch (_) {}
  }

  /// The API reports the newest community post and the newest consultation
  /// independently, so whichever of the two is more recent is the member's
  /// actual latest activity. If only one carries a parseable timestamp that one
  /// wins; with neither dated, the post is preferred as the likelier recent act.
  _Activity? _latestOf(dynamic post, dynamic history) {
    _Activity? fromPost;
    if (post != null) {
      final content = (post['content'] ?? '').toString().trim();
      if (content.isNotEmpty) {
        fromPost = _Activity(
          icon: Icons.forum_rounded,
          label: 'Your latest post',
          summary: content,
          at: DateTime.tryParse(post['created_at']?.toString() ?? ''),
        );
      }
    }

    _Activity? fromHistory;
    if (history != null) {
      final patient = (history['patient'] ?? '').toString().trim();
      if (patient.isNotEmpty) {
        fromHistory = _Activity(
          icon: Icons.medical_services_rounded,
          label: 'Recent consultation',
          summary: patient,
          at: DateTime.tryParse(history['created_at']?.toString() ?? ''),
        );
      }
    }

    if (fromPost == null) return fromHistory;
    if (fromHistory == null) return fromPost;
    if (fromPost.at == null) return fromHistory;
    if (fromHistory.at == null) return fromPost;
    return fromHistory.at!.isAfter(fromPost.at!) ? fromHistory : fromPost;
  }

  /// Short relative time — 'just now', '5m ago', '3h ago', '2d ago'. Anything
  /// older than a week reads better as a plain date than as '43d ago'.
  String _relativeTime(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.isNegative || diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
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

  Widget _buildActivity(ThemeColors tc, _Activity activity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(color: tc.primarySurface, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(activity.icon, size: 18, color: tc.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(activity.label, style: AppTypography.labelMedium.copyWith(color: tc.neutral70))),
                if (activity.at != null)
                  Text(_relativeTime(activity.at!), style: AppTypography.caption.copyWith(color: tc.textSecondary)),
              ]),
              const SizedBox(height: 2),
              Text(activity.summary,
                  style: AppTypography.bodyMedium.copyWith(color: tc.neutral100),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final fullName = widget.userData['full_name'] ?? 'Member';
    final rank = widget.userData['rank'] ?? 'Member';
    final userId = widget.userData['contact'].toString();
    // Named once: it gates the card and the space the card occupies.
    final showActivity = _activityLoaded &&
        (_unreadNotifs > 0 || _pendingRequests > 0 || _activity != null);

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
              Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(AppSpacing.xs), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 16, minHeight: 16), child: Text('$_unreadNotifs', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
          ]),
          IconButton(icon: const Icon(Icons.logout_rounded, size: 22), tooltip: 'Log out', onPressed: () => _logout(context)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            // Compact header. It previously ran ~149dp for a greeting, a name and
            // a rank chip: the chip sat on its own row below the avatar, and the
            // block carried 32dp of bottom padding. Folding the chip alongside
            // the name costs no extra height and brings this to ~96dp, which is
            // what lets all five tiles clear the fold once the activity card is
            // present.
            padding: const EdgeInsets.all(AppSpacing.xxl),
            // The top corners are rounded in dark mode only. There the app bar
            // is dark, so the green block is a shape in its own right and a
            // square top reads as a seam against the bar. In light mode the app
            // bar is the same green and the two are meant to read as one piece —
            // rounding the top there would cut scaffold-coloured notches between
            // them.
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(tc.isDark ? AppRadius.xxl : 0),
                bottom: const Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.md)), alignment: Alignment.center,
                child: Text(_initials(fullName), style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(_greeting, style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 2),
                Row(children: [
                  Flexible(child: Text(fullName, style: AppTypography.titleLarge.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: AppSpacing.sm),
                  Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: Text(rank.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: Colors.white, letterSpacing: 1))),
                ]),
              ])),
            ]),
          ),
          // The leading gap belongs to the card, not to the header: left
          // outside the condition it stacked with the trailing one and held a
          // 40dp hole open for any member with nothing to show.
          if (showActivity) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_unreadNotifs > 0 || _pendingRequests > 0)
                    Row(children: [
                      if (_pendingRequests > 0) _MiniStat(icon: Icons.pending_actions_rounded, count: _pendingRequests, label: 'Pending', color: tc.warningText, tc: tc),
                      if (_unreadNotifs > 0) _MiniStat(icon: Icons.notifications_rounded, count: _unreadNotifs, label: 'Alerts', color: tc.errorText, tc: tc),
                    ]),
                  // Rule only earns its place when there is something on both sides of it.
                  if ((_unreadNotifs > 0 || _pendingRequests > 0) && _activity != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1, thickness: 1, color: tc.neutral30),
                    ),
                  if (_activity != null) _buildActivity(tc, _activity!),
                ])),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          const AppSectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
              // 1.2 is the only ratio that works on a 360dp phone: the tile
              // content needs ~130dp of height, and five tiles in two columns
              // must still clear the fold. At the previous 1.0 the grid ran
              // 46dp past the screen and Profile was never visible.
              // Four destinations in the grid, Profile spanning the row beneath.
              // Five tiles left an orphan on the last row at both 2 and 4
              // columns; giving Profile the full width squares the grid and
              // separates the account from the four things members come here to
              // do. It is also shorter than a grid row, so the fold gains ~52dp.
              return Column(children: [
                GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: crossAxisCount, crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md, childAspectRatio: 1.2, children: [
                  AppFeatureTile(title: 'History', subtitle: 'Past consultations', icon: Icons.history_rounded, color: AppColors.featureCertificate, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(userId: userId)))),
                  AppFeatureTile(title: 'Perks', subtitle: 'Benefits & discounts', icon: Icons.card_giftcard_rounded, color: tc.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerksScreen()))),
                  AppFeatureTile(title: 'News', subtitle: 'Latest updates', icon: Icons.newspaper_rounded, color: AppColors.featureNews, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen()))),
                  AppFeatureTile(title: 'Community', subtitle: 'Member posts', icon: Icons.people_rounded, color: AppColors.featureCommunity, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityFeedScreen()))),
                ]),
                const SizedBox(height: AppSpacing.md),
                AppFeatureTile.row(title: 'Profile', subtitle: 'Account & settings', icon: Icons.person_rounded, color: AppColors.featurePharmacy, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userData: widget.userData)))),
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

/// One row of the dashboard's activity card: the member's most recent post or
/// consultation, already reduced to what the card needs to draw.
class _Activity {
  final IconData icon;
  final String label;
  final String summary;
  final DateTime? at;

  const _Activity({required this.icon, required this.label, required this.summary, this.at});
}

class _MiniStat extends StatelessWidget {
  final IconData icon; final int count; final String label; final Color color; final ThemeColors tc;
  const _MiniStat({required this.icon, required this.count, required this.label, required this.color, required this.tc});
  @override
  Widget build(BuildContext context) => Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text('$count $label', style: AppTypography.labelSmall.copyWith(color: tc.neutral90))]));
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
    Text(label, style: AppTypography.caption.copyWith(color: tc.textSecondary)),
  ]));
}