//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plm_eval_validate_response.g.dart';

/// PLMEvalValidateResponse
///
/// Properties:
/// * [valid] - Whether the model is valid for PLM evaluation
/// * [error] 
@BuiltValue()
abstract class PLMEvalValidateResponse implements Built<PLMEvalValidateResponse, PLMEvalValidateResponseBuilder> {
  /// Whether the model is valid for PLM evaluation
  @BuiltValueField(wireName: r'valid')
  bool get valid;

  @BuiltValueField(wireName: r'error')
  String? get error;

  PLMEvalValidateResponse._();

  factory PLMEvalValidateResponse([void updates(PLMEvalValidateResponseBuilder b)]) = _$PLMEvalValidateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PLMEvalValidateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PLMEvalValidateResponse> get serializer => _$PLMEvalValidateResponseSerializer();
}

class _$PLMEvalValidateResponseSerializer implements PrimitiveSerializer<PLMEvalValidateResponse> {
  @override
  final Iterable<Type> types = const [PLMEvalValidateResponse, _$PLMEvalValidateResponse];

  @override
  final String wireName = r'PLMEvalValidateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PLMEvalValidateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'valid';
    yield serializers.serialize(
      object.valid,
      specifiedType: const FullType(bool),
    );
    yield r'error';
    yield object.error == null ? null : serializers.serialize(
      object.error,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PLMEvalValidateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PLMEvalValidateResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'valid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.valid = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.error = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PLMEvalValidateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PLMEvalValidateResponseBuilder();
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

