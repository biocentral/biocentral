//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/projections_metadata.dart';
import 'package:biocentral_api/src/model/projections_data.dart';
import 'package:biocentral_api/src/model/protein_annotations.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'projection_result.g.dart';

/// ProjectionResult
///
/// Properties:
/// * [proteinAnnotations] 
/// * [projectionsMetadata] 
/// * [projectionsData] 
@BuiltValue()
abstract class ProjectionResult implements Built<ProjectionResult, ProjectionResultBuilder> {
  @BuiltValueField(wireName: r'protein_annotations')
  ProteinAnnotations get proteinAnnotations;

  @BuiltValueField(wireName: r'projections_metadata')
  ProjectionsMetadata get projectionsMetadata;

  @BuiltValueField(wireName: r'projections_data')
  ProjectionsData get projectionsData;

  ProjectionResult._();

  factory ProjectionResult([void updates(ProjectionResultBuilder b)]) = _$ProjectionResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectionResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectionResult> get serializer => _$ProjectionResultSerializer();
}

class _$ProjectionResultSerializer implements PrimitiveSerializer<ProjectionResult> {
  @override
  final Iterable<Type> types = const [ProjectionResult, _$ProjectionResult];

  @override
  final String wireName = r'ProjectionResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectionResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'protein_annotations';
    yield serializers.serialize(
      object.proteinAnnotations,
      specifiedType: const FullType(ProteinAnnotations),
    );
    yield r'projections_metadata';
    yield serializers.serialize(
      object.projectionsMetadata,
      specifiedType: const FullType(ProjectionsMetadata),
    );
    yield r'projections_data';
    yield serializers.serialize(
      object.projectionsData,
      specifiedType: const FullType(ProjectionsData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectionResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectionResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'protein_annotations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProteinAnnotations),
          ) as ProteinAnnotations;
          result.proteinAnnotations.replace(valueDes);
          break;
        case r'projections_metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProjectionsMetadata),
          ) as ProjectionsMetadata;
          result.projectionsMetadata.replace(valueDes);
          break;
        case r'projections_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProjectionsData),
          ) as ProjectionsData;
          result.projectionsData.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProjectionResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectionResultBuilder();
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

