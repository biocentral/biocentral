//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'perplexity_request.g.dart';

/// PerplexityRequest
///
/// Properties:
/// * [sequenceData] - Dictionary mapping sequence IDs to their amino acid sequence strings
/// * [plmName] - Name of the PLM to use for perplexity calculation
@BuiltValue()
abstract class PerplexityRequest implements Built<PerplexityRequest, PerplexityRequestBuilder> {
  /// Dictionary mapping sequence IDs to their amino acid sequence strings
  @BuiltValueField(wireName: r'sequence_data')
  BuiltMap<String, String> get sequenceData;

  /// Name of the PLM to use for perplexity calculation
  @BuiltValueField(wireName: r'plm_name')
  String get plmName;

  PerplexityRequest._();

  factory PerplexityRequest([void updates(PerplexityRequestBuilder b)]) = _$PerplexityRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PerplexityRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PerplexityRequest> get serializer => _$PerplexityRequestSerializer();
}

class _$PerplexityRequestSerializer implements PrimitiveSerializer<PerplexityRequest> {
  @override
  final Iterable<Type> types = const [PerplexityRequest, _$PerplexityRequest];

  @override
  final String wireName = r'PerplexityRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PerplexityRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sequence_data';
    yield serializers.serialize(
      object.sequenceData,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'plm_name';
    yield serializers.serialize(
      object.plmName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PerplexityRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PerplexityRequestBuilder result,
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
        case r'plm_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.plmName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PerplexityRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PerplexityRequestBuilder();
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

