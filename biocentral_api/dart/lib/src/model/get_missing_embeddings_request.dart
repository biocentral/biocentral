//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_missing_embeddings_request.g.dart';

/// Request model for checking missing embeddings
///
/// Properties:
/// * [sequences] - JSON string containing sequence data
/// * [embedderName] - Name of the embedder model
/// * [reduced] - Whether to check for reduced embeddings
@BuiltValue()
abstract class GetMissingEmbeddingsRequest implements Built<GetMissingEmbeddingsRequest, GetMissingEmbeddingsRequestBuilder> {
  /// JSON string containing sequence data
  @BuiltValueField(wireName: r'sequences')
  String get sequences;

  /// Name of the embedder model
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  /// Whether to check for reduced embeddings
  @BuiltValueField(wireName: r'reduced')
  bool get reduced;

  GetMissingEmbeddingsRequest._();

  factory GetMissingEmbeddingsRequest([void updates(GetMissingEmbeddingsRequestBuilder b)]) = _$GetMissingEmbeddingsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetMissingEmbeddingsRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetMissingEmbeddingsRequest> get serializer => _$GetMissingEmbeddingsRequestSerializer();
}

class _$GetMissingEmbeddingsRequestSerializer implements PrimitiveSerializer<GetMissingEmbeddingsRequest> {
  @override
  final Iterable<Type> types = const [GetMissingEmbeddingsRequest, _$GetMissingEmbeddingsRequest];

  @override
  final String wireName = r'GetMissingEmbeddingsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetMissingEmbeddingsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sequences';
    yield serializers.serialize(
      object.sequences,
      specifiedType: const FullType(String),
    );
    yield r'embedder_name';
    yield serializers.serialize(
      object.embedderName,
      specifiedType: const FullType(String),
    );
    yield r'reduced';
    yield serializers.serialize(
      object.reduced,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetMissingEmbeddingsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetMissingEmbeddingsRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sequences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sequences = valueDes;
          break;
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedderName = valueDes;
          break;
        case r'reduced':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.reduced = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetMissingEmbeddingsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetMissingEmbeddingsRequestBuilder();
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

