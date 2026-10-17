//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cluster_hbi_request.g.dart';

/// ClusterHBIRequest
///
/// Properties:
/// * [datasetHash] - Unique hash of the dataset for caching
/// * [sequenceIdentityThreshold] - Sequence identity threshold for clustering
/// * [sequenceData] - Map of sequence_id -> sequence. Required on first call
/// * [targetData] - Map of sequence_id -> target label/value for evaluation
/// * [isNumeric] - True for continuous regression targets, False for classification
/// * [iterations] - Bootstrap iterations performed
@BuiltValue()
abstract class ClusterHBIRequest implements Built<ClusterHBIRequest, ClusterHBIRequestBuilder> {
  /// Unique hash of the dataset for caching
  @BuiltValueField(wireName: r'dataset_hash')
  String get datasetHash;

  /// Sequence identity threshold for clustering
  @BuiltValueField(wireName: r'sequence_identity_threshold')
  num? get sequenceIdentityThreshold;

  /// Map of sequence_id -> sequence. Required on first call
  @BuiltValueField(wireName: r'sequence_data')
  BuiltMap<String, String>? get sequenceData;

  /// Map of sequence_id -> target label/value for evaluation
  @BuiltValueField(wireName: r'target_data')
  BuiltMap<String, JsonObject?> get targetData;

  /// True for continuous regression targets, False for classification
  @BuiltValueField(wireName: r'is_numeric')
  bool? get isNumeric;

  /// Bootstrap iterations performed
  @BuiltValueField(wireName: r'iterations')
  int? get iterations;

  ClusterHBIRequest._();

  factory ClusterHBIRequest([void updates(ClusterHBIRequestBuilder b)]) = _$ClusterHBIRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClusterHBIRequestBuilder b) => b
      ..sequenceIdentityThreshold = 0.3
      ..isNumeric = false
      ..iterations = 30;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClusterHBIRequest> get serializer => _$ClusterHBIRequestSerializer();
}

class _$ClusterHBIRequestSerializer implements PrimitiveSerializer<ClusterHBIRequest> {
  @override
  final Iterable<Type> types = const [ClusterHBIRequest, _$ClusterHBIRequest];

  @override
  final String wireName = r'ClusterHBIRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClusterHBIRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dataset_hash';
    yield serializers.serialize(
      object.datasetHash,
      specifiedType: const FullType(String),
    );
    if (object.sequenceIdentityThreshold != null) {
      yield r'sequence_identity_threshold';
      yield serializers.serialize(
        object.sequenceIdentityThreshold,
        specifiedType: const FullType(num),
      );
    }
    if (object.sequenceData != null) {
      yield r'sequence_data';
      yield serializers.serialize(
        object.sequenceData,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    yield r'target_data';
    yield serializers.serialize(
      object.targetData,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    if (object.isNumeric != null) {
      yield r'is_numeric';
      yield serializers.serialize(
        object.isNumeric,
        specifiedType: const FullType(bool),
      );
    }
    if (object.iterations != null) {
      yield r'iterations';
      yield serializers.serialize(
        object.iterations,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClusterHBIRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClusterHBIRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dataset_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.datasetHash = valueDes;
          break;
        case r'sequence_identity_threshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.sequenceIdentityThreshold = valueDes;
          break;
        case r'sequence_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>?;
          if (valueDes == null) continue;
          result.sequenceData.replace(valueDes);
          break;
        case r'target_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.targetData.replace(valueDes);
          break;
        case r'is_numeric':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isNumeric = valueDes;
          break;
        case r'iterations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.iterations = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClusterHBIRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClusterHBIRequestBuilder();
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


