import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/community_service.dart';
import '../models/community_post.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../widgets/app_empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<CommunityNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('user_session');
      if (json != null) {
        final user = jsonDecode(json);
        final userId = user['id'].toString();
        final result = await CommunityService.getNotifications(userId);
        if (result['status'] == 'success') {
          setState(() {
            _notifications = (result['data'] as List)
                .map((e) => CommunityNotification.fromJson(e))
                .toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'like' => Icons.thumb_up_rounded,
      'comment' => Icons.comment_rounded,
      'reply' => Icons.reply_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  Color _colorForType(String type) {
    return switch (type) {
      'like' => AppColors.primary,
      'comment' => const Color(0xFF2196F3),
      'reply' => const Color(0xFFFF9800),
      _ => AppColors.neutral60,
    };
  }

  String _textForType(String type) {
    return switch (type) {
      'like' => 'liked your post',
      'comment' => 'commented on your post',
      'reply' => 'replied to your comment',
      _ => 'interacted with your post',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? ListView(children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const AppEmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: 'No Notifications',
                        subtitle:
                            'You\'ll see notifications here when someone likes or comments on your posts.',
                      )),
                ])
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: n.isRead
                              ? AppColors.surface
                              : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _colorForType(n.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_iconForType(n.type),
                                  color: _colorForType(n.type), size: 22),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.neutral100),
                                      children: [
                                        TextSpan(
                                          text: n.fromUser.fullName,
                                          style: AppTypography.labelLarge
                                              .copyWith(
                                                  color: AppColors.neutral100),
                                        ),
                                        TextSpan(
                                            text: ' ${_textForType(n.type)}'),
                                      ],
                                    ),
                                  ),
                                  if (n.postPreview.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(n.postPreview,
                                        style: AppTypography.caption.copyWith(
                                            color: AppColors.neutral60),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}