//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/raw_prediction.dart';
import 'package:biocentral_api/src/model/prediction1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/mcd_upper_bound.dart';
import 'package:biocentral_api/src/model/mcd_lower_bound.dart';
import 'package:biocentral_api/src/model/mcd_mean.dart';
import 'package:biocentral_api/src/model/mcd_std.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biotrainer_prediction.g.dart';

/// BiotrainerPrediction
///
/// Properties:
/// * [seqId] - Sequence identifier
/// * [prediction]
/// * [isAggregated] - Whether the prediction is an aggregated per-residue prediction
/// * [residueIndex] - Residue index for non-collapsed per-residue predictions
/// * [rawPrediction]
/// * [mcdPredictions] - All Monte-Carlo-Dropout predictions
/// * [mcdMean]
/// * [mcdStd]
/// * [mcdLowerBound]
/// * [mcdUpperBound]
/// * [baldScore] - BALD score
@BuiltValue()
abstract class BiotrainerPrediction implements Built<BiotrainerPrediction, BiotrainerPredictionBuilder> {
  /// Sequence identifier
  @BuiltValueField(wireName: r'seq_id')
  String get seqId;

  @BuiltValueField(wireName: r'prediction')
  Prediction1 get prediction;

  /// Whether the prediction is an aggregated per-residue prediction
  @BuiltValueField(wireName: r'is_aggregated')
  bool? get isAggregated;

  /// Residue index for non-collapsed per-residue predictions
  @BuiltValueField(wireName: r'residue_index')
  int? get residueIndex;

  @BuiltValueField(wireName: r'raw_prediction')
  RawPrediction? get rawPrediction;

  /// All Monte-Carlo-Dropout predictions
  @BuiltValueField(wireName: r'mcd_predictions')
  BuiltList<JsonObject?>? get mcdPredictions;

  @BuiltValueField(wireName: r'mcd_mean')
  McdMean? get mcdMean;

  @BuiltValueField(wireName: r'mcd_std')
  McdStd? get mcdStd;

  @BuiltValueField(wireName: r'mcd_lower_bound')
  McdLowerBound? get mcdLowerBound;

  @BuiltValueField(wireName: r'mcd_upper_bound')
  McdUpperBound? get mcdUpperBound;

  /// BALD score
  @BuiltValueField(wireName: r'bald_score')
  num? get baldScore;

  BiotrainerPrediction._();

  factory BiotrainerPrediction([void updates(BiotrainerPredictionBuilder b)]) = _$BiotrainerPrediction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiotrainerPredictionBuilder b) => b
      ..isAggregated = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiotrainerPrediction> get serializer => _$BiotrainerPredictionSerializer();
}

class _$BiotrainerPredictionSerializer implements PrimitiveSerializer<BiotrainerPrediction> {
  @override
  final Iterable<Type> types = const [BiotrainerPrediction, _$BiotrainerPrediction];

  @override
  final String wireName = r'BiotrainerPrediction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiotrainerPrediction object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'seq_id';
    yield serializers.serialize(
      object.seqId,
      specifiedType: const FullType(String),
    );
    yield r'prediction';
    yield serializers.serialize(
      object.prediction,
      specifiedType: const FullType(Prediction1),
    );
    if (object.isAggregated != null) {
      yield r'is_aggregated';
      yield serializers.serialize(
        object.isAggregated,
        specifiedType: const FullType(bool),
      );
    }
    if (object.residueIndex != null) {
      yield r'residue_index';
      yield serializers.serialize(
        object.residueIndex,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.rawPrediction != null) {
      yield r'raw_prediction';
      yield serializers.serialize(
        object.rawPrediction,
        specifiedType: const FullType.nullable(RawPrediction),
      );
    }
    if (object.mcdPredictions != null) {
      yield r'mcd_predictions';
      yield serializers.serialize(
        object.mcdPredictions,
        specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
    if (object.mcdMean != null) {
      yield r'mcd_mean';
      yield serializers.serialize(
        object.mcdMean,
        specifiedType: const FullType.nullable(McdMean),
      );
    }
    if (object.mcdStd != null) {
      yield r'mcd_std';
      yield serializers.serialize(
        object.mcdStd,
        specifiedType: const FullType.nullable(McdStd),
      );
    }
    if (object.mcdLowerBound != null) {
      yield r'mcd_lower_bound';
      yield serializers.serialize(
        object.mcdLowerBound,
        specifiedType: const FullType.nullable(McdLowerBound),
      );
    }
    if (object.mcdUpperBound != null) {
      yield r'mcd_upper_bound';
      yield serializers.serialize(
        object.mcdUpperBound,
        specifiedType: const FullType.nullable(McdUpperBound),
      );
    }
    if (object.baldScore != null) {
      yield r'bald_score';
      yield serializers.serialize(
        object.baldScore,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiotrainerPrediction object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiotrainerPredictionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'seq_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.seqId = valueDes;
          break;
        case r'prediction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Prediction1),
          ) as Prediction1;
          result.prediction.replace(valueDes);
          break;
        case r'is_aggregated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isAggregated = valueDes;
          break;
        case r'residue_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.residueIndex = valueDes;
          break;
        case r'raw_prediction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RawPrediction),
          ) as RawPrediction?;
          if (valueDes == null) continue;
          result.rawPrediction.replace(valueDes);
          break;
        case r'mcd_predictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>?;
          if (valueDes == null) continue;
          result.mcdPredictions.replace(valueDes);
          break;
        case r'mcd_mean':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(McdMean),
          ) as McdMean?;
          if (valueDes == null) continue;
          result.mcdMean.replace(valueDes);
          break;
        case r'mcd_std':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(McdStd),
          ) as McdStd?;
          if (valueDes == null) continue;
          result.mcdStd.replace(valueDes);
          break;
        case r'mcd_lower_bound':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(McdLowerBound),
          ) as McdLowerBound?;
          if (valueDes == null) continue;
          result.mcdLowerBound.replace(valueDes);
          break;
        case r'mcd_upper_bound':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(McdUpperBound),
          ) as McdUpperBound?;
          if (valueDes == null) continue;
          result.mcdUpperBound.replace(valueDes);
          break;
        case r'bald_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.baldScore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiotrainerPrediction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiotrainerPredictionBuilder();
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
