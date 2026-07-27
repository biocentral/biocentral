//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_detect_format_request.g.dart';

/// AutoDetectFormatRequest
///
/// Properties:
/// * [header] 
@BuiltValue()
abstract class AutoDetectFormatRequest implements Built<AutoDetectFormatRequest, AutoDetectFormatRequestBuilder> {
  @BuiltValueField(wireName: r'header')
  String get header;

  AutoDetectFormatRequest._();

  factory AutoDetectFormatRequest([void updates(AutoDetectFormatRequestBuilder b)]) = _$AutoDetectFormatRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoDetectFormatRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoDetectFormatRequest> get serializer => _$AutoDetectFormatRequestSerializer();
}

class _$AutoDetectFormatRequestSerializer implements PrimitiveSerializer<AutoDetectFormatRequest> {
  @override
  final Iterable<Type> types = const [AutoDetectFormatRequest, _$AutoDetectFormatRequest];

  @override
  final String wireName = r'AutoDetectFormatRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoDetectFormatRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'header';
    yield serializers.serialize(
      object.header,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoDetectFormatRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AutoDetectFormatRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'header':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.header = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoDetectFormatRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoDetectFormatRequestBuilder();
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

