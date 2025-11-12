//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_missing_embeddings_response.g.dart';

/// Response model for missing embeddings check
///
/// Properties:
/// * [missing] - List of sequence IDs that are missing embeddings
@BuiltValue()
abstract class GetMissingEmbeddingsResponse implements Built<GetMissingEmbeddingsResponse, GetMissingEmbeddingsResponseBuilder> {
  /// List of sequence IDs that are missing embeddings
  @BuiltValueField(wireName: r'missing')
  BuiltList<String> get missing;

  GetMissingEmbeddingsResponse._();

  factory GetMissingEmbeddingsResponse([void updates(GetMissingEmbeddingsResponseBuilder b)]) = _$GetMissingEmbeddingsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetMissingEmbeddingsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetMissingEmbeddingsResponse> get serializer => _$GetMissingEmbeddingsResponseSerializer();
}

class _$GetMissingEmbeddingsResponseSerializer implements PrimitiveSerializer<GetMissingEmbeddingsResponse> {
  @override
  final Iterable<Type> types = const [GetMissingEmbeddingsResponse, _$GetMissingEmbeddingsResponse];

  @override
  final String wireName = r'GetMissingEmbeddingsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetMissingEmbeddingsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'missing';
    yield serializers.serialize(
      object.missing,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetMissingEmbeddingsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetMissingEmbeddingsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'missing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.missing.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetMissingEmbeddingsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetMissingEmbeddingsResponseBuilder();
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

