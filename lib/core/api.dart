import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'session.dart';

/// Anything that stopped a request from producing a usable answer.
///
/// [unauthenticated] is the one callers usually care about: the token is gone,
/// expired or revoked, and the member has to sign in again. Everything else is
/// an ordinary failure worth showing as itself.
class ApiException implements Exception {
  final String message;
  final bool unauthenticated;

  const ApiException(this.message, {this.unauthenticated = false});

  @override
  String toString() => message;
}

/// Every call to the member API goes through here.
///
/// The point is the Authorization header: endpoints no longer accept a user_id,
/// they resolve the caller from the token. Sending it from one place means a new
/// screen cannot forget to, which is exactly how the old `user_id` parameter
/// ended up on sixteen endpoints with sixteen slightly different checks.
class Api {
  Api._();

  /// Called when the server rejects the token, so the app can return to the
  /// sign-in screen from wherever it happens to be. Set once, in main().
  static void Function()? onUnauthenticated;

  static Future<Map<String, String>> _headers() async {
    final token = await Session.token();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      // Apache does not always pass Authorization through to PHP; the server
      // accepts either envelope and this one is never stripped.
      if (token != null && token.isNotEmpty) 'X-Member-Token': token,
    };
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/$path')
        .replace(queryParameters: query);

    return _send(() async =>
        http.get(uri, headers: await _headers()).timeout(AppConfig.apiTimeout));
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/$path');

    return _send(() async => http
        .post(uri, headers: await _headers(), body: body)
        .timeout(AppConfig.apiTimeout));
  }

  /// Sign-in calls, which cannot carry a token because they are how one is got.
  static Future<Map<String, dynamic>> postPublic(
    String path, {
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/$path');

    return _send(() async =>
        http.post(uri, body: body).timeout(AppConfig.apiTimeout));
  }

  static Future<String?> uploadImage(String path, String filePath) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}/$path'))
            ..headers.addAll(await _headers())
            ..files.add(await http.MultipartFile.fromPath('image', filePath));

      final res = await http.Response.fromStream(
          await request.send().timeout(AppConfig.apiTimeout));

      if (res.statusCode == 401) {
        await _signOut();
        return null;
      }

      final data = jsonDecode(res.body);
      if (data['status'] == 'success') return data['path'];
    } catch (_) {}

    return null;
  }

  static Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() request) async {
    final http.Response res;

    try {
      res = await request();
    } catch (_) {
      throw const ApiException(
          'Could not reach the server. Check your connection and try again.');
    }

    if (res.statusCode == 401) {
      await _signOut();
      throw const ApiException('Please sign in again.', unauthenticated: true);
    }

    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('The server sent something unreadable.');
    }
  }

  static Future<void> _signOut() async {
    await Session.clear();
    onUnauthenticated?.call();
  }
}
