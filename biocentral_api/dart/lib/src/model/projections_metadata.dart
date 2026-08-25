//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'projections_metadata.g.dart';

/// ProjectionsMetadata
///
/// Properties:
/// * [projectionName] 
/// * [dimensions] 
/// * [infoJson] 
@BuiltValue()
abstract class ProjectionsMetadata implements Built<ProjectionsMetadata, ProjectionsMetadataBuilder> {
  @BuiltValueField(wireName: r'projection_name')
  BuiltList<String> get projectionName;

  @BuiltValueField(wireName: r'dimensions')
  BuiltList<int> get dimensions;

  @BuiltValueField(wireName: r'info_json')
  BuiltList<String> get infoJson;

  ProjectionsMetadata._();

  factory ProjectionsMetadata([void updates(ProjectionsMetadataBuilder b)]) = _$ProjectionsMetadata;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectionsMetadataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectionsMetadata> get serializer => _$ProjectionsMetadataSerializer();
}

class _$ProjectionsMetadataSerializer implements PrimitiveSerializer<ProjectionsMetadata> {
  @override
  final Iterable<Type> types = const [ProjectionsMetadata, _$ProjectionsMetadata];

  @override
  final String wireName = r'ProjectionsMetadata';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectionsMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'projection_name';
    yield serializers.serialize(
      object.projectionName,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'dimensions';
    yield serializers.serialize(
      object.dimensions,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
    yield r'info_json';
    yield serializers.serialize(
      object.infoJson,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectionsMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectionsMetadataBuilder result,
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
        case r'dimensions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.dimensions.replace(valueDes);
          break;
        case r'info_json':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.infoJson.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProjectionsMetadata deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectionsMetadataBuilder();
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

