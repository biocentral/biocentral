// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biocentral_prediction_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BiocentralPredictionModel _$bindEmbed =
    const BiocentralPredictionModel._('bindEmbed');
const BiocentralPredictionModel _$protT5Conservation =
    const BiocentralPredictionModel._('protT5Conservation');
const BiocentralPredictionModel _$seth =
    const BiocentralPredictionModel._('seth');
const BiocentralPredictionModel _$lightAttentionSubcellularLocalization =
    const BiocentralPredictionModel._('lightAttentionSubcellularLocalization');
const BiocentralPredictionModel _$lightAttentionMembrane =
    const BiocentralPredictionModel._('lightAttentionMembrane');
const BiocentralPredictionModel _$tMbed =
    const BiocentralPredictionModel._('tMbed');
const BiocentralPredictionModel _$protT5SecondaryStructure =
    const BiocentralPredictionModel._('protT5SecondaryStructure');
const BiocentralPredictionModel _$exoTox =
    const BiocentralPredictionModel._('exoTox');
const BiocentralPredictionModel _$vespaG =
    const BiocentralPredictionModel._('vespaG');

BiocentralPredictionModel _$valueOf(String name) {
  switch (name) {
    case 'bindEmbed':
      return _$bindEmbed;
    case 'protT5Conservation':
      return _$protT5Conservation;
    case 'seth':
      return _$seth;
    case 'lightAttentionSubcellularLocalization':
      return _$lightAttentionSubcellularLocalization;
    case 'lightAttentionMembrane':
      return _$lightAttentionMembrane;
    case 'tMbed':
      return _$tMbed;
    case 'protT5SecondaryStructure':
      return _$protT5SecondaryStructure;
    case 'exoTox':
      return _$exoTox;
    case 'vespaG':
      return _$vespaG;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BiocentralPredictionModel> _$values =
    BuiltSet<BiocentralPredictionModel>(const <BiocentralPredictionModel>[
  _$bindEmbed,
  _$protT5Conservation,
  _$seth,
  _$lightAttentionSubcellularLocalization,
  _$lightAttentionMembrane,
  _$tMbed,
  _$protT5SecondaryStructure,
  _$exoTox,
  _$vespaG,
]);

class _$BiocentralPredictionModelMeta {
  const _$BiocentralPredictionModelMeta();
  BiocentralPredictionModel get bindEmbed => _$bindEmbed;
  BiocentralPredictionModel get protT5Conservation => _$protT5Conservation;
  BiocentralPredictionModel get seth => _$seth;
  BiocentralPredictionModel get lightAttentionSubcellularLocalization =>
      _$lightAttentionSubcellularLocalization;
  BiocentralPredictionModel get lightAttentionMembrane =>
      _$lightAttentionMembrane;
  BiocentralPredictionModel get tMbed => _$tMbed;
  BiocentralPredictionModel get protT5SecondaryStructure =>
      _$protT5SecondaryStructure;
  BiocentralPredictionModel get exoTox => _$exoTox;
  BiocentralPredictionModel get vespaG => _$vespaG;
  BiocentralPredictionModel valueOf(String name) => _$valueOf(name);
  BuiltSet<BiocentralPredictionModel> get values => _$values;
}

mixin _$BiocentralPredictionModelMixin {
  // ignore: non_constant_identifier_names
  _$BiocentralPredictionModelMeta get BiocentralPredictionModel =>
      const _$BiocentralPredictionModelMeta();
}

Serializer<BiocentralPredictionModel> _$biocentralPredictionModelSerializer =
    _$BiocentralPredictionModelSerializer();

class _$BiocentralPredictionModelSerializer
    implements PrimitiveSerializer<BiocentralPredictionModel> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'bindEmbed': 'BindEmbed',
    'protT5Conservation': 'ProtT5Conservation',
    'seth': 'Seth',
    'lightAttentionSubcellularLocalization':
        'LightAttentionSubcellularLocalization',
    'lightAttentionMembrane': 'LightAttentionMembrane',
    'tMbed': 'TMbed',
    'protT5SecondaryStructure': 'ProtT5SecondaryStructure',
    'exoTox': 'ExoTox',
    'vespaG': 'VespaG',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'BindEmbed': 'bindEmbed',
    'ProtT5Conservation': 'protT5Conservation',
    'Seth': 'seth',
    'LightAttentionSubcellularLocalization':
        'lightAttentionSubcellularLocalization',
    'LightAttentionMembrane': 'lightAttentionMembrane',
    'TMbed': 'tMbed',
    'ProtT5SecondaryStructure': 'protT5SecondaryStructure',
    'ExoTox': 'exoTox',
    'VespaG': 'vespaG',
  };

  @override
  final Iterable<Type> types = const <Type>[BiocentralPredictionModel];
  @override
  final String wireName = 'BiocentralPredictionModel';

  @override
  Object serialize(Serializers serializers, BiocentralPredictionModel object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BiocentralPredictionModel deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BiocentralPredictionModel.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
