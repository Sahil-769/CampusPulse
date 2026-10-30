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
import 'package:serverpod/serverpod.dart' as _is;

abstract class DuplicateRegistrationException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  DuplicateRegistrationException._({required this.message});

  factory DuplicateRegistrationException({required String message}) =
      _DuplicateRegistrationExceptionImpl;

  factory DuplicateRegistrationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DuplicateRegistrationException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [DuplicateRegistrationException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DuplicateRegistrationException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DuplicateRegistrationException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DuplicateRegistrationException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'DuplicateRegistrationException(message: $message)';
  }
}

class _DuplicateRegistrationExceptionImpl
    extends DuplicateRegistrationException {
  _DuplicateRegistrationExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [DuplicateRegistrationException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DuplicateRegistrationException copyWith({String? message}) {
    return DuplicateRegistrationException(message: message ?? this.message);
  }
}
