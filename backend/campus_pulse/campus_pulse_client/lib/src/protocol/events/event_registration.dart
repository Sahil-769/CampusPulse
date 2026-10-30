/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class EventRegistration
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EventRegistration._({
    required this.eventId,
    required this.studentId,
    required this.registeredAt,
  });

  factory EventRegistration({
    required int eventId,
    required String studentId,
    required DateTime registeredAt,
  }) = _EventRegistrationImpl;

  factory EventRegistration.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventRegistration(
      eventId: jsonSerialization['eventId'] as int,
      studentId: jsonSerialization['studentId'] as String,
      registeredAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['registeredAt'],
      ),
    );
  }

  int eventId;

  String studentId;

  DateTime registeredAt;

  /// Returns a shallow copy of this [EventRegistration]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EventRegistration copyWith({
    int? eventId,
    String? studentId,
    DateTime? registeredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventRegistration',
      'eventId': eventId,
      'studentId': studentId,
      'registeredAt': registeredAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EventRegistration',
      'eventId': eventId,
      'studentId': studentId,
      'registeredAt': registeredAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _EventRegistrationImpl extends EventRegistration {
  _EventRegistrationImpl({
    required int eventId,
    required String studentId,
    required DateTime registeredAt,
  }) : super._(
         eventId: eventId,
         studentId: studentId,
         registeredAt: registeredAt,
       );

  /// Returns a shallow copy of this [EventRegistration]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EventRegistration copyWith({
    int? eventId,
    String? studentId,
    DateTime? registeredAt,
  }) {
    return EventRegistration(
      eventId: eventId ?? this.eventId,
      studentId: studentId ?? this.studentId,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}
