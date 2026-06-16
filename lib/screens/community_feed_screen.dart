import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/community_post.dart';
import '../services/community_service.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../core/config.dart';
import '../widgets/app_empty_state.dart';
import 'community_create_post_screen.dart';
import 'community_post_detail_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final List<CommunityPost> _posts = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user_session');
    if (json != null) {
      final user = jsonDecode(json);
      _currentUserId = user['id'].toString();
    }
    _loadFeed();
  }

  Future<void> _loadFeed({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _posts.clear();
      });
    }

    if (!_hasMore && !refresh) return;
    setState(() => _isLoading = true);

    try {
      final result = await CommunityService.getFeed(
        page: _page,
        userId: _currentUserId,
      );

      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'] ?? [];
        final newPosts = data.map((e) => CommunityPost.fromJson(e)).toList();

        setState(() {
          _posts.addAll(newPosts);
          _hasMore = result['has_more'] ?? false;
          _page++;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not load feed'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadFeed();
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    setState(() {
      _posts[index] = post.copyWith(
        likeCount: post.likedByMe ? post.likeCount - 1 : post.likeCount + 1,
        likedByMe: !post.likedByMe,
      );
    });

    try {
      await CommunityService.toggleLike(
        postId: post.id,
        userId: _currentUserId,
      );
    } catch (_) {
      setState(() {
        _posts[index] = post;
      });
    }
  }

  void _openFullImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullImageScreen(
          imageUrl: '${AppConfig.baseUrl}/$imagePath',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => _loadFeed(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildComposer(tc),
          const Divider(height: 1),
          Expanded(
            child: _isLoading && _posts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => _loadFeed(refresh: true),
                        child: ListView(children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const AppEmptyState(
                                icon: Icons.forum_rounded,
                                title: 'No Posts Yet',
                                subtitle:
                                    'Be the first to share something with the community!',
                              )),
                        ]),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadFeed(refresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                              top: AppSpacing.md, bottom: AppSpacing.xxxl),
                          itemCount: _posts.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _posts.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _buildPostCard(index, tc);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(ThemeColors tc) {
    return Container(
      color: tc.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: InkWell(
        onTap: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => CommunityCreatePostScreen(
                      userId: _currentUserId,
                    )),
          );
          if (created == true) _loadFeed(refresh: true);
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tc.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(Icons.person, color: tc.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: tc.neutral10,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text("What's on your mind?",
                    style: AppTypography.bodyMedium
                        .copyWith(color: tc.neutral60)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.image_outlined, color: tc.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(int index, ThemeColors tc) {
    final post = _posts[index];

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppElevation.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
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
                        (post.user.fullName.isNotEmpty
                                ? post.user.fullName[0]
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
                        Text(post.user.fullName,
                            style: AppTypography.titleMedium
                                .copyWith(color: tc.neutral100)),
                        Text(_formatDate(post.createdAt),
                            style: AppTypography.caption
                                .copyWith(color: tc.neutral60)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz,
                        color: tc.neutral50, size: 20),
                    onPressed: () => _showPostMenu(post, tc),
                  ),
                ],
              ),
            ),
            if (post.content.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(post.content,
                    style: AppTypography.bodyMedium
                        .copyWith(color: tc.neutral90)),
              ),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildImageCollage(post, tc),
            ],
            if (post.likeCount > 0 || post.commentCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                if (post.likeCount > 0) ...[
                  GestureDetector(
                    onTap: () => _showLikesList(post),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up,
                            size: 16, color: tc.primary),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}',
                            style: AppTypography.caption
                                .copyWith(color: tc.primary,
                                    fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
                    const Spacer(),
                    if (post.commentCount > 0)
                      InkWell(
                        onTap: () => _openPostDetail(post),
                        child: Text('${post.commentCount} comments',
                            style: AppTypography.caption
                                .copyWith(color: tc.neutral60)),
                      ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _toggleLike(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            post.likedByMe
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 20,
                            color: post.likedByMe
                                ? tc.primary
                                : tc.neutral60,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Like',
                            style: AppTypography.labelMedium.copyWith(
                                color: post.likedByMe
                                    ? tc.primary
                                    : tc.neutral60),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _openPostDetail(post),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.comment_outlined,
                              size: 20, color: tc.neutral60),
                          const SizedBox(width: 6),
                          Text('Comment',
                              style: AppTypography.labelMedium.copyWith(
                                  color: tc.neutral60)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCollage(CommunityPost post, ThemeColors tc) {
    final count = post.images.length;
    final baseUrl = AppConfig.baseUrl;

    Widget imageBox(String path, {double? width, double? height}) {
      return GestureDetector(
        onTap: () => _openFullImage(path),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: SizedBox(
            width: width,
            height: height ?? 200,
            child: Image.network(
              '$baseUrl/$path',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: tc.neutral20,
                child: Icon(Icons.broken_image,
                    color: tc.neutral50),
              ),
            ),
          ),
        ),
      );
    }

    if (count == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: imageBox(post.images[0], height: 260),
      );
    }

    if (count == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(child: imageBox(post.images[0])),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: imageBox(post.images[1])),
            ],
          ),
        ),
      );
    }

    if (count == 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: imageBox(post.images[0]),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: imageBox(post.images[1])),
                    const SizedBox(height: AppSpacing.xs),
                    Expanded(child: imageBox(post.images[2])),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4+ images — 2x2 grid
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: imageBox(post.images[0])),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: imageBox(post.images[1])),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: imageBox(post.images[2])),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: post.images.length > 3
                        ? imageBox(post.images[3])
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPostDetail(CommunityPost post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(
          post: post,
          currentUserId: _currentUserId,
        ),
      ),
    );
    _loadFeed(refresh: true);
  }

  void _showPostMenu(CommunityPost post, ThemeColors tc) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            if (post.userId.toString() == _currentUserId)
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: tc.error),
                title: const Text('Delete Post'),
                onTap: () {
                  Navigator.pop(ctx);
                  _deletePost(post);
                },
              ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(ctx);
                _showReportSheet(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLikesList(CommunityPost post) async {
    try {
      final result = await CommunityService.getLikes(post.id);
      if (result['status'] != 'success') return;

      final List<dynamic> likes = result['data'] ?? [];
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          final tc = ThemeColors.of(ctx);
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Liked by ${likes.length}',
                    style: AppTypography.titleMedium
                        .copyWith(color: tc.neutral100),
                  ),
                ),
                if (likes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No likes yet.'),
                  )
                else ...[
                  ...likes.map((like) {
                    final user = like['user'] as Map<String, dynamic>;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tc.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (user['full_name']?.isNotEmpty == true
                                    ? user['full_name'][0]
                                    : '?')
                                .toUpperCase(),
                            style: AppTypography.labelMedium
                                .copyWith(color: tc.primary),
                          ),
                        ),
                      ),
                      title: Text(
                        user['full_name'] ?? user['contact'] ?? 'Unknown',
                        style: AppTypography.bodyMedium.copyWith(
                            color: tc.neutral100),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      );
    } catch (_) {}
  }

  void _showReportSheet(CommunityPost post) {
    final reasons = [
      'Spam',
      'Harassment',
      'Inappropriate content',
      'False information',
      'Violence',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final tc = ThemeColors.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text('Why are you reporting this post?',
                    style: AppTypography.titleMedium
                        .copyWith(color: tc.neutral100)),
              ),
              ...reasons.map((reason) => ListTile(
                    leading: Icon(Icons.flag_outlined,
                        color: tc.neutral60),
                    title: Text(reason),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        final result = await CommunityService.reportPost(
                          postId: post.id,
                          userId: _currentUserId,
                          reason: reason,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ??
                                  'Report submitted — thank you.'),
                              backgroundColor: result['status'] == 'success'
                                  ? AppColors.success
                                  : AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to submit report.'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  )),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deletePost(CommunityPost post) async {
    try {
      await CommunityService.deletePost(
          postId: post.id, userId: _currentUserId);
      _loadFeed(refresh: true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not delete post'),
              backgroundColor: AppColors.error),
        );
      }
    }
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

class _FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const _FullImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}