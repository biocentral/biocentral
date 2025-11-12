//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_embeddings_request.g.dart';

/// Request model for adding embeddings
///
/// Properties:
/// * [h5Bytes] - Base64 encoded HDF5 file containing embeddings
/// * [sequences] - JSON string containing sequence data
/// * [embedderName] - Name of the embedder model
/// * [reduced] - Whether these are reduced embeddings
@BuiltValue()
abstract class AddEmbeddingsRequest implements Built<AddEmbeddingsRequest, AddEmbeddingsRequestBuilder> {
  /// Base64 encoded HDF5 file containing embeddings
  @BuiltValueField(wireName: r'h5_bytes')
  String get h5Bytes;

  /// JSON string containing sequence data
  @BuiltValueField(wireName: r'sequences')
  String get sequences;

  /// Name of the embedder model
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  /// Whether these are reduced embeddings
  @BuiltValueField(wireName: r'reduced')
  bool get reduced;

  AddEmbeddingsRequest._();

  factory AddEmbeddingsRequest([void updates(AddEmbeddingsRequestBuilder b)]) = _$AddEmbeddingsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddEmbeddingsRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddEmbeddingsRequest> get serializer => _$AddEmbeddingsRequestSerializer();
}

class _$AddEmbeddingsRequestSerializer implements PrimitiveSerializer<AddEmbeddingsRequest> {
  @override
  final Iterable<Type> types = const [AddEmbeddingsRequest, _$AddEmbeddingsRequest];

  @override
  final String wireName = r'AddEmbeddingsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddEmbeddingsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'h5_bytes';
    yield serializers.serialize(
      object.h5Bytes,
      specifiedType: const FullType(String),
    );
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
    AddEmbeddingsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddEmbeddingsRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'h5_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.h5Bytes = valueDes;
          break;
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
  AddEmbeddingsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddEmbeddingsRequestBuilder();
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

