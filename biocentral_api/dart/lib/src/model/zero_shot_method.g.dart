// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zero_shot_method.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ZeroShotMethod _$WT_MARGINALS = const ZeroShotMethod._('WT_MARGINALS');
const ZeroShotMethod _$MASKED_MARGINALS =
    const ZeroShotMethod._('MASKED_MARGINALS');
const ZeroShotMethod _$PSEUDOPERPLEXITY =
    const ZeroShotMethod._('PSEUDOPERPLEXITY');
const ZeroShotMethod _$PERPLEXITY = const ZeroShotMethod._('PERPLEXITY');

ZeroShotMethod _$valueOf(String name) {
  switch (name) {
    case 'WT_MARGINALS':
      return _$WT_MARGINALS;
    case 'MASKED_MARGINALS':
      return _$MASKED_MARGINALS;
    case 'PSEUDOPERPLEXITY':
      return _$PSEUDOPERPLEXITY;
    case 'PERPLEXITY':
      return _$PERPLEXITY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ZeroShotMethod> _$values =
    BuiltSet<ZeroShotMethod>(const <ZeroShotMethod>[
  _$WT_MARGINALS,
  _$MASKED_MARGINALS,
  _$PSEUDOPERPLEXITY,
  _$PERPLEXITY,
]);

class _$ZeroShotMethodMeta {
  const _$ZeroShotMethodMeta();
  ZeroShotMethod get WT_MARGINALS => _$WT_MARGINALS;
  ZeroShotMethod get MASKED_MARGINALS => _$MASKED_MARGINALS;
  ZeroShotMethod get PSEUDOPERPLEXITY => _$PSEUDOPERPLEXITY;
  ZeroShotMethod get PERPLEXITY => _$PERPLEXITY;
  ZeroShotMethod valueOf(String name) => _$valueOf(name);
  BuiltSet<ZeroShotMethod> get values => _$values;
}

mixin _$ZeroShotMethodMixin {
  // ignore: non_constant_identifier_names
  _$ZeroShotMethodMeta get ZeroShotMethod => const _$ZeroShotMethodMeta();
}

Serializer<ZeroShotMethod> _$zeroShotMethodSerializer =
    _$ZeroShotMethodSerializer();

class _$ZeroShotMethodSerializer
    implements PrimitiveSerializer<ZeroShotMethod> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'WT_MARGINALS': 'WT_MARGINALS',
    'MASKED_MARGINALS': 'MASKED_MARGINALS',
    'PSEUDOPERPLEXITY': 'PSEUDOPERPLEXITY',
    'PERPLEXITY': 'PERPLEXITY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'WT_MARGINALS': 'WT_MARGINALS',
    'MASKED_MARGINALS': 'MASKED_MARGINALS',
    'PSEUDOPERPLEXITY': 'PSEUDOPERPLEXITY',
    'PERPLEXITY': 'PERPLEXITY',
  };

  @override
  final Iterable<Type> types = const <Type>[ZeroShotMethod];
  @override
  final String wireName = 'ZeroShotMethod';

  @override
  Object serialize(Serializers serializers, ZeroShotMethod object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ZeroShotMethod deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ZeroShotMethod.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
