//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'split_hbi_request.g.dart';

/// SplitHBIRequest
///
/// Properties:
/// * [trainSeqs] - Target database sequences (train split)
/// * [querySeqs] - Query database sequences to evaluate (test/val split)
/// * [trainLabels] - Ground truth annotations for train sequences
/// * [queryLabels] - Ground truth annotations for query sequences
/// * [evalueCutoff] - Maximum MMSeqs2 E-value threshold
/// * [minSeqId] - Minimum sequence identity threshold
/// * [isNumeric] - True for continuous regression targets, False for classification
/// * [iterations] - Bootstrap iterations performed
@BuiltValue()
abstract class SplitHBIRequest implements Built<SplitHBIRequest, SplitHBIRequestBuilder> {
  /// Target database sequences (train split)
  @BuiltValueField(wireName: r'train_seqs')
  BuiltMap<String, String> get trainSeqs;

  /// Query database sequences to evaluate (test/val split)
  @BuiltValueField(wireName: r'query_seqs')
  BuiltMap<String, String> get querySeqs;

  /// Ground truth annotations for train sequences
  @BuiltValueField(wireName: r'train_labels')
  BuiltMap<String, JsonObject?> get trainLabels;

  /// Ground truth annotations for query sequences
  @BuiltValueField(wireName: r'query_labels')
  BuiltMap<String, JsonObject?> get queryLabels;

  /// Maximum MMSeqs2 E-value threshold
  @BuiltValueField(wireName: r'evalue_cutoff')
  num? get evalueCutoff;

  /// Minimum sequence identity threshold
  @BuiltValueField(wireName: r'min_seq_id')
  num? get minSeqId;

  /// True for continuous regression targets, False for classification
  @BuiltValueField(wireName: r'is_numeric')
  bool? get isNumeric;

  /// Bootstrap iterations performed
  @BuiltValueField(wireName: r'iterations')
  int? get iterations;

  SplitHBIRequest._();

  factory SplitHBIRequest([void updates(SplitHBIRequestBuilder b)]) = _$SplitHBIRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SplitHBIRequestBuilder b) => b
      ..evalueCutoff = 10.0
      ..minSeqId = 0.0
      ..isNumeric = false
      ..iterations = 30;

  @BuiltValueSerializer(custom: true)
  static Serializer<SplitHBIRequest> get serializer => _$SplitHBIRequestSerializer();
}

class _$SplitHBIRequestSerializer implements PrimitiveSerializer<SplitHBIRequest> {
  @override
  final Iterable<Type> types = const [SplitHBIRequest, _$SplitHBIRequest];

  @override
  final String wireName = r'SplitHBIRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SplitHBIRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'train_seqs';
    yield serializers.serialize(
      object.trainSeqs,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'query_seqs';
    yield serializers.serialize(
      object.querySeqs,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'train_labels';
    yield serializers.serialize(
      object.trainLabels,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'query_labels';
    yield serializers.serialize(
      object.queryLabels,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    if (object.evalueCutoff != null) {
      yield r'evalue_cutoff';
      yield serializers.serialize(
        object.evalueCutoff,
        specifiedType: const FullType(num),
      );
    }
    if (object.minSeqId != null) {
      yield r'min_seq_id';
      yield serializers.serialize(
        object.minSeqId,
        specifiedType: const FullType(num),
      );
    }
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
    SplitHBIRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SplitHBIRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'train_seqs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.trainSeqs.replace(valueDes);
          break;
        case r'query_seqs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.querySeqs.replace(valueDes);
          break;
        case r'train_labels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.trainLabels.replace(valueDes);
          break;
        case r'query_labels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.queryLabels.replace(valueDes);
          break;
        case r'evalue_cutoff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.evalueCutoff = valueDes;
          break;
        case r'min_seq_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.minSeqId = valueDes;
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
  SplitHBIRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SplitHBIRequestBuilder();
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


