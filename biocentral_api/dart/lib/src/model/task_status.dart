//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'task_status.g.dart';

class TaskStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const TaskStatus PENDING = _$PENDING;
  @BuiltValueEnumConst(wireName: r'RUNNING')
  static const TaskStatus RUNNING = _$RUNNING;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const TaskStatus FINISHED = _$FINISHED;
  @BuiltValueEnumConst(wireName: r'FAILED')
  static const TaskStatus FAILED = _$FAILED;

  static Serializer<TaskStatus> get serializer => _$taskStatusSerializer;

  const TaskStatus._(String name): super(name);

  static BuiltSet<TaskStatus> get values => _$values;
  static TaskStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class TaskStatusMixin = Object with _$TaskStatusMixin;

