//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/active_learning_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_iteration_result.g.dart';

/// ActiveLearningIterationResult
///
/// Properties:
/// * [iteration] - Iteration number (zero indexed for simulations, otherwise matches the given number in the iteration config)
/// * [results] - List of active learning results
/// * [suggestions] - List of suggested entity IDs for next iteration
@BuiltValue()
abstract class ActiveLearningIterationResult implements Built<ActiveLearningIterationResult, ActiveLearningIterationResultBuilder> {
  /// Iteration number (zero indexed for simulations, otherwise matches the given number in the iteration config)
  @BuiltValueField(wireName: r'iteration')
  int get iteration;

  /// List of active learning results
  @BuiltValueField(wireName: r'results')
  BuiltList<ActiveLearningResult> get results;

  /// List of suggested entity IDs for next iteration
  @BuiltValueField(wireName: r'suggestions')
  BuiltList<String> get suggestions;

  ActiveLearningIterationResult._();

  factory ActiveLearningIterationResult([void updates(ActiveLearningIterationResultBuilder b)]) = _$ActiveLearningIterationResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningIterationResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningIterationResult> get serializer => _$ActiveLearningIterationResultSerializer();
}

class _$ActiveLearningIterationResultSerializer implements PrimitiveSerializer<ActiveLearningIterationResult> {
  @override
  final Iterable<Type> types = const [ActiveLearningIterationResult, _$ActiveLearningIterationResult];

  @override
  final String wireName = r'ActiveLearningIterationResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningIterationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'iteration';
    yield serializers.serialize(
      object.iteration,
      specifiedType: const FullType(int),
    );
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(ActiveLearningResult)]),
    );
    yield r'suggestions';
    yield serializers.serialize(
      object.suggestions,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningIterationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningIterationResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'iteration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.iteration = valueDes;
          break;
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ActiveLearningResult)]),
          ) as BuiltList<ActiveLearningResult>;
          result.results.replace(valueDes);
          break;
        case r'suggestions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.suggestions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningIterationResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningIterationResultBuilder();
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

