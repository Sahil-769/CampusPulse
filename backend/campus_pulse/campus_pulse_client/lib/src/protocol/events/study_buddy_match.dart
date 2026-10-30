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
import 'package:campus_pulse_client/src/protocol/protocol.dart' as _il98xzab;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../events/study_buddy_profile.dart' as _ii7j4mkj;

abstract class StudyBuddyMatch
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  StudyBuddyMatch._({
    required this.profile,
    required this.score,
    required this.reasons,
  });

  factory StudyBuddyMatch({
    required _ii7j4mkj.StudyBuddyProfile profile,
    required int score,
    required List<String> reasons,
  }) = _StudyBuddyMatchImpl;

  factory StudyBuddyMatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return StudyBuddyMatch(
      profile: _il98xzab.Protocol().deserialize<_ii7j4mkj.StudyBuddyProfile>(
        jsonSerialization['profile'],
      ),
      score: jsonSerialization['score'] as int,
      reasons: _il98xzab.Protocol().deserialize<List<String>>(
        jsonSerialization['reasons'],
      ),
    );
  }

  _ii7j4mkj.StudyBuddyProfile profile;

  int score;

  List<String> reasons;

  /// Returns a shallow copy of this [StudyBuddyMatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StudyBuddyMatch copyWith({
    _ii7j4mkj.StudyBuddyProfile? profile,
    int? score,
    List<String>? reasons,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StudyBuddyMatch',
      'profile': profile.toJson(),
      'score': score,
      'reasons': reasons.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StudyBuddyMatch',
      'profile': profile.toJsonForProtocol(),
      'score': score,
      'reasons': reasons.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _StudyBuddyMatchImpl extends StudyBuddyMatch {
  _StudyBuddyMatchImpl({
    required _ii7j4mkj.StudyBuddyProfile profile,
    required int score,
    required List<String> reasons,
  }) : super._(
         profile: profile,
         score: score,
         reasons: reasons,
       );

  /// Returns a shallow copy of this [StudyBuddyMatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StudyBuddyMatch copyWith({
    _ii7j4mkj.StudyBuddyProfile? profile,
    int? score,
    List<String>? reasons,
  }) {
    return StudyBuddyMatch(
      profile: profile ?? this.profile.copyWith(),
      score: score ?? this.score,
      reasons: reasons ?? this.reasons.map((e0) => e0).toList(),
    );
  }
}
