//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plm_eval_task_information.g.dart';

/// PLMEvalTaskInformation
///
/// Properties:
/// * [name] - Name of the task
/// * [description] - Description of the task
@BuiltValue()
abstract class PLMEvalTaskInformation implements Built<PLMEvalTaskInformation, PLMEvalTaskInformationBuilder> {
  /// Name of the task
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Description of the task
  @BuiltValueField(wireName: r'description')
  String get description;

  PLMEvalTaskInformation._();

  factory PLMEvalTaskInformation([void updates(PLMEvalTaskInformationBuilder b)]) = _$PLMEvalTaskInformation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PLMEvalTaskInformationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PLMEvalTaskInformation> get serializer => _$PLMEvalTaskInformationSerializer();
}

class _$PLMEvalTaskInformationSerializer implements PrimitiveSerializer<PLMEvalTaskInformation> {
  @override
  final Iterable<Type> types = const [PLMEvalTaskInformation, _$PLMEvalTaskInformation];

  @override
  final String wireName = r'PLMEvalTaskInformation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PLMEvalTaskInformation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PLMEvalTaskInformation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PLMEvalTaskInformationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PLMEvalTaskInformation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PLMEvalTaskInformationBuilder();
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

