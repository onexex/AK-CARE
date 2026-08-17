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

/// One row shaped the way get_activities.php hands it back.
Map<String, dynamic> _activity({
  int id = 1,
  String title = 'Medical mission',
  String type = 'medical',
  String scheduledAt = '2026-08-20 09:00:00',
  String? endsAt,
  String province = 'Batangas',
  Object nearYou = 0,
}) =>
    {
      'id': '$id',
      'type': type,
      'title': title,
      'scheduled_at': scheduledAt,
      'ends_at': endsAt,
      'barangay': 'Santa Anastacia',
      'city_municipality': 'City of Sto. Tomas',
      'province': province,
      'near_you': nearYou,
      'contact_person': null,
      'contact_number': null,
    };

/// Answers the news call and the activities call independently, so a test can
/// fail one without the other — which is the whole point of them being two
/// calls.
http.Client _server({
  Object? news,
  Object? activities,
  bool newsFails = false,
  bool activitiesFail = false,
}) =>
    MockClient((request) async {
      if (request.url.path.endsWith('get_activities.php')) {
        if (activitiesFail) throw Exception('offline');
        return http.Response(
          jsonEncode({'status': 'success', 'data': activities ?? []}),
          200,
        );
      }
      if (newsFails) throw Exception('offline');
      return http.Response(jsonEncode(news ?? []), 200);
    });

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

    testWidgets('an unreachable server says so, and offers a retry',
        (tester) async {
      Api.client = MockClient((_) async => throw Exception('offline'));

      await _show(tester, const NewsScreen());

      expect(find.text('Could not load the news'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a quiet news week is not dressed up as a failure',
        (tester) async {
      // The other half of the distinction. An empty list is a real answer and
      // must keep reading as one.
      Api.client =
          MockClient((_) async => http.Response(jsonEncode([]), 200));

      await _show(tester, const NewsScreen());

      expect(find.text('No News'), findsOneWidget);
      expect(find.text('Could not load the news'), findsNothing);
    });

    testWidgets('a body that is not JSON reads as a failure, not as no news',
        (tester) async {
      // '0 results[]' is what get_news.php used to send when the table was
      // empty — it echoed a message ahead of the JSON. The server no longer
      // does that, so this is now a guard rather than a live case: whatever
      // reason a body arrives unreadable, the screen must call it a failure
      // instead of dressing it up as an empty shelf.
      Api.client = MockClient((_) async => http.Response('0 results[]', 200));

      await _show(tester, const NewsScreen());

      expect(find.text('Could not load the news'), findsOneWidget);
      expect(find.text('No News'), findsNothing);
    });

    testWidgets('the retry goes back to the server', (tester) async {
      // Counts the news calls only — the screen also asks for activities, and
      // counting both would make the first news call look like the second.
      var newsCalls = 0;
      Api.client = MockClient((request) async {
        if (request.url.path.endsWith('get_activities.php')) {
          return http.Response(
              jsonEncode({'status': 'success', 'data': []}), 200);
        }
        newsCalls++;
        if (newsCalls == 1) throw Exception('offline');
        return http.Response(jsonEncode([_article()]), 200);
      });

      await _show(tester, const NewsScreen());
      expect(find.text('Could not load the news'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.text('Free check-ups this month'), findsOneWidget);
      expect(newsCalls, 2);
    });
  });

  group('Upcoming activities', () {
    testWidgets('appear above the news', (tester) async {
      Api.client = _server(
        news: [_article()],
        activities: [_activity(title: 'Medical mission')],
      );

      await _show(tester, const NewsScreen());

      expect(find.text('Upcoming Activities'), findsOneWidget);
      expect(find.text('Medical mission'), findsOneWidget);
      expect(find.text('Santa Anastacia, City of Sto. Tomas, Batangas'),
          findsOneWidget);
      // The stories are still there underneath.
      expect(find.text('Free check-ups this month'), findsOneWidget);
    });

    testWidgets('one in the member\'s province is marked, others are not',
        (tester) async {
      Api.client = _server(activities: [
        _activity(id: 1, title: 'Near one', nearYou: 1),
        _activity(id: 2, title: 'Far one', province: 'Zambales'),
      ]);

      await _show(tester, const NewsScreen());

      expect(find.text('Near you'), findsOneWidget);
      expect(find.text('Near one'), findsOneWidget);
      expect(find.text('Far one'), findsOneWidget,
          reason: 'proximity marks an activity, it never hides one');
    });

    testWidgets('the section keeps out of the way when there are none',
        (tester) async {
      Api.client = _server(news: [_article()], activities: []);

      await _show(tester, const NewsScreen());

      expect(find.text('Upcoming Activities'), findsNothing);
      expect(find.text('Free check-ups this month'), findsOneWidget);
    });

    testWidgets('a search hides them, so the results are only what was asked',
        (tester) async {
      Api.client = _server(
        news: [_article(title: 'Free check-ups this month')],
        activities: [_activity(title: 'Medical mission')],
      );

      await _show(tester, const NewsScreen());
      expect(find.text('Upcoming Activities'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'check-ups');
      await tester.pumpAndSettle();

      expect(find.text('Upcoming Activities'), findsNothing);
      expect(find.text('Free check-ups this month'), findsOneWidget);
    });

    testWidgets('the two calls fail independently', (tester) async {
      // Activities down, news up: the member still gets their stories rather
      // than an error for something that is an addition to the screen.
      Api.client = _server(news: [_article()], activitiesFail: true);

      await _show(tester, const NewsScreen());

      expect(find.text('Upcoming Activities'), findsNothing);
      expect(find.text('Free check-ups this month'), findsOneWidget);
      expect(find.text('Could not load the news'), findsNothing);
    });

    testWidgets('news down does not take the activities with it',
        (tester) async {
      Api.client = _server(activities: [_activity()], newsFails: true);

      await _show(tester, const NewsScreen());

      expect(find.text('Upcoming Activities'), findsOneWidget);
      expect(find.text('Could not load the news'), findsOneWidget);
    });

    testWidgets('pulling the screen down refreshes them too', (tester) async {
      // A strip that never moved would be the one stale thing on a screen the
      // member just asked to be current.
      var activityCalls = 0;
      Api.client = MockClient((request) async {
        if (request.url.path.endsWith('get_activities.php')) {
          activityCalls++;
          return http.Response(
              jsonEncode({
                'status': 'success',
                'data': [_activity(title: 'Medical mission')]
              }),
              200);
        }
        return http.Response(jsonEncode([_article()]), 200);
      });

      await _show(tester, const NewsScreen());
      expect(activityCalls, 1);

      await tester.fling(
          find.text('Free check-ups this month'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(activityCalls, 2, reason: 'the pull asked for them again');
    });

    testWidgets('the strip holds together at a raised text scale',
        (tester) async {
      // The cards are a fixed 132dp tall, which is the kind of number that
      // stops being enough the moment someone turns text size up.
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Api.client = _server(activities: [
        _activity(title: 'Medical mission', endsAt: '2026-08-21 17:00:00'),
      ]);

      await _show(tester, const NewsScreen());

      expect(find.text('Upcoming Activities'), findsOneWidget);
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
