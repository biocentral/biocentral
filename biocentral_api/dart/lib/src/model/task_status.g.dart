// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TaskStatus _$PENDING = const TaskStatus._('PENDING');
const TaskStatus _$RUNNING = const TaskStatus._('RUNNING');
const TaskStatus _$FINISHED = const TaskStatus._('FINISHED');
const TaskStatus _$FAILED = const TaskStatus._('FAILED');

TaskStatus _$valueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$PENDING;
    case 'RUNNING':
      return _$RUNNING;
    case 'FINISHED':
      return _$FINISHED;
    case 'FAILED':
      return _$FAILED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TaskStatus> _$values = BuiltSet<TaskStatus>(const <TaskStatus>[
  _$PENDING,
  _$RUNNING,
  _$FINISHED,
  _$FAILED,
]);

class _$TaskStatusMeta {
  const _$TaskStatusMeta();
  TaskStatus get PENDING => _$PENDING;
  TaskStatus get RUNNING => _$RUNNING;
  TaskStatus get FINISHED => _$FINISHED;
  TaskStatus get FAILED => _$FAILED;
  TaskStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<TaskStatus> get values => _$values;
}

mixin _$TaskStatusMixin {
  // ignore: non_constant_identifier_names
  _$TaskStatusMeta get TaskStatus => const _$TaskStatusMeta();
}

Serializer<TaskStatus> _$taskStatusSerializer = _$TaskStatusSerializer();

class _$TaskStatusSerializer implements PrimitiveSerializer<TaskStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'RUNNING': 'RUNNING',
    'FINISHED': 'FINISHED',
    'FAILED': 'FAILED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'RUNNING': 'RUNNING',
    'FINISHED': 'FINISHED',
    'FAILED': 'FAILED',
  };

  @override
  final Iterable<Type> types = const <Type>[TaskStatus];
  @override
  final String wireName = 'TaskStatus';

  @override
  Object serialize(Serializers serializers, TaskStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TaskStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TaskStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
