//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'projections_data.g.dart';

/// ProjectionsData
///
/// Properties:
/// * [projectionName]
/// * [identifier]
/// * [x]
/// * [y]
/// * [z]
@BuiltValue()
abstract class ProjectionsData implements Built<ProjectionsData, ProjectionsDataBuilder> {
  @BuiltValueField(wireName: r'projection_name')
  BuiltList<String> get projectionName;

  @BuiltValueField(wireName: r'identifier')
  BuiltList<String> get identifier;

  @BuiltValueField(wireName: r'x')
  BuiltList<num> get x;

  @BuiltValueField(wireName: r'y')
  BuiltList<num> get y;

  @BuiltValueField(wireName: r'z')
  BuiltList<num?> get z;

  ProjectionsData._();

  factory ProjectionsData([void updates(ProjectionsDataBuilder b)]) = _$ProjectionsData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectionsDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectionsData> get serializer => _$ProjectionsDataSerializer();
}

class _$ProjectionsDataSerializer implements PrimitiveSerializer<ProjectionsData> {
  @override
  final Iterable<Type> types = const [ProjectionsData, _$ProjectionsData];

  @override
  final String wireName = r'ProjectionsData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectionsData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'projection_name';
    yield serializers.serialize(
      object.projectionName,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'identifier';
    yield serializers.serialize(
      object.identifier,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'x';
    yield serializers.serialize(
      object.x,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
    yield r'y';
    yield serializers.serialize(
      object.y,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
    yield r'z';
    yield serializers.serialize(
      object.z,
      specifiedType: const FullType(BuiltList, [FullType.nullable(num)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectionsData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectionsDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'projection_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.projectionName.replace(valueDes);
          break;
        case r'identifier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.identifier.replace(valueDes);
          break;
        case r'x':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.x.replace(valueDes);
          break;
        case r'y':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.y.replace(valueDes);
          break;
        case r'z':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType.nullable(num)]),
          ) as BuiltList<num?>;
          result.z.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProjectionsData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectionsDataBuilder();
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
