//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/biocentral_service_stats.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'service_stats_response.g.dart';

/// ServiceStatsResponse
///
/// Properties:
/// * [serviceStats] - Service statistics
@BuiltValue()
abstract class ServiceStatsResponse implements Built<ServiceStatsResponse, ServiceStatsResponseBuilder> {
  /// Service statistics
  @BuiltValueField(wireName: r'service_stats')
  BiocentralServiceStats get serviceStats;

  ServiceStatsResponse._();

  factory ServiceStatsResponse([void updates(ServiceStatsResponseBuilder b)]) = _$ServiceStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServiceStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServiceStatsResponse> get serializer => _$ServiceStatsResponseSerializer();
}

class _$ServiceStatsResponseSerializer implements PrimitiveSerializer<ServiceStatsResponse> {
  @override
  final Iterable<Type> types = const [ServiceStatsResponse, _$ServiceStatsResponse];

  @override
  final String wireName = r'ServiceStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServiceStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'service_stats';
    yield serializers.serialize(
      object.serviceStats,
      specifiedType: const FullType(BiocentralServiceStats),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ServiceStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServiceStatsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'service_stats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BiocentralServiceStats),
          ) as BiocentralServiceStats;
          result.serviceStats.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ServiceStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServiceStatsResponseBuilder();
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

