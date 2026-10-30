import '../generated/protocol.dart';
import 'campus_pulse_repository.dart';

class InMemoryCampusPulseRepository implements CampusPulseRepository {
  InMemoryCampusPulseRepository()
    : _events = _seedEvents(),
      _buddies = _seedBuddies() {
    _registrations.addAll([
      _sampleRegistration(1, 'riya.nair@campuspulse.edu', 2),
      _sampleRegistration(2, 'kabir.shah@campuspulse.edu', 1),
      _sampleRegistration(3, 'meera.patel@campuspulse.edu', 4),
      _sampleRegistration(4, 'organizer@campuspulse.edu', 3),
      _sampleRegistration(6, 'organizer@campuspulse.edu', 2),
    ]);
  }

  final Map<int, CampusEvent> _events;
  final List<EventRegistration> _registrations = [];
  final List<StudyBuddyProfile> _buddies;
  int _nextEventId = 11;

  static EventRegistration _sampleRegistration(
    int eventId,
    String studentId,
    int daysAgo,
  ) => EventRegistration(
    eventId: eventId,
    studentId: studentId,
    registeredAt: DateTime.now().toUtc().subtract(Duration(days: daysAgo)),
  );

  @override
  Future<List<CampusEvent>> listEvents() async {
    return _events.values.toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<CampusEvent?> findEvent(int eventId) async => _events[eventId];

  @override
  Future<EventRegistration> registerForEvent({
    required int eventId,
    required String studentId,
  }) async {
    final event = _events[eventId];
    if (event == null) throw EventNotFoundFailure(eventId);
    if (_registrations.any(
      (registration) =>
          registration.eventId == eventId &&
          registration.studentId == studentId,
    )) {
      throw DuplicateRegistrationFailure(eventId, studentId);
    }
    final registration = EventRegistration(
      eventId: eventId,
      studentId: studentId,
      registeredAt: DateTime.now().toUtc(),
    );
    _registrations.add(registration);
    return registration;
  }

  @override
  Future<List<CampusEvent>> listRegisteredEvents(String studentId) async {
    final registeredIds = _registrations
        .where((registration) => registration.studentId == studentId)
        .map((registration) => registration.eventId)
        .toSet();
    return _events.values
        .where((event) => registeredIds.contains(event.id))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<CampusEvent> createEvent(CampusEvent event) async {
    _validateText(event.title, 'title');
    _validateText(event.category, 'category');
    _validateText(event.venue, 'venue');
    _validateText(event.organizer, 'organizer');
    _validateText(event.description, 'description');
    if (event.capacity < 1) {
      throw ArgumentError.value(event.capacity, 'capacity');
    }
    if (!event.startsAt.isAfter(DateTime.now())) {
      throw ArgumentError.value(
        event.startsAt,
        'startsAt',
        'Must be in the future.',
      );
    }
    final created = CampusEvent(
      id: _nextEventId++,
      title: event.title.trim(),
      category: event.category.trim(),
      startsAt: event.startsAt.toUtc(),
      venue: event.venue.trim(),
      organizer: event.organizer.trim(),
      description: event.description.trim(),
      capacity: event.capacity,
      tags: event.tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
    );
    _events[created.id] = created;
    return created;
  }

  @override
  Future<List<StudyBuddyMatch>> matchStudyBuddies({
    required List<String> subjects,
    required List<String> goals,
    required List<String> availability,
  }) async {
    final subjectSet = _normalizedSet(subjects);
    final goalSet = _normalizedSet(goals);
    final availabilitySet = _normalizedSet(availability);
    if (subjectSet.isEmpty && goalSet.isEmpty && availabilitySet.isEmpty) {
      throw ArgumentError(
        'Provide at least one subject, goal, or availability slot.',
      );
    }

    final matches =
        _buddies.map((profile) {
          final sharedSubjects = subjectSet.intersection(
            _normalizedSet(profile.subjects),
          );
          final sharedGoals = goalSet.intersection(
            _normalizedSet(profile.goals),
          );
          final sharedAvailability = availabilitySet.intersection(
            _normalizedSet(profile.availability),
          );
          final score =
              (similarity(subjectSet, _normalizedSet(profile.subjects)) * 50 +
                      similarity(goalSet, _normalizedSet(profile.goals)) * 30 +
                      similarity(
                            availabilitySet,
                            _normalizedSet(profile.availability),
                          ) *
                          20)
                  .round();
          final reasons = <String>[];
          if (sharedSubjects.isNotEmpty) {
            reasons.add('Shared subjects: ${_displayValues(sharedSubjects)}.');
          }
          if (sharedGoals.isNotEmpty) {
            reasons.add('Shared goals: ${_displayValues(sharedGoals)}.');
          }
          if (sharedAvailability.isNotEmpty) {
            reasons.add(
              'Overlapping availability: ${_displayValues(sharedAvailability)}.',
            );
          }
          if (reasons.isEmpty) {
            reasons.add(
              'No shared preferences; this is the lowest-scoring available profile.',
            );
          }
          return StudyBuddyMatch(
            profile: profile,
            score: score,
            reasons: reasons,
          );
        }).toList()..sort((a, b) {
          final scoreOrder = b.score.compareTo(a.score);
          return scoreOrder != 0
              ? scoreOrder
              : a.profile.id.compareTo(b.profile.id);
        });
    return matches;
  }

  static double similarity(Set<String> requested, Set<String> candidate) {
    if (requested.isEmpty && candidate.isEmpty) return 1;
    if (requested.isEmpty || candidate.isEmpty) return 0;
    return requested.intersection(candidate).length /
        requested.union(candidate).length;
  }

  static Set<String> _normalizedSet(Iterable<String> values) => values
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();

  static String _displayValues(Set<String> values) {
    final sortedValues = values.toList()..sort();
    return sortedValues.join(', ');
  }

  static void _validateText(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'Cannot be empty.');
    }
  }

  static Map<int, CampusEvent> _seedEvents() {
    final events = <CampusEvent>[
      _event(
        1,
        'Campus Hackathon 2026',
        'Hackathons',
        11,
        10,
        'Innovation Hall',
        'Tech Club',
        'A full-day innovation sprint with mentoring and final presentations.',
        120,
        ['coding', 'innovation'],
      ),
      _event(
        2,
        'Design Systems Workshop',
        'Workshops',
        12,
        12,
        'Creative Lab',
        'Design Circle',
        'Build reusable components and consistent product experiences.',
        40,
        ['design', 'product'],
      ),
      _event(
        3,
        'AI for Social Impact',
        'Workshops',
        15,
        18,
        'Seminar Block',
        'Campus Labs',
        'Explore responsible AI use cases for community challenges.',
        60,
        ['AI', 'community'],
      ),
      _event(
        4,
        'Inter-College Sports Fest',
        'Sports',
        18,
        9,
        'Main Turf',
        'Sports Council',
        'A weekend of team events and campus sports.',
        180,
        ['sports', 'teams'],
      ),
      _event(
        5,
        'Build for Good: Civic Tech Sprint',
        'Hackathons',
        8,
        9,
        'Innovation Hall',
        'Tech Club',
        'Prototype practical digital tools for campus and local community challenges with mentor reviews throughout the day.',
        80,
        ['coding', 'community', 'innovation'],
      ),
      _event(
        6,
        'Product Design Critique Night',
        'Clubs',
        10,
        17,
        'Creative Lab',
        'Design Circle',
        'Bring a project in progress for a friendly peer critique covering user flows, accessibility, and visual design decisions.',
        30,
        ['design', 'accessibility', 'product'],
      ),
      _event(
        7,
        'Git and GitHub for Team Projects',
        'Workshops',
        12,
        16,
        'Engineering Lab 2',
        'Developer Society',
        'Practice branches, pull requests, and code reviews in a guided workshop for students building their first team project.',
        45,
        ['git', 'coding', 'teamwork'],
      ),
      _event(
        8,
        'Open Mic on the Quad',
        'Clubs',
        14,
        18,
        'Central Quad',
        'Arts and Culture Club',
        'An evening of student music, poetry, and short performances. Sign up for a spot or come support campus artists.',
        60,
        ['arts', 'music', 'community'],
      ),
      _event(
        9,
        'Data Science Case Challenge',
        'Hackathons',
        18,
        10,
        'Business School Auditorium',
        'Analytics Society',
        'Explore a real-world dataset in small teams, develop a clear insight, and present findings to faculty and industry guests.',
        50,
        ['data science', 'analytics', 'teamwork'],
      ),
      _event(
        10,
        'Sunrise 5K Campus Run',
        'Sports',
        21,
        7,
        'North Gate Track',
        'Running Club',
        'A relaxed campus 5K for all experience levels, with warm-up groups, water stations, and breakfast at the student center.',
        100,
        ['running', 'wellness', 'sports'],
      ),
    ];
    return {for (final event in events) event.id: event};
  }

  static CampusEvent _event(
    int id,
    String title,
    String category,
    int day,
    int hour,
    String venue,
    String organizer,
    String description,
    int capacity,
    List<String> tags,
  ) => CampusEvent(
    id: id,
    title: title,
    category: category,
    startsAt: DateTime.utc(2026, 11, day, hour),
    venue: venue,
    organizer: organizer,
    description: description,
    capacity: capacity,
    tags: tags,
  );

  static List<StudyBuddyProfile> _seedBuddies() => [
    StudyBuddyProfile(
      id: 1,
      name: 'Riya Nair',
      major: 'CSE',
      year: '3rd Year',
      subjects: ['DSA', 'Web Development', 'UI/UX Design'],
      goals: ['Placement Preparation', 'Project Work'],
      availability: ['Mon Morning', 'Wed Evening', 'Sat Afternoon'],
    ),
    StudyBuddyProfile(
      id: 2,
      name: 'Arjun Mehta',
      major: 'ECE',
      year: '2nd Year',
      subjects: ['DSA', 'Machine Learning', 'App Development'],
      goals: ['Project Work', 'Learning New Skills'],
      availability: ['Tue Evening', 'Sat Afternoon', 'Sun Morning'],
    ),
    StudyBuddyProfile(
      id: 3,
      name: 'Samaira Shah',
      major: 'IT',
      year: '3rd Year',
      subjects: ['UI/UX Design', 'Web Development'],
      goals: ['Exam Revision', 'Placement Preparation'],
      availability: ['Thu Morning', 'Fri Evening'],
    ),
    StudyBuddyProfile(
      id: 4,
      name: 'Dev Malhotra',
      major: 'CSE',
      year: '2nd Year',
      subjects: ['Data Science', 'Machine Learning', 'Python'],
      goals: ['Research Experience', 'Project Work'],
      availability: ['Mon Evening', 'Wed Afternoon', 'Sat Morning'],
    ),
    StudyBuddyProfile(
      id: 5,
      name: 'Anika Bose',
      major: 'ECE',
      year: '3rd Year',
      subjects: ['Embedded Systems', 'IoT', 'Digital Logic'],
      goals: ['Project Work', 'Placement Preparation'],
      availability: ['Tue Afternoon', 'Thu Evening', 'Sun Morning'],
    ),
    StudyBuddyProfile(
      id: 6,
      name: 'Kabir Khanna',
      major: 'Mechanical',
      year: '2nd Year',
      subjects: ['CAD', 'Robotics', 'Manufacturing'],
      goals: ['Competition Preparation', 'Learning New Skills'],
      availability: ['Wed Evening', 'Fri Afternoon', 'Sat Morning'],
    ),
    StudyBuddyProfile(
      id: 7,
      name: 'Mira Iyer',
      major: 'IT',
      year: '4th Year',
      subjects: ['Cybersecurity', 'Networking', 'Cloud Computing'],
      goals: ['Placement Preparation', 'Research Experience'],
      availability: ['Mon Afternoon', 'Thu Morning', 'Sun Evening'],
    ),
  ];
}
