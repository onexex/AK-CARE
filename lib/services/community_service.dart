import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/community_post.dart';

class CommunityService {
  static const String _communityPath = 'community';

  static String _base(String endpoint) =>
      '${AppConfig.baseUrl}/$_communityPath/$endpoint';

  // ── Feed ──
  static Future<Map<String, dynamic>> getFeed({
    required int page,
    required String userId,
  }) async {
    final uri = Uri.parse(_base('get_feed.php'))
        .replace(queryParameters: {'page': page.toString(), 'user_id': userId});
    final res = await http.get(uri).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Post ──
  static Future<Map<String, dynamic>> createPost({
    required String userId,
    required String content,
    List<String> images = const [],
  }) async {
    final res = await http.post(
      Uri.parse(_base('create_post.php')),
      body: {
        'user_id': userId,
        'content': content,
        'images': json.encode(images),
      },
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> deletePost({
    required int postId,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse(_base('delete_post.php')),
      body: {'post_id': postId.toString(), 'user_id': userId},
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Like ──
  static Future<Map<String, dynamic>> toggleLike({
    required int postId,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse(_base('like_post.php')),
      body: {'post_id': postId.toString(), 'user_id': userId},
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Comments ──
  static Future<Map<String, dynamic>> getComments(int postId) async {
    final res = await http.get(
      Uri.parse(_base('comments.php')).replace(queryParameters: {
        'post_id': postId.toString(),
      }),
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> addComment({
    required int postId,
    required String userId,
    required String comment,
  }) async {
    final res = await http.post(
      Uri.parse(_base('comments.php')),
      body: {
        'post_id': postId.toString(),
        'user_id': userId,
        'comment': comment,
      },
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> deleteComment({
    required int commentId,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse(_base('comments.php')),
      body: {'id': commentId.toString(), 'user_id': userId},
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Replies ──
  static Future<Map<String, dynamic>> addReply({
    required int commentId,
    required String userId,
    required String reply,
  }) async {
    final res = await http.post(
      Uri.parse(_base('replies.php')),
      body: {
        'comment_id': commentId.toString(),
        'user_id': userId,
        'reply': reply,
      },
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Notifications ──
  static Future<Map<String, dynamic>> getNotifications(String userId) async {
    final res = await http.get(
      Uri.parse(_base('notifications.php'))
          .replace(queryParameters: {'user_id': userId}),
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Likes ──
  static Future<Map<String, dynamic>> getLikes(int postId) async {
    final res = await http.get(
      Uri.parse(_base('get_likes.php'))
          .replace(queryParameters: {'post_id': postId.toString()}),
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Reports ──
  static Future<Map<String, dynamic>> reportPost({
    required int postId,
    required String userId,
    required String reason,
  }) async {
    final res = await http.post(
      Uri.parse(_base('report_post.php')),
      body: {
        'post_id': postId.toString(),
        'user_id': userId,
        'reason': reason,
      },
    ).timeout(AppConfig.apiTimeout);
    return json.decode(res.body);
  }

  // ── Image Upload ──
  static Future<String?> uploadImage(String filePath) async {
    try {
      final uri = Uri.parse(_base('upload_image.php'));
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      final streamed = await request.send().timeout(AppConfig.apiTimeout);
      final res = await http.Response.fromStream(streamed);
      final data = json.decode(res.body);
      if (data['status'] == 'success') return data['path'];
    } catch (_) {}
    return null;
  }
}