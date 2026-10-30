import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'campus_pulse_repository.dart';
import 'in_memory_campus_pulse_repository.dart';

class EventsEndpoint extends Endpoint {
  static final CampusPulseRepository _repository =
      InMemoryCampusPulseRepository();

  Future<List<CampusEvent>> list(Session session) => _repository.listEvents();

  Future<CampusEvent> get(Session session, int eventId) async {
    _validatePositiveId(eventId, 'eventId');
    final event = await _repository.findEvent(eventId);
    if (event == null) {
      throw EventNotFoundException(message: 'Event $eventId was not found.');
    }
    return event;
  }

  Future<EventRegistration> register(
    Session session,
    int eventId,
    String prototypeStudentId,
  ) async {
    _validatePositiveId(eventId, 'eventId');
    final studentId = prototypeStudentId.trim();
    if (studentId.isEmpty || studentId.length > 100) {
      throw InvalidRequestException(
        message: 'A valid prototype student ID is required.',
      );
    }
    try {
      return await _repository.registerForEvent(
        eventId: eventId,
        studentId: studentId,
      );
    } on DuplicateRegistrationFailure catch (error) {
      throw DuplicateRegistrationException(
        message:
            'Student ${error.studentId} is already registered for event ${error.eventId}.',
      );
    } on EventNotFoundFailure catch (error) {
      throw EventNotFoundException(
        message: 'Event ${error.eventId} was not found.',
      );
    }
  }

  Future<List<CampusEvent>> myRegistrations(
    Session session,
    String prototypeStudentId,
  ) async {
    final studentId = prototypeStudentId.trim();
    if (studentId.isEmpty || studentId.length > 100) {
      throw InvalidRequestException(
        message: 'A valid prototype student ID is required.',
      );
    }
    return _repository.listRegisteredEvents(studentId);
  }

  Future<CampusEvent> create(
    Session session,
    String title,
    String category,
    DateTime startsAt,
    String venue,
    String organizer,
    String description,
    int capacity,
    List<String> tags,
  ) async {
    if (tags.length > 20 || tags.any((tag) => tag.trim().length > 40)) {
      throw InvalidRequestException(
        message: 'Event tags exceed the allowed limits.',
      );
    }
    try {
      return await _repository.createEvent(
        CampusEvent(
          id: 0,
          title: title,
          category: category,
          startsAt: startsAt,
          venue: venue,
          organizer: organizer,
          description: description,
          capacity: capacity,
          tags: tags,
        ),
      );
    } on ArgumentError catch (error) {
      throw InvalidRequestException(
        message: error.message?.toString() ?? 'Invalid event.',
      );
    }
  }

  Future<List<StudyBuddyMatch>> matchStudyBuddies(
    Session session,
    List<String> subjects,
    List<String> goals,
    List<String> availability,
  ) async {
    if (subjects.length > 30 || goals.length > 30 || availability.length > 30) {
      throw InvalidRequestException(message: 'Too many matching preferences.');
    }
    try {
      return await _repository.matchStudyBuddies(
        subjects: subjects,
        goals: goals,
        availability: availability,
      );
    } on ArgumentError catch (error) {
      throw InvalidRequestException(
        message: error.message?.toString() ?? 'Invalid preferences.',
      );
    }
  }

  static void _validatePositiveId(int id, String field) {
    if (id < 1) {
      throw InvalidRequestException(message: '$field must be positive.');
    }
  }
}
