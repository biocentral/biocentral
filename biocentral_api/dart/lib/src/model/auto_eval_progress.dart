//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_eval_progress.g.dart';

/// AutoEvalProgress
///
/// Properties:
/// * [completedTasks] 
/// * [totalTasks] 
/// * [currentFrameworkName] 
/// * [currentTaskName] 
/// * [finalReport] 
@BuiltValue()
abstract class AutoEvalProgress implements Built<AutoEvalProgress, AutoEvalProgressBuilder> {
  @BuiltValueField(wireName: r'completed_tasks')
  int get completedTasks;

  @BuiltValueField(wireName: r'total_tasks')
  int get totalTasks;

  @BuiltValueField(wireName: r'current_framework_name')
  String get currentFrameworkName;

  @BuiltValueField(wireName: r'current_task_name')
  String get currentTaskName;

  @BuiltValueField(wireName: r'final_report')
  BuiltMap<String, JsonObject?>? get finalReport;

  AutoEvalProgress._();

  factory AutoEvalProgress([void updates(AutoEvalProgressBuilder b)]) = _$AutoEvalProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoEvalProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoEvalProgress> get serializer => _$AutoEvalProgressSerializer();
}

class _$AutoEvalProgressSerializer implements PrimitiveSerializer<AutoEvalProgress> {
  @override
  final Iterable<Type> types = const [AutoEvalProgress, _$AutoEvalProgress];

  @override
  final String wireName = r'AutoEvalProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoEvalProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'completed_tasks';
    yield serializers.serialize(
      object.completedTasks,
      specifiedType: const FullType(int),
    );
    yield r'total_tasks';
    yield serializers.serialize(
      object.totalTasks,
      specifiedType: const FullType(int),
    );
    yield r'current_framework_name';
    yield serializers.serialize(
      object.currentFrameworkName,
      specifiedType: const FullType(String),
    );
    yield r'current_task_name';
    yield serializers.serialize(
      object.currentTaskName,
      specifiedType: const FullType(String),
    );
    if (object.finalReport != null) {
      yield r'final_report';
      yield serializers.serialize(
        object.finalReport,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoEvalProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AutoEvalProgressBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'completed_tasks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedTasks = valueDes;
          break;
        case r'total_tasks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalTasks = valueDes;
          break;
        case r'current_framework_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currentFrameworkName = valueDes;
          break;
        case r'current_task_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currentTaskName = valueDes;
          break;
        case r'final_report':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.finalReport.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoEvalProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoEvalProgressBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

