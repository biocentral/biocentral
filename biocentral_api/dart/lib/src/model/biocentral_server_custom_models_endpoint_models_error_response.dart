//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biocentral_server_custom_models_endpoint_models_error_response.g.dart';

/// Standard error response model
///
/// Properties:
/// * [error] 
/// * [detail] 
@BuiltValue()
abstract class BiocentralServerCustomModelsEndpointModelsErrorResponse implements Built<BiocentralServerCustomModelsEndpointModelsErrorResponse, BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder> {
  @BuiltValueField(wireName: r'error')
  String get error;

  @BuiltValueField(wireName: r'detail')
  String? get detail;

  BiocentralServerCustomModelsEndpointModelsErrorResponse._();

  factory BiocentralServerCustomModelsEndpointModelsErrorResponse([void updates(BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder b)]) = _$BiocentralServerCustomModelsEndpointModelsErrorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiocentralServerCustomModelsEndpointModelsErrorResponse> get serializer => _$BiocentralServerCustomModelsEndpointModelsErrorResponseSerializer();
}

class _$BiocentralServerCustomModelsEndpointModelsErrorResponseSerializer implements PrimitiveSerializer<BiocentralServerCustomModelsEndpointModelsErrorResponse> {
  @override
  final Iterable<Type> types = const [BiocentralServerCustomModelsEndpointModelsErrorResponse, _$BiocentralServerCustomModelsEndpointModelsErrorResponse];

  @override
  final String wireName = r'BiocentralServerCustomModelsEndpointModelsErrorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiocentralServerCustomModelsEndpointModelsErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(String),
    );
    if (object.detail != null) {
      yield r'detail';
      yield serializers.serialize(
        object.detail,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiocentralServerCustomModelsEndpointModelsErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder result,
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
        case r'detail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.detail = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiocentralServerCustomModelsEndpointModelsErrorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder();
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

