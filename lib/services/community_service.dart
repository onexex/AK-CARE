import 'dart:convert';

import '../core/api.dart';

/// Community endpoints.
///
/// Every method used to take a `userId` and send it as the caller's identity.
/// The server no longer accepts one — it resolves the member from the session
/// token — so those parameters are gone rather than merely ignored: a parameter
/// that looks like it decides who you are, but doesn't, is worse than none.
class CommunityService {
  static const String _communityPath = 'community';

  static String _path(String endpoint) => '$_communityPath/$endpoint';

  // ── Feed ──
  static Future<Map<String, dynamic>> getFeed({required int page}) =>
      Api.get(_path('get_feed.php'), query: {'page': page.toString()});

  // ── Post ──
  static Future<Map<String, dynamic>> createPost({
    required String content,
    List<String> images = const [],
  }) =>
      Api.post(_path('create_post.php'), body: {
        'content': content,
        'images': json.encode(images),
      });

  static Future<Map<String, dynamic>> deletePost({required int postId}) =>
      Api.post(_path('delete_post.php'),
          body: {'post_id': postId.toString()});

  // ── Like ──
  static Future<Map<String, dynamic>> toggleLike({required int postId}) =>
      Api.post(_path('like_post.php'), body: {'post_id': postId.toString()});

  // ── Comments ──
  static Future<Map<String, dynamic>> getComments(int postId) =>
      Api.get(_path('comments.php'), query: {'post_id': postId.toString()});

  static Future<Map<String, dynamic>> addComment({
    required int postId,
    required String comment,
  }) =>
      Api.post(_path('comments.php'), body: {
        'post_id': postId.toString(),
        'comment': comment,
      });

  static Future<Map<String, dynamic>> deleteComment({required int commentId}) =>
      Api.post(_path('comments.php'), body: {'id': commentId.toString()});

  // ── Replies ──
  static Future<Map<String, dynamic>> addReply({
    required int commentId,
    required String reply,
  }) =>
      Api.post(_path('replies.php'), body: {
        'comment_id': commentId.toString(),
        'reply': reply,
      });

  // ── Notifications ──
  static Future<Map<String, dynamic>> getNotifications() =>
      Api.get(_path('notifications.php'));

  // ── Likes ──
  static Future<Map<String, dynamic>> getLikes(int postId) =>
      Api.get(_path('get_likes.php'), query: {'post_id': postId.toString()});

  // ── Reports ──
  static Future<Map<String, dynamic>> reportPost({
    required int postId,
    required String reason,
  }) =>
      Api.post(_path('report_post.php'), body: {
        'post_id': postId.toString(),
        'reason': reason,
      });

  // ── Image Upload ──
  static Future<String?> uploadImage(String filePath) =>
      Api.uploadImage(_path('upload_image.php'), filePath);
}
