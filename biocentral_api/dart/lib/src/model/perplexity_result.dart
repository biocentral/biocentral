//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/zero_shot_method.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'perplexity_result.g.dart';

/// (Pseudo)perplexity result for a set of sequences (method depends on given protein language model).
///
/// Properties:
/// * [method] - Either perplexity or pseudoperplexity
/// * [seq2perplexity] - Dictionary mapping sequence IDs to their (pseudo)perplexity scores
@BuiltValue()
abstract class PerplexityResult implements Built<PerplexityResult, PerplexityResultBuilder> {
  /// Either perplexity or pseudoperplexity
  @BuiltValueField(wireName: r'method')
  ZeroShotMethod get method;
  // enum methodEnum {  WT_MARGINALS,  MASKED_MARGINALS,  PSEUDOPERPLEXITY,  PERPLEXITY,  JACOBIAN_CONTACT,  };

  /// Dictionary mapping sequence IDs to their (pseudo)perplexity scores
  @BuiltValueField(wireName: r'seq2perplexity')
  BuiltMap<String, num> get seq2perplexity;

  PerplexityResult._();

  factory PerplexityResult([void updates(PerplexityResultBuilder b)]) = _$PerplexityResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PerplexityResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PerplexityResult> get serializer => _$PerplexityResultSerializer();
}

class _$PerplexityResultSerializer implements PrimitiveSerializer<PerplexityResult> {
  @override
  final Iterable<Type> types = const [PerplexityResult, _$PerplexityResult];

  @override
  final String wireName = r'PerplexityResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PerplexityResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(ZeroShotMethod),
    );
    yield r'seq2perplexity';
    yield serializers.serialize(
      object.seq2perplexity,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(num)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PerplexityResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PerplexityResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ZeroShotMethod),
          ) as ZeroShotMethod;
          result.method = valueDes;
          break;
        case r'seq2perplexity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(num)]),
          ) as BuiltMap<String, num>;
          result.seq2perplexity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PerplexityResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PerplexityResultBuilder();
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

