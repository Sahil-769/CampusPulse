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
import 'package:campus_pulse_server/src/generated/protocol.dart' as _i2t5n14n;
import 'package:serverpod/serverpod.dart' as _is;

abstract class StudyBuddyProfile
    implements _is.SerializableModel, _is.ProtocolSerialization {
  StudyBuddyProfile._({
    required this.id,
    required this.name,
    required this.major,
    required this.year,
    required this.subjects,
    required this.goals,
    required this.availability,
  });

  factory StudyBuddyProfile({
    required int id,
    required String name,
    required String major,
    required String year,
    required List<String> subjects,
    required List<String> goals,
    required List<String> availability,
  }) = _StudyBuddyProfileImpl;

  factory StudyBuddyProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return StudyBuddyProfile(
      id: jsonSerialization['id'] as int,
      name: jsonSerialization['name'] as String,
      major: jsonSerialization['major'] as String,
      year: jsonSerialization['year'] as String,
      subjects: _i2t5n14n.Protocol().deserialize<List<String>>(
        jsonSerialization['subjects'],
      ),
      goals: _i2t5n14n.Protocol().deserialize<List<String>>(
        jsonSerialization['goals'],
      ),
      availability: _i2t5n14n.Protocol().deserialize<List<String>>(
        jsonSerialization['availability'],
      ),
    );
  }

  int id;

  String name;

  String major;

  String year;

  List<String> subjects;

  List<String> goals;

  List<String> availability;

  /// Returns a shallow copy of this [StudyBuddyProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StudyBuddyProfile copyWith({
    int? id,
    String? name,
    String? major,
    String? year,
    List<String>? subjects,
    List<String>? goals,
    List<String>? availability,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StudyBuddyProfile',
      'id': id,
      'name': name,
      'major': major,
      'year': year,
      'subjects': subjects.toJson(),
      'goals': goals.toJson(),
      'availability': availability.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StudyBuddyProfile',
      'id': id,
      'name': name,
      'major': major,
      'year': year,
      'subjects': subjects.toJson(),
      'goals': goals.toJson(),
      'availability': availability.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _StudyBuddyProfileImpl extends StudyBuddyProfile {
  _StudyBuddyProfileImpl({
    required int id,
    required String name,
    required String major,
    required String year,
    required List<String> subjects,
    required List<String> goals,
    required List<String> availability,
  }) : super._(
         id: id,
         name: name,
         major: major,
         year: year,
         subjects: subjects,
         goals: goals,
         availability: availability,
       );

  /// Returns a shallow copy of this [StudyBuddyProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StudyBuddyProfile copyWith({
    int? id,
    String? name,
    String? major,
    String? year,
    List<String>? subjects,
    List<String>? goals,
    List<String>? availability,
  }) {
    return StudyBuddyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      major: major ?? this.major,
      year: year ?? this.year,
      subjects: subjects ?? this.subjects.map((e0) => e0).toList(),
      goals: goals ?? this.goals.map((e0) => e0).toList(),
      availability: availability ?? this.availability.map((e0) => e0).toList(),
    );
  }
}
