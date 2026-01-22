//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';

part 'get_projection_config_response.g.dart';

/// Response model for projection configuration
///
/// Properties:
/// * [projectionConfig] - Projection configuration for each method
@BuiltValue()
abstract class GetProjectionConfigResponse implements Built<GetProjectionConfigResponse, GetProjectionConfigResponseBuilder> {
  /// Projection configuration for each method
  @BuiltValueField(wireName: r'projection_config')
  BuiltMap<String, BuiltList<JsonObject?>> get projectionConfig;

  GetProjectionConfigResponse._();

  factory GetProjectionConfigResponse([void updates(GetProjectionConfigResponseBuilder b)]) = _$GetProjectionConfigResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetProjectionConfigResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetProjectionConfigResponse> get serializer => _$GetProjectionConfigResponseSerializer();
}

class _$GetProjectionConfigResponseSerializer implements PrimitiveSerializer<GetProjectionConfigResponse> {
  @override
  final Iterable<Type> types = const [GetProjectionConfigResponse, _$GetProjectionConfigResponse];

  @override
  final String wireName = r'GetProjectionConfigResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetProjectionConfigResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'projection_config';
    yield serializers.serialize(
      object.projectionConfig,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltList, [FullType.nullable(JsonObject)])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetProjectionConfigResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetProjectionConfigResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'projection_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltList, [FullType.nullable(JsonObject)])]),
          ) as BuiltMap<String, BuiltList<JsonObject?>>;
          result.projectionConfig.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetProjectionConfigResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetProjectionConfigResponseBuilder();
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

