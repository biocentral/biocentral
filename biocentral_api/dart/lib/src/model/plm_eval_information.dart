//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/plm_eval_task_information.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plm_eval_information.g.dart';

/// PLMEvalInformation
///
/// Properties:
/// * [nTasks] - Number of tasks
/// * [tasks] - List of tasks
@BuiltValue()
abstract class PLMEvalInformation implements Built<PLMEvalInformation, PLMEvalInformationBuilder> {
  /// Number of tasks
  @BuiltValueField(wireName: r'n_tasks')
  int get nTasks;

  /// List of tasks
  @BuiltValueField(wireName: r'tasks')
  BuiltList<PLMEvalTaskInformation> get tasks;

  PLMEvalInformation._();

  factory PLMEvalInformation([void updates(PLMEvalInformationBuilder b)]) = _$PLMEvalInformation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PLMEvalInformationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PLMEvalInformation> get serializer => _$PLMEvalInformationSerializer();
}

class _$PLMEvalInformationSerializer implements PrimitiveSerializer<PLMEvalInformation> {
  @override
  final Iterable<Type> types = const [PLMEvalInformation, _$PLMEvalInformation];

  @override
  final String wireName = r'PLMEvalInformation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PLMEvalInformation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'n_tasks';
    yield serializers.serialize(
      object.nTasks,
      specifiedType: const FullType(int),
    );
    yield r'tasks';
    yield serializers.serialize(
      object.tasks,
      specifiedType: const FullType(BuiltList, [FullType(PLMEvalTaskInformation)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PLMEvalInformation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PLMEvalInformationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'n_tasks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.nTasks = valueDes;
          break;
        case r'tasks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PLMEvalTaskInformation)]),
          ) as BuiltList<PLMEvalTaskInformation>;
          result.tasks.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PLMEvalInformation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PLMEvalInformationBuilder();
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

