//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/bootstrapped_metric.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cluster_hbi_response.g.dart';

/// ClusterHBIResponse
///
/// Properties:
/// * [metrics] - Bootstrapped evaluation metrics
/// * [clusters] - Calculated cluster dictionary (rep_id -> members)
@BuiltValue()
abstract class ClusterHBIResponse implements Built<ClusterHBIResponse, ClusterHBIResponseBuilder> {
  /// Bootstrapped evaluation metrics
  @BuiltValueField(wireName: r'metrics')
  BuiltList<BootstrappedMetric> get metrics;

  /// Calculated cluster dictionary (rep_id -> members)
  @BuiltValueField(wireName: r'clusters')
  BuiltMap<String, BuiltList<String>> get clusters;

  ClusterHBIResponse._();

  factory ClusterHBIResponse([void updates(ClusterHBIResponseBuilder b)]) = _$ClusterHBIResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClusterHBIResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClusterHBIResponse> get serializer => _$ClusterHBIResponseSerializer();
}

class _$ClusterHBIResponseSerializer implements PrimitiveSerializer<ClusterHBIResponse> {
  @override
  final Iterable<Type> types = const [ClusterHBIResponse, _$ClusterHBIResponse];

  @override
  final String wireName = r'ClusterHBIResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClusterHBIResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'metrics';
    yield serializers.serialize(
      object.metrics,
      specifiedType: const FullType(BuiltList, [FullType(BootstrappedMetric)]),
    );
    yield r'clusters';
    yield serializers.serialize(
      object.clusters,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(String)])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClusterHBIResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClusterHBIResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'metrics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BootstrappedMetric)]),
          ) as BuiltList<BootstrappedMetric>;
          result.metrics.replace(valueDes);
          break;
        case r'clusters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(String)])]),
          ) as BuiltMap<String, BuiltList<String>>;
          result.clusters.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClusterHBIResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClusterHBIResponseBuilder();
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


