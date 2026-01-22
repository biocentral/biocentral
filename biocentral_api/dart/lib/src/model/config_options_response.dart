//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';

part 'config_options_response.g.dart';

/// ConfigOptionsResponse
///
/// Properties:
/// * [options] - List of configuration option dictionaries
@BuiltValue()
abstract class ConfigOptionsResponse implements Built<ConfigOptionsResponse, ConfigOptionsResponseBuilder> {
  /// List of configuration option dictionaries
  @BuiltValueField(wireName: r'options')
  BuiltList<JsonObject?> get options;

  ConfigOptionsResponse._();

  factory ConfigOptionsResponse([void updates(ConfigOptionsResponseBuilder b)]) = _$ConfigOptionsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfigOptionsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfigOptionsResponse> get serializer => _$ConfigOptionsResponseSerializer();
}

class _$ConfigOptionsResponseSerializer implements PrimitiveSerializer<ConfigOptionsResponse> {
  @override
  final Iterable<Type> types = const [ConfigOptionsResponse, _$ConfigOptionsResponse];

  @override
  final String wireName = r'ConfigOptionsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfigOptionsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'options';
    yield serializers.serialize(
      object.options,
      specifiedType: const FullType(BuiltList, [FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfigOptionsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfigOptionsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'options':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>;
          result.options.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfigOptionsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfigOptionsResponseBuilder();
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

