// Which screen the app opens on.
//
// That is the whole of MyApp's logic, and it is not a cosmetic decision: the
// rule that a stored member without a token counts as signed out is what keeps
// a session from a build that predates authentication out of the dashboard,
// where every request it made would come back 401.
//
// (This file used to hold the generated counter test, which exercised a demo
// app this project never had and failed on every run.)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akop_member_app/main.dart';
import 'package:akop_member_app/screens/home_dashboard.dart';
import 'package:akop_member_app/screens/login_screen.dart';

/// Fails every HTTP call at once.
///
/// The dashboard asks for the member's latest activity the moment it is built,
/// and `AppConfig.baseUrl` points at a developer's own XAMPP. Without this the
/// suite would either reach that machine or sit out a ten-second timeout, and
/// pass or fail on whether Apache happened to be running. The dashboard already
/// swallows the failure — an offline member sees the screen without the
/// activity line — so refusing the call exercises a path the app supports.
class _OfflineHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('network disabled in tests');
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

/// A member row shaped like the one `verify_otp.php` stores.
const _member = {'id': 'AKM-787', 'name': 'Test Member'};

/// Seeds the prefs Session reads, then settles the app past its splash.
Future<void> _openApp(
  WidgetTester tester, {
  Map<String, dynamic>? user,
  String? token,
}) async {
  SharedPreferences.setMockInitialValues({
    if (user != null) 'user_session': jsonEncode(user),
    if (token != null) 'auth_token': token,
  });

  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => HttpOverrides.global = _OfflineHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  group('the screen the app opens on', () {
    testWidgets('sign-in, when there is no session at all', (tester) async {
      await _openApp(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeDashboard), findsNothing);
    });

    testWidgets('the dashboard, for a member holding a token', (tester) async {
      await _openApp(tester, user: _member, token: 'a-real-token');

      expect(find.byType(HomeDashboard), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('sign-in, for a stored member with no token — the session '
        'predates authentication and would 401 on every request',
        (tester) async {
      await _openApp(tester, user: _member);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeDashboard), findsNothing);
    });

    testWidgets('sign-in, when the token was stored blank', (tester) async {
      await _openApp(tester, user: _member, token: '');

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeDashboard), findsNothing);
    });

    testWidgets('sign-in, when a token is held but the member record is gone',
        (tester) async {
      await _openApp(tester, token: 'a-real-token');

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeDashboard), findsNothing);
    });
  });

  testWidgets('the sign-in screen lays out on the narrowest phone in use',
      (tester) async {
    // 'GET VERIFICATION CODE' and its icon want 333px; the sign-in card caps
    // that row at 312 whatever the screen, so this button overflowed on every
    // device until AppButton was made to scale a long label down. Nothing had
    // ever rendered it in a test, so nothing said so.
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _openApp(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a dashboard that cannot reach the server still renders',
      (tester) async {
    // The offline client above makes every request fail; the member is still
    // shown their dashboard rather than an error screen or a blank frame.
    await _openApp(tester, user: _member, token: 'a-real-token');

    expect(find.byType(HomeDashboard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
