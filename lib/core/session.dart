import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The signed-in member, and the token that proves it.
///
/// The member record was already kept under `user_session`; what is new is the
/// token. Until it existed, every request simply asserted a member_id and the
/// server believed it, so the app's "session" was a label rather than a claim
/// anyone checked.
class Session {
  Session._();

  static const _userKey = 'user_session';
  static const _tokenKey = 'auth_token';

  static Future<void> save({
    required Map<String, dynamic> user,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> user() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  /// The member's own id, or '' when signed out. Kept for the screens that
  /// still display it — it is no longer sent to the server as identity.
  static Future<String> memberId() async =>
      (await user())?['id']?.toString() ?? '';

  static Future<void> updateUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  /// A stored member with no token is a session from a build that predates
  /// authentication: it looks signed in but every request will 401, so it is
  /// treated as signed out.
  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey) != null &&
        (prefs.getString(_tokenKey) ?? '').isNotEmpty;
  }
}
