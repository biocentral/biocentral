//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biocentral_prediction_model.g.dart';

class BiocentralPredictionModel extends EnumClass {

  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'BindEmbed')
  static const BiocentralPredictionModel bindEmbed = _$bindEmbed;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'ProtT5Conservation')
  static const BiocentralPredictionModel protT5Conservation = _$protT5Conservation;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'Seth')
  static const BiocentralPredictionModel seth = _$seth;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'LightAttentionSubcellularLocalization')
  static const BiocentralPredictionModel lightAttentionSubcellularLocalization = _$lightAttentionSubcellularLocalization;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'LightAttentionMembrane')
  static const BiocentralPredictionModel lightAttentionMembrane = _$lightAttentionMembrane;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'TMbed')
  static const BiocentralPredictionModel tMbed = _$tMbed;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'ProtT5SecondaryStructure')
  static const BiocentralPredictionModel protT5SecondaryStructure = _$protT5SecondaryStructure;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'ExoTox')
  static const BiocentralPredictionModel exoTox = _$exoTox;
  /// Biocentral prediction model names (for usage in APIs)
  @BuiltValueEnumConst(wireName: r'VespaG')
  static const BiocentralPredictionModel vespaG = _$vespaG;

  static Serializer<BiocentralPredictionModel> get serializer => _$biocentralPredictionModelSerializer;

  const BiocentralPredictionModel._(String name): super(name);

  static BuiltSet<BiocentralPredictionModel> get values => _$values;
  static BiocentralPredictionModel valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class BiocentralPredictionModelMixin = Object with _$BiocentralPredictionModelMixin;

