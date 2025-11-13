//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'projection_request.g.dart';

/// Request model for projection
///
/// Properties:
/// * [sequenceData] - Sequence data to embed (seq_id -> sequence)
/// * [method] - Projection method to use
/// * [config] - Projection configuration
/// * [embedderName] - Name of the embedder model
@BuiltValue()
abstract class ProjectionRequest implements Built<ProjectionRequest, ProjectionRequestBuilder> {
  /// Sequence data to embed (seq_id -> sequence)
  @BuiltValueField(wireName: r'sequence_data')
  BuiltMap<String, String> get sequenceData;

  /// Projection method to use
  @BuiltValueField(wireName: r'method')
  String get method;

  /// Projection configuration
  @BuiltValueField(wireName: r'config')
  BuiltMap<String, JsonObject?> get config;

  /// Name of the embedder model
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  ProjectionRequest._();

  factory ProjectionRequest([void updates(ProjectionRequestBuilder b)]) = _$ProjectionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectionRequest> get serializer => _$ProjectionRequestSerializer();
}

class _$ProjectionRequestSerializer implements PrimitiveSerializer<ProjectionRequest> {
  @override
  final Iterable<Type> types = const [ProjectionRequest, _$ProjectionRequest];

  @override
  final String wireName = r'ProjectionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sequence_data';
    yield serializers.serialize(
      object.sequenceData,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(String),
    );
    yield r'config';
    yield serializers.serialize(
      object.config,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'embedder_name';
    yield serializers.serialize(
      object.embedderName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectionRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sequence_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.sequenceData.replace(valueDes);
          break;
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.method = valueDes;
          break;
        case r'config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.config.replace(valueDes);
          break;
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedderName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProjectionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectionRequestBuilder();
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

