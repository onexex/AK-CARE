// Empty states that carry a Try Again button.
//
// AppEmptyState is a centred column: icon block, title, subtitle, and — when
// there is an action — a button, which takes it to roughly 290dp. Screens were
// pinning that into SizedBox(height: 0.4 * screen), and 0.4 of a short screen
// is 240. It fitted on a tall handset and clipped everywhere else, silently in
// release builds.
//
// These drive the real screens to their failure state through the Api seam and
// hold them at viewport heights where a fixed fraction is not enough.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akop_member_app/core/api.dart';
import 'package:akop_member_app/design_system/app_theme.dart';
import 'package:akop_member_app/screens/community_feed_screen.dart';
import 'package:akop_member_app/screens/eprescription_screen.dart';
import 'package:akop_member_app/screens/history_screen.dart';
import 'package:akop_member_app/screens/medical_certs_screen.dart';
import 'package:akop_member_app/screens/notifications_screen.dart';
import 'package:akop_member_app/screens/request_status_screen.dart';

/// Short enough that 0.4 and 0.5 of it cannot hold the state with its button.
const _shortPhone = Size(360, 600);

Future<void> _showAt(
  WidgetTester tester,
  Widget screen, {
  Size size = _shortPhone,
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

  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Api.resetClient);

  group('Medical certificates', () {
    testWidgets('the failure state fits a short screen', (tester) async {
      Api.client = MockClient((_) async => throw Exception('offline'));

      await _showAt(tester, const MedicalCertsScreen());

      expect(find.text('Could not load your certificates'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('and still fits with the system font turned up',
        (tester) async {
      Api.client = MockClient((_) async => throw Exception('offline'));

      await _showAt(tester, const MedicalCertsScreen(), textScale: 1.3);

      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the empty state fits too', (tester) async {
      Api.client = MockClient((_) async => http.Response(
            jsonEncode({'status': 'success', 'data': []}),
            200,
          ));

      await _showAt(tester, const MedicalCertsScreen());

      expect(find.text('No Requests'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('E-Prescriptions', () {
    testWidgets('the failure state fits a short screen', (tester) async {
      Api.client = MockClient((_) async => throw Exception('offline'));

      await _showAt(tester, const EPrescriptionScreen());

      expect(find.text('Could not load your records'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('and still fits with the system font turned up',
        (tester) async {
      Api.client = MockClient((_) async => throw Exception('offline'));

      await _showAt(tester, const EPrescriptionScreen(), textScale: 1.3);

      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the empty state fits too', (tester) async {
      Api.client = MockClient((_) async => http.Response(
            jsonEncode({'status': 'success', 'data': []}),
            200,
          ));

      await _showAt(tester, const EPrescriptionScreen());

      expect(find.text('Nothing from a doctor yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // The rest of the sweep. None of these carry an action button, so each had
  // the slack the two above did not — they are covered because a fixed height
  // was the wrong tool everywhere, not because they were visibly broken.
  group('the action-less states', () {
    /// Every screen here answers an empty list; only the envelope differs.
    void serveEmpty() {
      Api.client = MockClient((_) async => http.Response(
            jsonEncode({'status': 'success', 'data': [], 'notifications': []}),
            200,
          ));
    }

    testWidgets('teleconsult requests', (tester) async {
      serveEmpty();
      await _showAt(tester, const RequestStatusScreen(), textScale: 1.3);

      expect(find.text('No Requests Yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('history', (tester) async {
      serveEmpty();
      await _showAt(tester, const HistoryScreen(), textScale: 1.3);

      expect(find.text('No History Yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('notifications', (tester) async {
      serveEmpty();
      await _showAt(tester, const NotificationsScreen(), textScale: 1.3);

      expect(find.text('No Notifications'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('community feed', (tester) async {
      serveEmpty();
      await _showAt(tester, const CommunityFeedScreen(), textScale: 1.3);

      expect(find.text('No Posts Yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
