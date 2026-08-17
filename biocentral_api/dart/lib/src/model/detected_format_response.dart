//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'detected_format_response.g.dart';

/// DetectedFormatResponse
///
/// Properties:
/// * [detectedFormat] 
@BuiltValue()
abstract class DetectedFormatResponse implements Built<DetectedFormatResponse, DetectedFormatResponseBuilder> {
  @BuiltValueField(wireName: r'detected_format')
  String get detectedFormat;

  DetectedFormatResponse._();

  factory DetectedFormatResponse([void updates(DetectedFormatResponseBuilder b)]) = _$DetectedFormatResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DetectedFormatResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DetectedFormatResponse> get serializer => _$DetectedFormatResponseSerializer();
}

class _$DetectedFormatResponseSerializer implements PrimitiveSerializer<DetectedFormatResponse> {
  @override
  final Iterable<Type> types = const [DetectedFormatResponse, _$DetectedFormatResponse];

  @override
  final String wireName = r'DetectedFormatResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DetectedFormatResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'detected_format';
    yield serializers.serialize(
      object.detectedFormat,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DetectedFormatResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DetectedFormatResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'detected_format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.detectedFormat = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DetectedFormatResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DetectedFormatResponseBuilder();
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

