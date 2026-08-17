//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'clustering_request.g.dart';

/// ClusteringRequest
///
/// Properties:
/// * [sequenceData] - Dictionary mapping sequence IDs to their amino acid sequence strings
/// * [sequenceIdentityThreshold] - Sequence identity threshold for clustering (between 0.0 and 1.0)
@BuiltValue()
abstract class ClusteringRequest implements Built<ClusteringRequest, ClusteringRequestBuilder> {
  /// Dictionary mapping sequence IDs to their amino acid sequence strings
  @BuiltValueField(wireName: r'sequence_data')
  BuiltMap<String, String> get sequenceData;

  /// Sequence identity threshold for clustering (between 0.0 and 1.0)
  @BuiltValueField(wireName: r'sequence_identity_threshold')
  num? get sequenceIdentityThreshold;

  ClusteringRequest._();

  factory ClusteringRequest([void updates(ClusteringRequestBuilder b)]) = _$ClusteringRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClusteringRequestBuilder b) => b
      ..sequenceIdentityThreshold = 0.3;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClusteringRequest> get serializer => _$ClusteringRequestSerializer();
}

class _$ClusteringRequestSerializer implements PrimitiveSerializer<ClusteringRequest> {
  @override
  final Iterable<Type> types = const [ClusteringRequest, _$ClusteringRequest];

  @override
  final String wireName = r'ClusteringRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClusteringRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sequence_data';
    yield serializers.serialize(
      object.sequenceData,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    if (object.sequenceIdentityThreshold != null) {
      yield r'sequence_identity_threshold';
      yield serializers.serialize(
        object.sequenceIdentityThreshold,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClusteringRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClusteringRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sequence_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.sequenceData.replace(valueDes);
          break;
        case r'sequence_identity_threshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.sequenceIdentityThreshold = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClusteringRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClusteringRequestBuilder();
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

