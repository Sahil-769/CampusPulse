import '../generated/protocol.dart';

class EventNotFoundFailure implements Exception {
  final int eventId;

  const EventNotFoundFailure(this.eventId);
}

class DuplicateRegistrationFailure implements Exception {
  final int eventId;
  final String studentId;

  const DuplicateRegistrationFailure(this.eventId, this.studentId);
}

abstract interface class CampusPulseRepository {
  Future<List<CampusEvent>> listEvents();

  Future<CampusEvent?> findEvent(int eventId);

  Future<EventRegistration> registerForEvent({
    required int eventId,
    required String studentId,
  });

  Future<List<CampusEvent>> listRegisteredEvents(String studentId);

  Future<CampusEvent> createEvent(CampusEvent event);

  Future<List<StudyBuddyMatch>> matchStudyBuddies({
    required List<String> subjects,
    required List<String> goals,
    required List<String> availability,
  });
}
