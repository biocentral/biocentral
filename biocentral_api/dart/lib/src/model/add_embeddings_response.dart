//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_embeddings_response.g.dart';

/// AddEmbeddingsResponse
///
/// Properties:
/// * [success] - Bool flag indicating whether embeddings were added successfully
@BuiltValue()
abstract class AddEmbeddingsResponse implements Built<AddEmbeddingsResponse, AddEmbeddingsResponseBuilder> {
  /// Bool flag indicating whether embeddings were added successfully
  @BuiltValueField(wireName: r'success')
  bool get success;

  AddEmbeddingsResponse._();

  factory AddEmbeddingsResponse([void updates(AddEmbeddingsResponseBuilder b)]) = _$AddEmbeddingsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddEmbeddingsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddEmbeddingsResponse> get serializer => _$AddEmbeddingsResponseSerializer();
}

class _$AddEmbeddingsResponseSerializer implements PrimitiveSerializer<AddEmbeddingsResponse> {
  @override
  final Iterable<Type> types = const [AddEmbeddingsResponse, _$AddEmbeddingsResponse];

  @override
  final String wireName = r'AddEmbeddingsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddEmbeddingsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'success';
    yield serializers.serialize(
      object.success,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AddEmbeddingsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddEmbeddingsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.success = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AddEmbeddingsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddEmbeddingsResponseBuilder();
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

