//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plm_eval_validate_request.g.dart';

/// PLMEvalValidateRequest
///
/// Properties:
/// * [modelId] - Huggingface model identifier
@BuiltValue()
abstract class PLMEvalValidateRequest implements Built<PLMEvalValidateRequest, PLMEvalValidateRequestBuilder> {
  /// Huggingface model identifier
  @BuiltValueField(wireName: r'model_id')
  String get modelId;

  PLMEvalValidateRequest._();

  factory PLMEvalValidateRequest([void updates(PLMEvalValidateRequestBuilder b)]) = _$PLMEvalValidateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PLMEvalValidateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PLMEvalValidateRequest> get serializer => _$PLMEvalValidateRequestSerializer();
}

class _$PLMEvalValidateRequestSerializer implements PrimitiveSerializer<PLMEvalValidateRequest> {
  @override
  final Iterable<Type> types = const [PLMEvalValidateRequest, _$PLMEvalValidateRequest];

  @override
  final String wireName = r'PLMEvalValidateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PLMEvalValidateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'model_id';
    yield serializers.serialize(
      object.modelId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PLMEvalValidateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PLMEvalValidateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'model_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PLMEvalValidateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PLMEvalValidateRequestBuilder();
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

