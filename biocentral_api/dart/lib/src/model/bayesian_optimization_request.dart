//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bayesian_optimization_request.g.dart';

/// Request model for Bayesian optimization training
///
/// Properties:
/// * [databaseHash] - Hash identifier for the training database
/// * [modelType] - Type of model to use
/// * [coefficient] - Coefficient value (must be non-negative)
/// * [embedderName] - Name of embedder to use
/// * [discrete] - Whether to perform discrete optimization or continuous optimization
/// * [optimizationMode] - Optimization mode selection
/// * [targetLb] 
/// * [targetUb] 
/// * [targetValue] 
/// * [discreteLabels] 
/// * [discreteTargets] 
@BuiltValue()
abstract class BayesianOptimizationRequest implements Built<BayesianOptimizationRequest, BayesianOptimizationRequestBuilder> {
  /// Hash identifier for the training database
  @BuiltValueField(wireName: r'database_hash')
  String get databaseHash;

  /// Type of model to use
  @BuiltValueField(wireName: r'model_type')
  String get modelType;

  /// Coefficient value (must be non-negative)
  @BuiltValueField(wireName: r'coefficient')
  num get coefficient;

  /// Name of embedder to use
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  /// Whether to perform discrete optimization or continuous optimization
  @BuiltValueField(wireName: r'discrete')
  bool get discrete;

  /// Optimization mode selection
  @BuiltValueField(wireName: r'optimization_mode')
  String get optimizationMode;

  @BuiltValueField(wireName: r'target_lb')
  num? get targetLb;

  @BuiltValueField(wireName: r'target_ub')
  num? get targetUb;

  @BuiltValueField(wireName: r'target_value')
  num? get targetValue;

  @BuiltValueField(wireName: r'discrete_labels')
  BuiltList<String>? get discreteLabels;

  @BuiltValueField(wireName: r'discrete_targets')
  BuiltList<String>? get discreteTargets;

  BayesianOptimizationRequest._();

  factory BayesianOptimizationRequest([void updates(BayesianOptimizationRequestBuilder b)]) = _$BayesianOptimizationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BayesianOptimizationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BayesianOptimizationRequest> get serializer => _$BayesianOptimizationRequestSerializer();
}

class _$BayesianOptimizationRequestSerializer implements PrimitiveSerializer<BayesianOptimizationRequest> {
  @override
  final Iterable<Type> types = const [BayesianOptimizationRequest, _$BayesianOptimizationRequest];

  @override
  final String wireName = r'BayesianOptimizationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BayesianOptimizationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'database_hash';
    yield serializers.serialize(
      object.databaseHash,
      specifiedType: const FullType(String),
    );
    yield r'model_type';
    yield serializers.serialize(
      object.modelType,
      specifiedType: const FullType(String),
    );
    yield r'coefficient';
    yield serializers.serialize(
      object.coefficient,
      specifiedType: const FullType(num),
    );
    yield r'embedder_name';
    yield serializers.serialize(
      object.embedderName,
      specifiedType: const FullType(String),
    );
    yield r'discrete';
    yield serializers.serialize(
      object.discrete,
      specifiedType: const FullType(bool),
    );
    yield r'optimization_mode';
    yield serializers.serialize(
      object.optimizationMode,
      specifiedType: const FullType(String),
    );
    if (object.targetLb != null) {
      yield r'target_lb';
      yield serializers.serialize(
        object.targetLb,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.targetUb != null) {
      yield r'target_ub';
      yield serializers.serialize(
        object.targetUb,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.targetValue != null) {
      yield r'target_value';
      yield serializers.serialize(
        object.targetValue,
        specifiedType: const FullType.nullable(num),
      );
    }
    yield r'discrete_labels';
    yield object.discreteLabels == null ? null : serializers.serialize(
      object.discreteLabels,
      specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
    );
    yield r'discrete_targets';
    yield object.discreteTargets == null ? null : serializers.serialize(
      object.discreteTargets,
      specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BayesianOptimizationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BayesianOptimizationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'database_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.databaseHash = valueDes;
          break;
        case r'model_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelType = valueDes;
          break;
        case r'coefficient':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.coefficient = valueDes;
          break;
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedderName = valueDes;
          break;
        case r'discrete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.discrete = valueDes;
          break;
        case r'optimization_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.optimizationMode = valueDes;
          break;
        case r'target_lb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.targetLb = valueDes;
          break;
        case r'target_ub':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.targetUb = valueDes;
          break;
        case r'target_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.targetValue = valueDes;
          break;
        case r'discrete_labels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.discreteLabels.replace(valueDes);
          break;
        case r'discrete_targets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.discreteTargets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BayesianOptimizationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BayesianOptimizationRequestBuilder();
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

