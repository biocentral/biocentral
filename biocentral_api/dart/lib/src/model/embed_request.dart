//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'embed_request.g.dart';

/// EmbedRequest
///
/// Properties:
/// * [embedderName] - Name of the embedder model to use
/// * [reduce] - Whether to use dimensionality reduction
/// * [sequenceData] - Sequence data to embed (seq_id -> sequence)
/// * [useHalfPrecision] - Whether to use half precision
@BuiltValue()
abstract class EmbedRequest implements Built<EmbedRequest, EmbedRequestBuilder> {
  /// Name of the embedder model to use
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  /// Whether to use dimensionality reduction
  @BuiltValueField(wireName: r'reduce')
  bool? get reduce;

  /// Sequence data to embed (seq_id -> sequence)
  @BuiltValueField(wireName: r'sequence_data')
  BuiltMap<String, String> get sequenceData;

  /// Whether to use half precision
  @BuiltValueField(wireName: r'use_half_precision')
  bool? get useHalfPrecision;

  EmbedRequest._();

  factory EmbedRequest([void updates(EmbedRequestBuilder b)]) = _$EmbedRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmbedRequestBuilder b) => b
      ..reduce = false
      ..useHalfPrecision = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmbedRequest> get serializer => _$EmbedRequestSerializer();
}

class _$EmbedRequestSerializer implements PrimitiveSerializer<EmbedRequest> {
  @override
  final Iterable<Type> types = const [EmbedRequest, _$EmbedRequest];

  @override
  final String wireName = r'EmbedRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmbedRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'embedder_name';
    yield serializers.serialize(
      object.embedderName,
      specifiedType: const FullType(String),
    );
    if (object.reduce != null) {
      yield r'reduce';
      yield serializers.serialize(
        object.reduce,
        specifiedType: const FullType(bool),
      );
    }
    yield r'sequence_data';
    yield serializers.serialize(
      object.sequenceData,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    if (object.useHalfPrecision != null) {
      yield r'use_half_precision';
      yield serializers.serialize(
        object.useHalfPrecision,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EmbedRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EmbedRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedderName = valueDes;
          break;
        case r'reduce':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.reduce = valueDes;
          break;
        case r'sequence_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.sequenceData.replace(valueDes);
          break;
        case r'use_half_precision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.useHalfPrecision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EmbedRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmbedRequestBuilder();
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

