import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_pulse/main.dart';

void main() {
  group('Campus workflows', () {
    late CampusDataController controller;

    setUp(() {
      controller = CampusDataController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('bookmarks can be added and removed', () {
      controller.toggleBookmark(2);
      expect(controller.state.bookmarkedEventIds, contains(2));

      controller.toggleBookmark(2);
      expect(controller.state.bookmarkedEventIds, isNot(contains(2)));
    });

    test('event registrations update shared state and prevent duplicates', () {
      final initialSeats = controller.state.eventById(2)!.seatsLeft;

      expect(
        controller.registerForEvent(
          2,
          studentName: 'Taylor Student',
          email: 'taylor@campus.edu',
        ),
        isTrue,
      );
      expect(
        controller.registerForEvent(
          2,
          studentName: 'Taylor Student',
          email: 'taylor@campus.edu',
        ),
        isFalse,
      );
      expect(controller.state.isRegistered(2, 'taylor@campus.edu'), isTrue);
      expect(controller.state.eventById(2)!.seatsLeft, initialSeats - 1);
    });

    test('organizers can publish events and check in attendees', () {
      final event = controller.createEvent(
        const DemoEvent(
          id: 0,
          title: 'Campus Build Night',
          date: '12 Nov 2026',
          time: '5:00 PM',
          venue: 'Innovation Hall',
          organizer: 'Campus Crew',
          category: 'Clubs',
          color: kPrimaryBlue,
          isRegistered: false,
          seatsLeft: 50,
          description: 'Build something with your campus community.',
        ),
      );
      expect(controller.state.eventById(event.id)?.title, event.title);

      expect(controller.checkIn(1), isTrue);
      expect(
        controller.state.registrations
            .firstWhere((registration) => registration.id == 1)
            .checkedIn,
        isTrue,
      );
      expect(controller.checkIn(1), isFalse);
    });

    test('match requests can only be sent once per buddy', () {
      final buddy = demoBuddies.first;
      expect(
        controller.sendMatchRequest(buddy, senderName: 'Taylor Student'),
        isTrue,
      );
      expect(
        controller.sendMatchRequest(buddy, senderName: 'Taylor Student'),
        isFalse,
      );
      expect(controller.state.hasOutgoingMatchRequest(buddy.id), isTrue);
    });

    test(
      'matching breakdown accounts for study fit, goals, and availability',
      () {
        final breakdown = calculateStudyMatchBreakdown(
          subjectsA: {'DSA'},
          subjectsB: {'DSA'},
          skillsA: {'Flutter'},
          skillsB: {'Flutter'},
          goalsA: {'Project Work'},
          goalsB: {'Project Work'},
          availabilityA: {'Sat Afternoon'},
          availabilityB: {'Sat Afternoon'},
        );

        expect(breakdown.studyContribution, 50);
        expect(breakdown.goalContribution, 30);
        expect(breakdown.availabilityContribution, 20);
        expect(breakdown.score, 100);
      },
    );
  });

  group('Event discovery UI', () {
    testWidgets('search and category chips filter events', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ExploreEventsScreen())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'AI for Social Impact',
      );
      await tester.pumpAndSettle();
      expect(find.text('AI for Social Impact'), findsNWidgets(2));
      expect(find.text('Campus Hackathon 2026'), findsNothing);

      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sports'));
      await tester.pumpAndSettle();
      expect(find.text('Inter-College Sports Fest'), findsOneWidget);
      expect(find.text('Design Systems Workshop'), findsNothing);
    });

    testWidgets('bookmarks can narrow the feed to saved events', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(actions: [const ExploreSavedFilterButton()]),
              body: const ExploreEventsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bookmarkButton = find.byTooltip('Bookmark event').first;
      await tester.ensureVisible(bookmarkButton);
      await tester.tap(bookmarkButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Show saved events'));
      await tester.pumpAndSettle();

      expect(find.text('Campus Hackathon 2026'), findsOneWidget);
      expect(find.text('Design Systems Workshop'), findsNothing);
    });
  });
}
