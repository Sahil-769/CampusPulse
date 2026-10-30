import 'package:campus_pulse_client/campus_pulse_client.dart';

class CampusPulseApi {
  CampusPulseApi({String? serverUrl})
    : client = Client(
        serverUrl ??
            const String.fromEnvironment(
              'CAMPUS_PULSE_SERVER_URL',
              defaultValue: 'http://localhost:8080/',
            ),
      );

  final Client client;

  Future<List<CampusEvent>> listEvents() => client.events.list();

  Future<CampusEvent> getEvent(int eventId) => client.events.get(eventId);

  Future<EventRegistration> registerForEvent(
    int eventId,
    String prototypeStudentId,
  ) => client.events.register(eventId, prototypeStudentId);

  Future<List<CampusEvent>> myRegistrations(String prototypeStudentId) =>
      client.events.myRegistrations(prototypeStudentId);

  Future<List<StudyBuddyMatch>> matchStudyBuddies({
    required List<String> subjects,
    required List<String> goals,
    required List<String> availability,
  }) => client.events.matchStudyBuddies(subjects, goals, availability);

  Future<CampusEvent> createEvent({
    required String title,
    required String category,
    required DateTime startsAt,
    required String venue,
    required String organizer,
    required String description,
    required int capacity,
    required List<String> tags,
  }) => client.events.create(
    title,
    category,
    startsAt,
    venue,
    organizer,
    description,
    capacity,
    tags,
  );
}
