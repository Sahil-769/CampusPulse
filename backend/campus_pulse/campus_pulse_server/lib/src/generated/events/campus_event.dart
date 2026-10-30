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

abstract class CampusEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CampusEvent._({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.venue,
    required this.organizer,
    required this.description,
    required this.capacity,
    required this.tags,
  });

  factory CampusEvent({
    required int id,
    required String title,
    required String category,
    required DateTime startsAt,
    required String venue,
    required String organizer,
    required String description,
    required int capacity,
    required List<String> tags,
  }) = _CampusEventImpl;

  factory CampusEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampusEvent(
      id: jsonSerialization['id'] as int,
      title: jsonSerialization['title'] as String,
      category: jsonSerialization['category'] as String,
      startsAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      venue: jsonSerialization['venue'] as String,
      organizer: jsonSerialization['organizer'] as String,
      description: jsonSerialization['description'] as String,
      capacity: jsonSerialization['capacity'] as int,
      tags: _i2t5n14n.Protocol().deserialize<List<String>>(
        jsonSerialization['tags'],
      ),
    );
  }

  int id;

  String title;

  String category;

  DateTime startsAt;

  String venue;

  String organizer;

  String description;

  int capacity;

  List<String> tags;

  /// Returns a shallow copy of this [CampusEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampusEvent copyWith({
    int? id,
    String? title,
    String? category,
    DateTime? startsAt,
    String? venue,
    String? organizer,
    String? description,
    int? capacity,
    List<String>? tags,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampusEvent',
      'id': id,
      'title': title,
      'category': category,
      'startsAt': startsAt.toJson(),
      'venue': venue,
      'organizer': organizer,
      'description': description,
      'capacity': capacity,
      'tags': tags.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampusEvent',
      'id': id,
      'title': title,
      'category': category,
      'startsAt': startsAt.toJson(),
      'venue': venue,
      'organizer': organizer,
      'description': description,
      'capacity': capacity,
      'tags': tags.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CampusEventImpl extends CampusEvent {
  _CampusEventImpl({
    required int id,
    required String title,
    required String category,
    required DateTime startsAt,
    required String venue,
    required String organizer,
    required String description,
    required int capacity,
    required List<String> tags,
  }) : super._(
         id: id,
         title: title,
         category: category,
         startsAt: startsAt,
         venue: venue,
         organizer: organizer,
         description: description,
         capacity: capacity,
         tags: tags,
       );

  /// Returns a shallow copy of this [CampusEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampusEvent copyWith({
    int? id,
    String? title,
    String? category,
    DateTime? startsAt,
    String? venue,
    String? organizer,
    String? description,
    int? capacity,
    List<String>? tags,
  }) {
    return CampusEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startsAt: startsAt ?? this.startsAt,
      venue: venue ?? this.venue,
      organizer: organizer ?? this.organizer,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      tags: tags ?? this.tags.map((e0) => e0).toList(),
    );
  }
}
