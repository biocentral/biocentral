//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'config_verification_response.g.dart';

/// Response model for config verification
///
/// Properties:
/// * [error] - Empty string if verification successful, error message otherwise
@BuiltValue()
abstract class ConfigVerificationResponse implements Built<ConfigVerificationResponse, ConfigVerificationResponseBuilder> {
  /// Empty string if verification successful, error message otherwise
  @BuiltValueField(wireName: r'error')
  String? get error;

  ConfigVerificationResponse._();

  factory ConfigVerificationResponse([void updates(ConfigVerificationResponseBuilder b)]) = _$ConfigVerificationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfigVerificationResponseBuilder b) => b
      ..error = '';

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfigVerificationResponse> get serializer => _$ConfigVerificationResponseSerializer();
}

class _$ConfigVerificationResponseSerializer implements PrimitiveSerializer<ConfigVerificationResponse> {
  @override
  final Iterable<Type> types = const [ConfigVerificationResponse, _$ConfigVerificationResponse];

  @override
  final String wireName = r'ConfigVerificationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfigVerificationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfigVerificationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfigVerificationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  ConfigVerificationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfigVerificationResponseBuilder();
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

