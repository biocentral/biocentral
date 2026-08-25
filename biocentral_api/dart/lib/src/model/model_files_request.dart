//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model_files_request.g.dart';

/// ModelFilesRequest
///
/// Properties:
/// * [modelHash] - Hash identifier for the trained model
@BuiltValue()
abstract class ModelFilesRequest implements Built<ModelFilesRequest, ModelFilesRequestBuilder> {
  /// Hash identifier for the trained model
  @BuiltValueField(wireName: r'model_hash')
  String get modelHash;

  ModelFilesRequest._();

  factory ModelFilesRequest([void updates(ModelFilesRequestBuilder b)]) = _$ModelFilesRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModelFilesRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModelFilesRequest> get serializer => _$ModelFilesRequestSerializer();
}

class _$ModelFilesRequestSerializer implements PrimitiveSerializer<ModelFilesRequest> {
  @override
  final Iterable<Type> types = const [ModelFilesRequest, _$ModelFilesRequest];

  @override
  final String wireName = r'ModelFilesRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModelFilesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'model_hash';
    yield serializers.serialize(
      object.modelHash,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ModelFilesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModelFilesRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'model_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelHash = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModelFilesRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModelFilesRequestBuilder();
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

