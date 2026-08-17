//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/model_metadata.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model_metadata_response.g.dart';

/// ModelMetadataResponse
///
/// Properties:
/// * [metadata] - List of model metadata
@BuiltValue()
abstract class ModelMetadataResponse implements Built<ModelMetadataResponse, ModelMetadataResponseBuilder> {
  /// List of model metadata
  @BuiltValueField(wireName: r'metadata')
  BuiltList<ModelMetadata> get metadata;

  ModelMetadataResponse._();

  factory ModelMetadataResponse([void updates(ModelMetadataResponseBuilder b)]) = _$ModelMetadataResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModelMetadataResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModelMetadataResponse> get serializer => _$ModelMetadataResponseSerializer();
}

class _$ModelMetadataResponseSerializer implements PrimitiveSerializer<ModelMetadataResponse> {
  @override
  final Iterable<Type> types = const [ModelMetadataResponse, _$ModelMetadataResponse];

  @override
  final String wireName = r'ModelMetadataResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModelMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'metadata';
    yield serializers.serialize(
      object.metadata,
      specifiedType: const FullType(BuiltList, [FullType(ModelMetadata)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ModelMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModelMetadataResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ModelMetadata)]),
          ) as BuiltList<ModelMetadata>;
          result.metadata.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModelMetadataResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModelMetadataResponseBuilder();
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

