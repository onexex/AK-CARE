// News and Pharmacy Discounts, driven through a scripted server.
//
// Both screens used to call `http` directly, so neither could be rendered
// without a live XAMPP behind it. Going through Api put them on the same seam
// as the sign-in flow; these tests are what that seam buys.
//
// The two endpoints do not answer alike — pharmacy_discounts.php uses the
// {status, data} envelope, get_news.php returns a bare array — and that
// difference is the reason Api.getList exists, so it is pinned here.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akop_member_app/core/api.dart';
import 'package:akop_member_app/design_system/app_theme.dart';
import 'package:akop_member_app/screens/news_screen.dart';
import 'package:akop_member_app/screens/pharmacy_discounts_screen.dart';

/// One row shaped the way `news_corner` hands it back.
Map<String, dynamic> _article({
  int id = 1,
  String title = 'Free check-ups this month',
  String category = 'Health',
}) =>
    {
      'news_id': '$id',
      'headline_title': title,
      'content_body': 'Body text.',
      'category_tag': category,
      'author_source': 'AK MIYEMBRO',
      'date_time_published': '2026-08-14 09:00:00',
      'image_url': '',
    };

Future<void> _show(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
  await tester.pumpAndSettle();
}

void main() {
  // Api attaches the session token to every request, so even a screen whose
  // endpoint is public reads prefs on its way out. Without this the read never
  // completes, the spinner animates forever and pumpAndSettle times out.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  tearDown(Api.resetClient);

  group('News', () {
    testWidgets('renders the articles the server returns', (tester) async {
      Api.client = MockClient((_) async => http.Response(
            jsonEncode([
              _article(title: 'Free check-ups this month'),
              _article(id: 2, title: 'New partner clinic in Cebu'),
            ]),
            200,
          ));

      await _show(tester, const NewsScreen());

      expect(find.text('Free check-ups this month'), findsOneWidget);
      expect(find.text('New partner clinic in Cebu'), findsOneWidget);
    });

    testWidgets('a bare array is read, where the envelope would not be',
        (tester) async {
      // The precise reason Api.getList exists. Wrapping the same rows in the
      // usual envelope is what this endpoint does NOT do, and reading it that
      // way yields nothing.
      Api.client = MockClient((_) async => http.Response(
            jsonEncode({
              'status': 'success',
              'data': [_article()]
            }),
            200,
          ));

      await _show(tester, const NewsScreen());

      expect(find.text('Free check-ups this month'), findsNothing,
          reason: 'an enveloped body is not the shape this endpoint sends');
    });

    testWidgets('an unreachable server leaves the screen standing',
        (tester) async {
      Api.client = MockClient((_) async => throw Exception('offline'));

      await _show(tester, const NewsScreen());

      expect(tester.takeException(), isNull);
    });
  });

  group('Pharmacy Discounts', () {
    testWidgets('renders the partners the server returns', (tester) async {
      Api.client = MockClient((_) async => http.Response(
            jsonEncode({
              'status': 'success',
              'data': [
                {
                  'id': '1',
                  'name': 'Mercury Drug',
                  'discount': '15%',
                  'address': 'Cebu City',
                  'phone': '09171234567',
                  'logo': null,
                },
              ],
            }),
            200,
          ));

      await _show(tester, const PharmacyDiscountsScreen());

      expect(find.text('Mercury Drug'), findsOneWidget);
    });

    testWidgets('says there are none rather than spinning forever',
        (tester) async {
      Api.client = MockClient((_) async => http.Response(
            jsonEncode({'status': 'success', 'data': []}),
            200,
          ));

      await _show(tester, const PharmacyDiscountsScreen());

      expect(find.text('No partner pharmacies yet.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('an unreachable server stops the spinner too', (tester) async {
      // Worth its own case: the loading flag is cleared in the failure path as
      // well, so a member offline gets an answer instead of a spinner that
      // never resolves.
      Api.client = MockClient((_) async => throw Exception('offline'));

      await _show(tester, const PharmacyDiscountsScreen());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
