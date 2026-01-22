//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';

part 'config_verification_request.g.dart';

/// Request model for config verification
///
/// Properties:
/// * [configDict] - Biotrainer configuration
@BuiltValue()
abstract class ConfigVerificationRequest implements Built<ConfigVerificationRequest, ConfigVerificationRequestBuilder> {
  /// Biotrainer configuration
  @BuiltValueField(wireName: r'config_dict')
  BuiltMap<String, JsonObject?> get configDict;

  ConfigVerificationRequest._();

  factory ConfigVerificationRequest([void updates(ConfigVerificationRequestBuilder b)]) = _$ConfigVerificationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfigVerificationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfigVerificationRequest> get serializer => _$ConfigVerificationRequestSerializer();
}

class _$ConfigVerificationRequestSerializer implements PrimitiveSerializer<ConfigVerificationRequest> {
  @override
  final Iterable<Type> types = const [ConfigVerificationRequest, _$ConfigVerificationRequest];

  @override
  final String wireName = r'ConfigVerificationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfigVerificationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'config_dict';
    yield serializers.serialize(
      object.configDict,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfigVerificationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfigVerificationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'config_dict':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.configDict.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfigVerificationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfigVerificationRequestBuilder();
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

