//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/embedding_stats.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'derived_values.g.dart';

/// Derived values calculated during the training process. 
///
/// Properties:
/// * [biotrainerVersion] - Version of BioTrainer used for training
/// * [classInt2str] - Mapping of class integers to class names
/// * [classStr2int] - Mapping of class names to class integers
/// * [computedClassWeights] - Class weights computed during training
/// * [embeddingStats] - Statistics of the embeddings
/// * [embeddingsFile] - Path to the embeddings file
/// * [modelHash] - Hash of the model
/// * [nClasses] - Number of classes in the dataset
/// * [nFeatures] - Number of input features (e.g. embedding dimensions)
/// * [nTestingIds] - Number of sequences in the test set
/// * [pipelineElapsedTime] - Elapsed time in seconds for the pipeline
/// * [pipelineEndTime] - End time of the pipeline
/// * [pipelineStartTime] - Start time of the pipeline
/// * [trainingElapsedTime] - Elapsed time in seconds for training
@BuiltValue()
abstract class DerivedValues implements Built<DerivedValues, DerivedValuesBuilder> {
  /// Version of BioTrainer used for training
  @BuiltValueField(wireName: r'biotrainer_version')
  String? get biotrainerVersion;

  /// Mapping of class integers to class names
  @BuiltValueField(wireName: r'class_int2str')
  BuiltMap<String, String>? get classInt2str;

  /// Mapping of class names to class integers
  @BuiltValueField(wireName: r'class_str2int')
  BuiltMap<String, int>? get classStr2int;

  /// Class weights computed during training
  @BuiltValueField(wireName: r'computed_class_weights')
  BuiltMap<String, num>? get computedClassWeights;

  /// Statistics of the embeddings
  @BuiltValueField(wireName: r'embedding_stats')
  EmbeddingStats? get embeddingStats;

  /// Path to the embeddings file
  @BuiltValueField(wireName: r'embeddings_file')
  String? get embeddingsFile;

  /// Hash of the model
  @BuiltValueField(wireName: r'model_hash')
  String? get modelHash;

  /// Number of classes in the dataset
  @BuiltValueField(wireName: r'n_classes')
  int? get nClasses;

  /// Number of input features (e.g. embedding dimensions)
  @BuiltValueField(wireName: r'n_features')
  int? get nFeatures;

  /// Number of sequences in the test set
  @BuiltValueField(wireName: r'n_testing_ids')
  int? get nTestingIds;

  /// Elapsed time in seconds for the pipeline
  @BuiltValueField(wireName: r'pipeline_elapsed_time')
  num? get pipelineElapsedTime;

  /// End time of the pipeline
  @BuiltValueField(wireName: r'pipeline_end_time')
  String? get pipelineEndTime;

  /// Start time of the pipeline
  @BuiltValueField(wireName: r'pipeline_start_time')
  String? get pipelineStartTime;

  /// Elapsed time in seconds for training
  @BuiltValueField(wireName: r'training_elapsed_time')
  num? get trainingElapsedTime;

  DerivedValues._();

  factory DerivedValues([void updates(DerivedValuesBuilder b)]) = _$DerivedValues;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DerivedValuesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DerivedValues> get serializer => _$DerivedValuesSerializer();
}

class _$DerivedValuesSerializer implements PrimitiveSerializer<DerivedValues> {
  @override
  final Iterable<Type> types = const [DerivedValues, _$DerivedValues];

  @override
  final String wireName = r'DerivedValues';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DerivedValues object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.biotrainerVersion != null) {
      yield r'biotrainer_version';
      yield serializers.serialize(
        object.biotrainerVersion,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.classInt2str != null) {
      yield r'class_int2str';
      yield serializers.serialize(
        object.classInt2str,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    if (object.classStr2int != null) {
      yield r'class_str2int';
      yield serializers.serialize(
        object.classStr2int,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(int)]),
      );
    }
    if (object.computedClassWeights != null) {
      yield r'computed_class_weights';
      yield serializers.serialize(
        object.computedClassWeights,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(num)]),
      );
    }
    if (object.embeddingStats != null) {
      yield r'embedding_stats';
      yield serializers.serialize(
        object.embeddingStats,
        specifiedType: const FullType.nullable(EmbeddingStats),
      );
    }
    if (object.embeddingsFile != null) {
      yield r'embeddings_file';
      yield serializers.serialize(
        object.embeddingsFile,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.modelHash != null) {
      yield r'model_hash';
      yield serializers.serialize(
        object.modelHash,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.nClasses != null) {
      yield r'n_classes';
      yield serializers.serialize(
        object.nClasses,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.nFeatures != null) {
      yield r'n_features';
      yield serializers.serialize(
        object.nFeatures,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.nTestingIds != null) {
      yield r'n_testing_ids';
      yield serializers.serialize(
        object.nTestingIds,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.pipelineElapsedTime != null) {
      yield r'pipeline_elapsed_time';
      yield serializers.serialize(
        object.pipelineElapsedTime,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.pipelineEndTime != null) {
      yield r'pipeline_end_time';
      yield serializers.serialize(
        object.pipelineEndTime,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.pipelineStartTime != null) {
      yield r'pipeline_start_time';
      yield serializers.serialize(
        object.pipelineStartTime,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.trainingElapsedTime != null) {
      yield r'training_elapsed_time';
      yield serializers.serialize(
        object.trainingElapsedTime,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DerivedValues object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DerivedValuesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'biotrainer_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.biotrainerVersion = valueDes;
          break;
        case r'class_int2str':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>?;
          if (valueDes == null) continue;
          result.classInt2str.replace(valueDes);
          break;
        case r'class_str2int':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(int)]),
          ) as BuiltMap<String, int>?;
          if (valueDes == null) continue;
          result.classStr2int.replace(valueDes);
          break;
        case r'computed_class_weights':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(num)]),
          ) as BuiltMap<String, num>?;
          if (valueDes == null) continue;
          result.computedClassWeights.replace(valueDes);
          break;
        case r'embedding_stats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(EmbeddingStats),
          ) as EmbeddingStats?;
          if (valueDes == null) continue;
          result.embeddingStats.replace(valueDes);
          break;
        case r'embeddings_file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.embeddingsFile = valueDes;
          break;
        case r'model_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.modelHash = valueDes;
          break;
        case r'n_classes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nClasses = valueDes;
          break;
        case r'n_features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nFeatures = valueDes;
          break;
        case r'n_testing_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nTestingIds = valueDes;
          break;
        case r'pipeline_elapsed_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.pipelineElapsedTime = valueDes;
          break;
        case r'pipeline_end_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pipelineEndTime = valueDes;
          break;
        case r'pipeline_start_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pipelineStartTime = valueDes;
          break;
        case r'training_elapsed_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.trainingElapsedTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DerivedValues deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DerivedValuesBuilder();
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

