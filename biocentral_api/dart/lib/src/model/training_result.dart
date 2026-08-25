//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/epoch_metrics.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'training_result.g.dart';

/// Training results for each cross-validation split. 
///
/// Properties:
/// * [nTrainingIds] - Number of sequences in the training set
/// * [nValidationIds] - Number of sequences in the validation set
/// * [trainingIds] - List of IDs in the training set
/// * [validationIds] - List of IDs in the validation set
/// * [splitHyperParams] - Hyperparameters used for this split
/// * [nFreeParameters] - Number of free parameters in the model
/// * [startTime] - Start time of the training process
/// * [endTime] - End time of the training process
/// * [elapsedTime] - Elapsed time in seconds for training
/// * [trainingLosses] - Training losses for each epoch
/// * [validationLosses] - Validation losses for each epoch
/// * [bestEpochMetrics] - Best training epoch metrics
/// * [sanityCheckWarnings] - Warnings from sanity checks
@BuiltValue()
abstract class TrainingResult implements Built<TrainingResult, TrainingResultBuilder> {
  /// Number of sequences in the training set
  @BuiltValueField(wireName: r'n_training_ids')
  int? get nTrainingIds;

  /// Number of sequences in the validation set
  @BuiltValueField(wireName: r'n_validation_ids')
  int? get nValidationIds;

  /// List of IDs in the training set
  @BuiltValueField(wireName: r'training_ids')
  BuiltList<String>? get trainingIds;

  /// List of IDs in the validation set
  @BuiltValueField(wireName: r'validation_ids')
  BuiltList<String>? get validationIds;

  /// Hyperparameters used for this split
  @BuiltValueField(wireName: r'split_hyper_params')
  BuiltMap<String, JsonObject?>? get splitHyperParams;

  /// Number of free parameters in the model
  @BuiltValueField(wireName: r'n_free_parameters')
  int? get nFreeParameters;

  /// Start time of the training process
  @BuiltValueField(wireName: r'start_time')
  String? get startTime;

  /// End time of the training process
  @BuiltValueField(wireName: r'end_time')
  String? get endTime;

  /// Elapsed time in seconds for training
  @BuiltValueField(wireName: r'elapsed_time')
  num? get elapsedTime;

  /// Training losses for each epoch
  @BuiltValueField(wireName: r'training_losses')
  BuiltList<num>? get trainingLosses;

  /// Validation losses for each epoch
  @BuiltValueField(wireName: r'validation_losses')
  BuiltList<num>? get validationLosses;

  /// Best training epoch metrics
  @BuiltValueField(wireName: r'best_epoch_metrics')
  EpochMetrics? get bestEpochMetrics;

  /// Warnings from sanity checks
  @BuiltValueField(wireName: r'sanity_check_warnings')
  BuiltList<String>? get sanityCheckWarnings;

  TrainingResult._();

  factory TrainingResult([void updates(TrainingResultBuilder b)]) = _$TrainingResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrainingResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrainingResult> get serializer => _$TrainingResultSerializer();
}

class _$TrainingResultSerializer implements PrimitiveSerializer<TrainingResult> {
  @override
  final Iterable<Type> types = const [TrainingResult, _$TrainingResult];

  @override
  final String wireName = r'TrainingResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrainingResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.nTrainingIds != null) {
      yield r'n_training_ids';
      yield serializers.serialize(
        object.nTrainingIds,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.nValidationIds != null) {
      yield r'n_validation_ids';
      yield serializers.serialize(
        object.nValidationIds,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.trainingIds != null) {
      yield r'training_ids';
      yield serializers.serialize(
        object.trainingIds,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.validationIds != null) {
      yield r'validation_ids';
      yield serializers.serialize(
        object.validationIds,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.splitHyperParams != null) {
      yield r'split_hyper_params';
      yield serializers.serialize(
        object.splitHyperParams,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.nFreeParameters != null) {
      yield r'n_free_parameters';
      yield serializers.serialize(
        object.nFreeParameters,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.startTime != null) {
      yield r'start_time';
      yield serializers.serialize(
        object.startTime,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.endTime != null) {
      yield r'end_time';
      yield serializers.serialize(
        object.endTime,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.elapsedTime != null) {
      yield r'elapsed_time';
      yield serializers.serialize(
        object.elapsedTime,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.trainingLosses != null) {
      yield r'training_losses';
      yield serializers.serialize(
        object.trainingLosses,
        specifiedType: const FullType(BuiltList, [FullType(num)]),
      );
    }
    if (object.validationLosses != null) {
      yield r'validation_losses';
      yield serializers.serialize(
        object.validationLosses,
        specifiedType: const FullType(BuiltList, [FullType(num)]),
      );
    }
    if (object.bestEpochMetrics != null) {
      yield r'best_epoch_metrics';
      yield serializers.serialize(
        object.bestEpochMetrics,
        specifiedType: const FullType.nullable(EpochMetrics),
      );
    }
    if (object.sanityCheckWarnings != null) {
      yield r'sanity_check_warnings';
      yield serializers.serialize(
        object.sanityCheckWarnings,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrainingResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrainingResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'n_training_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nTrainingIds = valueDes;
          break;
        case r'n_validation_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nValidationIds = valueDes;
          break;
        case r'training_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.trainingIds.replace(valueDes);
          break;
        case r'validation_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.validationIds.replace(valueDes);
          break;
        case r'split_hyper_params':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.splitHyperParams.replace(valueDes);
          break;
        case r'n_free_parameters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nFreeParameters = valueDes;
          break;
        case r'start_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.startTime = valueDes;
          break;
        case r'end_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.endTime = valueDes;
          break;
        case r'elapsed_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.elapsedTime = valueDes;
          break;
        case r'training_losses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(num)]),
          ) as BuiltList<num>?;
          if (valueDes == null) continue;
          result.trainingLosses.replace(valueDes);
          break;
        case r'validation_losses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(num)]),
          ) as BuiltList<num>?;
          if (valueDes == null) continue;
          result.validationLosses.replace(valueDes);
          break;
        case r'best_epoch_metrics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(EpochMetrics),
          ) as EpochMetrics?;
          if (valueDes == null) continue;
          result.bestEpochMetrics.replace(valueDes);
          break;
        case r'sanity_check_warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.sanityCheckWarnings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrainingResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrainingResultBuilder();
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

