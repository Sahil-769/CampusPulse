import 'package:campus_pulse_server/src/events/in_memory_campus_pulse_repository.dart';
import 'package:campus_pulse_server/src/events/campus_pulse_repository.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryCampusPulseRepository', () {
    late InMemoryCampusPulseRepository repository;

    setUp(() {
      repository = InMemoryCampusPulseRepository();
    });

    test('seeds and returns campus events by ID', () async {
      final events = await repository.listEvents();
      final event = await repository.findEvent(1);

      expect(events, hasLength(10));
      expect(event?.title, 'Campus Hackathon 2026');
      expect(await repository.findEvent(999), isNull);
    });

    test('rejects a registration for an unknown event', () async {
      await expectLater(
        repository.registerForEvent(eventId: 999, studentId: 'student-a'),
        throwsA(isA<EventNotFoundFailure>()),
      );
    });

    test('returns seeded registrations for sample accounts only', () async {
      final sampleRegistrations = await repository.listRegisteredEvents(
        'riya.nair@campuspulse.edu',
      );
      final presenterRegistrations = await repository.listRegisteredEvents(
        'student@campuspulse.edu',
      );

      expect(sampleRegistrations.map((event) => event.id), [1]);
      expect(presenterRegistrations, isEmpty);
    });

    test(
      'rejects duplicate registrations and returns a student list',
      () async {
        await repository.registerForEvent(eventId: 1, studentId: 'student-a');
        await repository.registerForEvent(eventId: 2, studentId: 'student-b');

        await expectLater(
          repository.registerForEvent(eventId: 1, studentId: 'student-a'),
          throwsA(isA<DuplicateRegistrationFailure>()),
        );
        expect(
          await repository.listRegisteredEvents('student-a'),
          hasLength(1),
        );
        expect(
          (await repository.listRegisteredEvents(
            'student-a',
          )).map((event) => event.id),
          [1],
        );
        expect(
          await repository.listRegisteredEvents('student-b'),
          hasLength(1),
        );
        expect(await repository.listRegisteredEvents('student-c'), isEmpty);
      },
    );

    test('creates an event with a repository-assigned ID', () async {
      final created = await repository.createEvent(
        (await repository.findEvent(1))!.copyWith(
          id: 0,
          title: 'Prototype Organizer Event',
          startsAt: DateTime.now().add(const Duration(days: 10)),
        ),
      );

      expect(created.id, 11);
      expect(
        (await repository.listEvents()).map((event) => event.id),
        contains(9),
      );
    });

    test('returns stable match scores and explainable reasons', () async {
      final first = await repository.matchStudyBuddies(
        subjects: ['DSA', 'Web Development', 'UI/UX Design'],
        goals: ['Placement Preparation', 'Project Work'],
        availability: ['Mon Morning', 'Wed Evening', 'Sat Afternoon'],
      );
      final second = await repository.matchStudyBuddies(
        subjects: ['DSA', 'Web Development', 'UI/UX Design'],
        goals: ['Placement Preparation', 'Project Work'],
        availability: ['Mon Morning', 'Wed Evening', 'Sat Afternoon'],
      );

      expect(first.map((match) => match.score), [100, 43, 30, 24, 10, 10, 4]);
      expect(first.map((match) => match.profile.id), [1, 3, 5, 2, 4, 7, 6]);
      expect(
        first.map((match) => match.score),
        second.map((match) => match.score),
      );
      expect(first.first.reasons, contains(contains('Shared subjects')));
      expect(first.first.reasons, contains(contains('Shared goals')));
      expect(
        first.first.reasons,
        contains(contains('Overlapping availability')),
      );
    });
  });
}
