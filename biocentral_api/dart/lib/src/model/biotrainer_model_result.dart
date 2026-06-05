//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/test_result.dart';
import 'package:biocentral_api/src/model/biotrainer_prediction.dart';
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/derived_values.dart';
import 'package:biocentral_api/src/model/training_result.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biotrainer_model_result.g.dart';

/// BiotrainerModelResult
///
/// Properties:
/// * [config] - Training configuration parameters
/// * [derivedValues] - Values derived during the training process
/// * [trainingResults] - Training results for each cross-validation split
/// * [testResults] - Test results after training for each test set
/// * [predictions] - Predictions made by the model
@BuiltValue()
abstract class BiotrainerModelResult implements Built<BiotrainerModelResult, BiotrainerModelResultBuilder> {
  /// Training configuration parameters
  @BuiltValueField(wireName: r'config')
  BuiltMap<String, JsonObject?>? get config;

  /// Values derived during the training process
  @BuiltValueField(wireName: r'derived_values')
  DerivedValues? get derivedValues;

  /// Training results for each cross-validation split
  @BuiltValueField(wireName: r'training_results')
  BuiltMap<String, TrainingResult>? get trainingResults;

  /// Test results after training for each test set
  @BuiltValueField(wireName: r'test_results')
  BuiltMap<String, TestResult>? get testResults;

  /// Predictions made by the model
  @BuiltValueField(wireName: r'predictions')
  BuiltList<BiotrainerPrediction>? get predictions;

  BiotrainerModelResult._();

  factory BiotrainerModelResult([void updates(BiotrainerModelResultBuilder b)]) = _$BiotrainerModelResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiotrainerModelResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiotrainerModelResult> get serializer => _$BiotrainerModelResultSerializer();
}

class _$BiotrainerModelResultSerializer implements PrimitiveSerializer<BiotrainerModelResult> {
  @override
  final Iterable<Type> types = const [BiotrainerModelResult, _$BiotrainerModelResult];

  @override
  final String wireName = r'BiotrainerModelResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiotrainerModelResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.config != null) {
      yield r'config';
      yield serializers.serialize(
        object.config,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.derivedValues != null) {
      yield r'derived_values';
      yield serializers.serialize(
        object.derivedValues,
        specifiedType: const FullType.nullable(DerivedValues),
      );
    }
    if (object.trainingResults != null) {
      yield r'training_results';
      yield serializers.serialize(
        object.trainingResults,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(TrainingResult)]),
      );
    }
    if (object.testResults != null) {
      yield r'test_results';
      yield serializers.serialize(
        object.testResults,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(TestResult)]),
      );
    }
    if (object.predictions != null) {
      yield r'predictions';
      yield serializers.serialize(
        object.predictions,
        specifiedType: const FullType(BuiltList, [FullType(BiotrainerPrediction)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiotrainerModelResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiotrainerModelResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.config.replace(valueDes);
          break;
        case r'derived_values':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DerivedValues),
          ) as DerivedValues?;
          if (valueDes == null) continue;
          result.derivedValues.replace(valueDes);
          break;
        case r'training_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(TrainingResult)]),
          ) as BuiltMap<String, TrainingResult>;
          result.trainingResults.replace(valueDes);
          break;
        case r'test_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(TestResult)]),
          ) as BuiltMap<String, TestResult>;
          result.testResults.replace(valueDes);
          break;
        case r'predictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BiotrainerPrediction)]),
          ) as BuiltList<BiotrainerPrediction>;
          result.predictions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiotrainerModelResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiotrainerModelResultBuilder();
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

