import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPost post;
  final String currentUserId;

  const CommunityPostDetailScreen({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final List<CommunityComment> _comments = [];
  final _commentController = TextEditingController();
  final _replyController = TextEditingController();
  bool _isLoadingComments = true;
  int? _replyingToCommentId;
  late CommunityPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final result = await CommunityService.getComments(_post.id);
      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'] ?? [];
        setState(() {
          _comments.clear();
          _comments.addAll(
              data.map((e) => CommunityComment.fromJson(e)).toList());
          _isLoadingComments = false;
        });
      } else {
        setState(() => _isLoadingComments = false);
      }
    } catch (_) {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      await CommunityService.addComment(
        postId: _post.id,
        userId: widget.currentUserId,
        comment: text,
      );
      _loadComments();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add comment'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _addReply(int commentId) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    _replyController.clear();
    FocusScope.of(context).unfocus();

    try {
      await CommunityService.addReply(
        commentId: commentId,
        userId: widget.currentUserId,
        reply: text,
      );
      setState(() => _replyingToCommentId = null);
      _loadComments();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add reply'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await CommunityService.deleteComment(
          commentId: commentId, userId: widget.currentUserId);
      _loadComments();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              children: [
                // Post card
                _buildPostHeader(tc),
                const Divider(height: 1),
                // Comments header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Comments (${_comments.length})',
                    style: AppTypography.titleMedium
                        .copyWith(color: tc.neutral90),
                  ),
                ),
                if (_isLoadingComments)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ))
                else if (_comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                        child: Text('No comments yet.',
                            style: TextStyle(color: tc.neutral60))),
                  )
                else
                  ..._comments.map((c) => _buildCommentTile(c, tc)),
              ],
            ),
          ),
          // Comment input
          Container(
            color: tc.surface,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: tc.neutral60),
                      filled: true,
                      fillColor: tc.neutral10,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                    ),
                    style: AppTypography.bodyMedium
                        .copyWith(color: tc.neutral100),
                    cursorColor: tc.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _addComment,
                  icon: Icon(Icons.send_rounded,
                      color: tc.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(ThemeColors tc) {
    return Container(
      color: tc.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tc.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (_post.user.fullName.isNotEmpty
                            ? _post.user.fullName[0]
                            : '?')
                        .toUpperCase(),
                    style: AppTypography.labelLarge
                        .copyWith(color: tc.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_post.user.fullName,
                        style: AppTypography.titleMedium
                            .copyWith(color: tc.neutral100)),
                    Text(_formatDate(_post.createdAt),
                        style: AppTypography.caption
                            .copyWith(color: tc.neutral60)),
                  ],
                ),
              ),
            ],
          ),
          if (_post.content.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_post.content,
                style: AppTypography.bodyMedium
                    .copyWith(color: tc.neutral90)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommunityComment comment, ThemeColors tc) {
    return Container(
      color: tc.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tc.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (comment.user.fullName.isNotEmpty
                            ? comment.user.fullName[0]
                            : '?')
                        .toUpperCase(),
                    style: AppTypography.labelSmall
                        .copyWith(color: tc.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: tc.neutral10,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.user.fullName,
                          style: AppTypography.labelMedium
                              .copyWith(color: tc.neutral100)),
                      const SizedBox(height: 2),
                      Text(comment.comment,
                          style: AppTypography.bodySmall
                              .copyWith(color: tc.neutral80)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => setState(
                      () => _replyingToCommentId = comment.id),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Reply',
                      style: AppTypography.caption
                          .copyWith(color: tc.neutral60)),
                ),
                if (comment.userId.toString() == widget.currentUserId) ...[
                  const SizedBox(width: AppSpacing.md),
                  TextButton(
                    onPressed: () => _deleteComment(comment.id),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text('Delete',
                        style: AppTypography.caption
                            .copyWith(color: tc.error)),
                  ),
                ],
              ],
            ),
          ),
          // Replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: AppSpacing.xs),
              child: Column(
                children: comment.replies
                    .map((r) => _buildReplyTile(r, tc))
                    .toList(),
              ),
            ),
          // Reply input
          if (_replyingToCommentId == comment.id)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        hintStyle: AppTypography.bodySmall.copyWith(color: tc.neutral60),
                        filled: true,
                        fillColor: tc.neutral10,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            borderSide: BorderSide.none),
                      ),
                      style: AppTypography.bodySmall
                          .copyWith(color: tc.neutral100),
                      cursorColor: tc.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () => _addReply(comment.id),
                    icon: Icon(Icons.send_rounded,
                        size: 20, color: tc.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyTile(CommunityReply reply, ThemeColors tc) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: tc.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (reply.user.fullName.isNotEmpty
                        ? reply.user.fullName[0]
                        : '?')
                    .toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                    color: tc.primary, fontSize: 8),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: tc.neutral10,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodySmall
                      .copyWith(color: tc.neutral80),
                  children: [
                    TextSpan(
                      text: '${reply.user.fullName} ',
                      style: AppTypography.labelSmall
                          .copyWith(color: tc.neutral100),
                    ),
                    TextSpan(text: reply.reply),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}