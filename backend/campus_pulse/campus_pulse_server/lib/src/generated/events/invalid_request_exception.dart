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

abstract class InvalidRequestException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  InvalidRequestException._({required this.message});

  factory InvalidRequestException({required String message}) =
      _InvalidRequestExceptionImpl;

  factory InvalidRequestException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return InvalidRequestException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [InvalidRequestException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InvalidRequestException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InvalidRequestException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InvalidRequestException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'InvalidRequestException(message: $message)';
  }
}

class _InvalidRequestExceptionImpl extends InvalidRequestException {
  _InvalidRequestExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [InvalidRequestException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InvalidRequestException copyWith({String? message}) {
    return InvalidRequestException(message: message ?? this.message);
  }
}
