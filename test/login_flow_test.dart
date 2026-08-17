// The sign-in flow, driven through a scripted server.
//
// The OTP step is the reason Api.client exists. It only appears after
// check_user.php has answered, so before the seam no test could render it —
// and a box on it overflowed its card by 8px, on the one screen every member
// must pass through, until someone looked at a handset. This drives the real
// screen to that state and holds it there.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akop_member_app/core/api.dart';
import 'package:akop_member_app/main.dart';
import 'package:akop_member_app/screens/login_screen.dart';

/// A server that says yes to the number lookup, so the flow advances to the
/// code entry. Anything else 404s loudly rather than quietly returning success
/// for a call the test did not mean to make.
http.Client _serverThatSendsAnOtp() => MockClient((request) async {
      if (request.url.path.endsWith('check_user.php')) {
        return http.Response(
          jsonEncode({'status': 'success', 'message': 'OTP sent'}),
          200,
        );
      }
      return http.Response(jsonEncode({'status': 'error'}), 404);
    });

/// Puts the app on the code-entry step: open signed out, type a number, ask for
/// a code. Pumped in fixed steps rather than settled — the success SnackBar
/// holds a timer that pumpAndSettle would wait out.
Future<void> _advanceToOtpStep(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});

  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  expect(find.byType(LoginScreen), findsOneWidget,
      reason: 'the flow starts signed out');

  await tester.enterText(find.byType(TextField).first, '09171234567');
  await tester.tap(find.text('GET VERIFICATION CODE'));

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Lets the SnackBar's timer expire so it does not outlive the test.
Future<void> _drainSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUp(() => Api.client = _serverThatSendsAnOtp());

  // A leaked fake would silently mute every test that ran after it.
  tearDown(Api.resetClient);

  testWidgets('asking for a code brings up the four-digit entry',
      (tester) async {
    await _advanceToOtpStep(tester);

    expect(find.text('Verify Your Identity'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4),
        reason: 'one field per digit');

    await _drainSnackBar(tester);
  });

  testWidgets('the four boxes fit the card on a 360dp phone', (tester) async {
    // The regression this seam was built to catch. 360dp is the width the
    // handset reported: the card offers 264dp inside its padding, and four
    // boxes that each claimed a fixed 60 plus 8 of margin wanted 272 — the
    // 8.0px the device drew as overflow stripes.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _advanceToOtpStep(tester);

    expect(find.text('Verify Your Identity'), findsOneWidget);
    expect(tester.takeException(), isNull,
        reason: 'no box may overflow the card it sits in');

    await _drainSnackBar(tester);
  });

  testWidgets('the entry still fits when the member scales text up',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _advanceToOtpStep(tester);

    expect(find.text('Verify Your Identity'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _drainSnackBar(tester);
  });

  testWidgets('a server that cannot be reached is said so, not swallowed',
      (tester) async {
    Api.client = MockClient((_) async => throw const SocketExceptionStub());

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '09171234567');
    await tester.tap(find.text('GET VERIFICATION CODE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Still on the number step, with a reason on screen rather than a dead
    // button and no explanation.
    expect(find.text('Verify Your Identity'), findsNothing);
    expect(
        find.textContaining('Unable to connect', findRichText: true),
        findsOneWidget);
  });
}

/// Stands in for a dropped connection without dragging dart:io in.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
