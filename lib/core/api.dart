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

  /// The client every request goes through.
  ///
  /// Production never assigns this. It exists so a test can hand the app a
  /// scripted server and drive a screen that only exists on the far side of a
  /// network call — the sign-in OTP step was unreachable for exactly that
  /// reason, and an 8px overflow lived there, on a screen every member passes
  /// through, until someone happened to look at a handset.
  ///
  /// Tests must restore it; [resetClient] is the way, and `addTearDown` the
  /// place, since a leaked fake would silently mute every later test.
  static http.Client client = http.Client();

  /// Puts [client] back to one that really talks to the network.
  static void resetClient() => client = http.Client();

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

    return _send(() async => client
        .get(uri, headers: await _headers())
        .timeout(AppConfig.apiTimeout));
  }

  /// A GET whose body is a bare JSON array rather than the usual
  /// `{status, data}` envelope.
  ///
  /// `get_news.php` predates that convention and returns the rows directly, so
  /// [get] cannot read it — the cast to a map is what fails. This is a
  /// concession to one older endpoint, not a second way of doing things: a new
  /// endpoint should use the envelope and [get].
  static Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/$path')
        .replace(queryParameters: query);

    final body = await _decode(() async => client
        .get(uri, headers: await _headers())
        .timeout(AppConfig.apiTimeout));

    if (body is List) return body;
    throw const ApiException('The server sent something unreadable.');
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/$path');

    return _send(() async => client
        .post(uri, headers: await _headers(), body: body)
        .timeout(AppConfig.apiTimeout));
  }

  /// Sign-in calls, which cannot carry a token because they are how one is got.
  static Future<Map<String, dynamic>> postPublic(
    String path, {
    Map<String, String>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/$path');

    return _send(
        () async => client.post(uri, body: body).timeout(AppConfig.apiTimeout));
  }

  static Future<String?> uploadImage(String path, String filePath) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}/$path'))
            ..headers.addAll(await _headers())
            ..files.add(await http.MultipartFile.fromPath('image', filePath));

      final res = await http.Response.fromStream(
          await client.send(request).timeout(AppConfig.apiTimeout));

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
    final body = await _decode(request);

    if (body is Map<String, dynamic>) return body;
    throw const ApiException('The server sent something unreadable.');
  }

  /// Everything the transport owes a caller — reachability, the 401 sign-out,
  /// and readable JSON — with no opinion about the shape that comes back. Both
  /// [_send] and [getList] then check for the shape they need.
  static Future<dynamic> _decode(
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
      return jsonDecode(res.body);
    } catch (_) {
      throw const ApiException('The server sent something unreadable.');
    }
  }

  static Future<void> _signOut() async {
    await Session.clear();
    onUnauthenticated?.call();
  }
}
