// The member QR code.
//
// The client's requirement is narrow and easy to drift from: the scanned
// payload must be the member id itself. A partner scanner looks the id up
// directly, so a URL, a JSON envelope or a prefix would each have to be
// stripped back off at the counter — and nothing in the app would notice the
// change, since a wrapped payload still renders a perfectly valid code.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:akop_member_app/design_system/app_theme.dart';
import 'package:akop_member_app/screens/member_qr_screen.dart';

const _member = {
  'id': '001-0100-0051',
  'full_name': 'Juan Dela Cruz',
  'rank': 'Member',
};

Future<void> _show(
  WidgetTester tester,
  Map<String, dynamic> user, {
  ThemeData? theme,
  Size size = const Size(360, 720),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  if (textScale != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MemberQrScreen(userData: user),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('payload', () {
    test('is the member id and nothing else', () {
      expect(MemberQrScreen.qrPayload({'id': 1042, 'full_name': 'Juan'}), '1042');
    });

    test('carries a formatted card number through unchanged', () {
      expect(
          MemberQrScreen.qrPayload({'id': '001-0100-0051'}), '001-0100-0051');
    });

    test('is empty when the account has no id', () {
      expect(MemberQrScreen.qrPayload({'full_name': 'Juan'}), '');
      expect(MemberQrScreen.qrPayload({'id': '   '}), '');
    });
  });

  testWidgets('encodes the bare member id', (tester) async {
    await _show(tester, _member);

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, 'QR code for member ID 001-0100-0051');
  });

  testWidgets('prints the id and the holder alongside the code',
      (tester) async {
    await _show(tester, _member);

    // The printed id is the fallback when the scanner is down, so it has to be
    // on screen too — not only inside the code.
    expect(find.text('001-0100-0051'), findsOneWidget);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('MEMBER'), findsOneWidget);
  });

  testWidgets('the code stays black on white in dark mode', (tester) async {
    await _show(tester, _member, theme: AppTheme.dark);

    // Drawn in surface colours a dark-mode code is decoration: scanners need
    // the contrast the spec assumes.
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.backgroundColor, Colors.white);
    expect(qr.dataModuleStyle.color, Colors.black);
    expect(qr.eyeStyle.color, Colors.black);
  });

  testWidgets('lays out on a narrow phone and at a raised text scale',
      (tester) async {
    await _show(tester, _member, size: const Size(320, 640), textScale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an account with no id gets an explanation, not a blank code',
      (tester) async {
    await _show(tester, {'full_name': 'Juan Dela Cruz'});

    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('No member ID yet'), findsOneWidget);
  });
}
