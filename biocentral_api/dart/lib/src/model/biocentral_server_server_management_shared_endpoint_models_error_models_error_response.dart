//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biocentral_server_server_management_shared_endpoint_models_error_models_error_response.g.dart';

/// BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
///
/// Properties:
/// * [error] 
/// * [errorType] 
/// * [details] 
/// * [errorCode] 
@BuiltValue()
abstract class BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse implements Built<BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse, BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder> {
  @BuiltValueField(wireName: r'error')
  String get error;

  @BuiltValueField(wireName: r'error_type')
  String get errorType;

  @BuiltValueField(wireName: r'details')
  String? get details;

  @BuiltValueField(wireName: r'error_code')
  int? get errorCode;

  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse._();

  factory BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse([void updates(BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder b)]) = _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse> get serializer => _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseSerializer();
}

class _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseSerializer implements PrimitiveSerializer<BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse> {
  @override
  final Iterable<Type> types = const [BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse, _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse];

  @override
  final String wireName = r'BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(String),
    );
    yield r'error_type';
    yield serializers.serialize(
      object.errorType,
      specifiedType: const FullType(String),
    );
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.errorCode != null) {
      yield r'error_code';
      yield serializers.serialize(
        object.errorCode,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder result,
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
        case r'error_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.errorType = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.details = valueDes;
          break;
        case r'error_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.errorCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder();
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

