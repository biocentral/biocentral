//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/bootstrapped_metric.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'split_hbi_response.g.dart';

/// SplitHBIResponse
///
/// Properties:
/// * [metrics] - Bootstrapped evaluation metrics
/// * [numQueries] - Total number of query sequences provided
/// * [hitsFound] - Number of queries with homologous hits in train
/// * [evaluatedQueries] - Number of queries successfully evaluated
@BuiltValue()
abstract class SplitHBIResponse implements Built<SplitHBIResponse, SplitHBIResponseBuilder> {
  /// Bootstrapped evaluation metrics
  @BuiltValueField(wireName: r'metrics')
  BuiltList<BootstrappedMetric> get metrics;

  /// Total number of query sequences provided
  @BuiltValueField(wireName: r'num_queries')
  int get numQueries;

  /// Number of queries with homologous hits in train
  @BuiltValueField(wireName: r'hits_found')
  int get hitsFound;

  /// Number of queries successfully evaluated
  @BuiltValueField(wireName: r'evaluated_queries')
  int get evaluatedQueries;

  SplitHBIResponse._();

  factory SplitHBIResponse([void updates(SplitHBIResponseBuilder b)]) = _$SplitHBIResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SplitHBIResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SplitHBIResponse> get serializer => _$SplitHBIResponseSerializer();
}

class _$SplitHBIResponseSerializer implements PrimitiveSerializer<SplitHBIResponse> {
  @override
  final Iterable<Type> types = const [SplitHBIResponse, _$SplitHBIResponse];

  @override
  final String wireName = r'SplitHBIResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SplitHBIResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'metrics';
    yield serializers.serialize(
      object.metrics,
      specifiedType: const FullType(BuiltList, [FullType(BootstrappedMetric)]),
    );
    yield r'num_queries';
    yield serializers.serialize(
      object.numQueries,
      specifiedType: const FullType(int),
    );
    yield r'hits_found';
    yield serializers.serialize(
      object.hitsFound,
      specifiedType: const FullType(int),
    );
    yield r'evaluated_queries';
    yield serializers.serialize(
      object.evaluatedQueries,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SplitHBIResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SplitHBIResponseBuilder result,
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
        case r'num_queries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.numQueries = valueDes;
          break;
        case r'hits_found':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hitsFound = valueDes;
          break;
        case r'evaluated_queries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.evaluatedQueries = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SplitHBIResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SplitHBIResponseBuilder();
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


