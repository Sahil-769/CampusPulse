/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:campus_pulse_server/src/generated/events/campus_event.dart'
    as _i57zskwf;
import 'package:campus_pulse_server/src/generated/events/study_buddy_match.dart'
    as _itfgoe9a;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'events/campus_event.dart' as _itswrjgw;
import 'events/duplicate_registration_exception.dart' as _i0lkavwt;
import 'events/event_not_found_exception.dart' as _ipg1rakb;
import 'events/event_registration.dart' as _iy7pigjs;
import 'events/invalid_request_exception.dart' as _i09y8p8s;
import 'events/study_buddy_match.dart' as _i71f7i92;
import 'events/study_buddy_profile.dart' as _if4mbfnw;
import 'greetings/greeting.dart' as _izw8z7ou;
export 'events/campus_event.dart';
export 'events/duplicate_registration_exception.dart';
export 'events/event_not_found_exception.dart';
export 'events/event_registration.dart';
export 'events/invalid_request_exception.dart';
export 'events/study_buddy_match.dart';
export 'events/study_buddy_profile.dart';
export 'greetings/greeting.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _itswrjgw.CampusEvent) {
      return _itswrjgw.CampusEvent.fromJson(data) as T;
    }
    if (t == _i0lkavwt.DuplicateRegistrationException) {
      return _i0lkavwt.DuplicateRegistrationException.fromJson(data) as T;
    }
    if (t == _ipg1rakb.EventNotFoundException) {
      return _ipg1rakb.EventNotFoundException.fromJson(data) as T;
    }
    if (t == _iy7pigjs.EventRegistration) {
      return _iy7pigjs.EventRegistration.fromJson(data) as T;
    }
    if (t == _i09y8p8s.InvalidRequestException) {
      return _i09y8p8s.InvalidRequestException.fromJson(data) as T;
    }
    if (t == _i71f7i92.StudyBuddyMatch) {
      return _i71f7i92.StudyBuddyMatch.fromJson(data) as T;
    }
    if (t == _if4mbfnw.StudyBuddyProfile) {
      return _if4mbfnw.StudyBuddyProfile.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _is.getType<_itswrjgw.CampusEvent?>()) {
      return (data != null ? _itswrjgw.CampusEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0lkavwt.DuplicateRegistrationException?>()) {
      return (data != null
              ? _i0lkavwt.DuplicateRegistrationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipg1rakb.EventNotFoundException?>()) {
      return (data != null
              ? _ipg1rakb.EventNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iy7pigjs.EventRegistration?>()) {
      return (data != null ? _iy7pigjs.EventRegistration.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i09y8p8s.InvalidRequestException?>()) {
      return (data != null
              ? _i09y8p8s.InvalidRequestException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i71f7i92.StudyBuddyMatch?>()) {
      return (data != null ? _i71f7i92.StudyBuddyMatch.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_if4mbfnw.StudyBuddyProfile?>()) {
      return (data != null ? _if4mbfnw.StudyBuddyProfile.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i57zskwf.CampusEvent>) {
      return (data as List)
              .map((e) => deserialize<_i57zskwf.CampusEvent>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_itfgoe9a.StudyBuddyMatch>) {
      return (data as List)
              .map((e) => deserialize<_itfgoe9a.StudyBuddyMatch>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _itswrjgw.CampusEvent => 'CampusEvent',
      _i0lkavwt.DuplicateRegistrationException =>
        'DuplicateRegistrationException',
      _ipg1rakb.EventNotFoundException => 'EventNotFoundException',
      _iy7pigjs.EventRegistration => 'EventRegistration',
      _i09y8p8s.InvalidRequestException => 'InvalidRequestException',
      _i71f7i92.StudyBuddyMatch => 'StudyBuddyMatch',
      _if4mbfnw.StudyBuddyProfile => 'StudyBuddyProfile',
      _izw8z7ou.Greeting => 'Greeting',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'campus_pulse.',
        '',
      );
    }

    switch (data) {
      case _itswrjgw.CampusEvent():
        return 'CampusEvent';
      case _i0lkavwt.DuplicateRegistrationException():
        return 'DuplicateRegistrationException';
      case _ipg1rakb.EventNotFoundException():
        return 'EventNotFoundException';
      case _iy7pigjs.EventRegistration():
        return 'EventRegistration';
      case _i09y8p8s.InvalidRequestException():
        return 'InvalidRequestException';
      case _i71f7i92.StudyBuddyMatch():
        return 'StudyBuddyMatch';
      case _if4mbfnw.StudyBuddyProfile():
        return 'StudyBuddyProfile';
      case _izw8z7ou.Greeting():
        return 'Greeting';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CampusEvent') {
      return deserialize<_itswrjgw.CampusEvent>(data['data']);
    }
    if (dataClassName == 'DuplicateRegistrationException') {
      return deserialize<_i0lkavwt.DuplicateRegistrationException>(
        data['data'],
      );
    }
    if (dataClassName == 'EventNotFoundException') {
      return deserialize<_ipg1rakb.EventNotFoundException>(data['data']);
    }
    if (dataClassName == 'EventRegistration') {
      return deserialize<_iy7pigjs.EventRegistration>(data['data']);
    }
    if (dataClassName == 'InvalidRequestException') {
      return deserialize<_i09y8p8s.InvalidRequestException>(data['data']);
    }
    if (dataClassName == 'StudyBuddyMatch') {
      return deserialize<_i71f7i92.StudyBuddyMatch>(data['data']);
    }
    if (dataClassName == 'StudyBuddyProfile') {
      return deserialize<_if4mbfnw.StudyBuddyProfile>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('campus_pulse', this);
    _iacs.Protocol().registerHostProtocol('campus_pulse', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'campus_pulse';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
