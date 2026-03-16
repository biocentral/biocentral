//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'zero_shot_method.g.dart';

class ZeroShotMethod extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WT_MARGINALS')
  static const ZeroShotMethod WT_MARGINALS = _$WT_MARGINALS;
  @BuiltValueEnumConst(wireName: r'MASKED_MARGINALS')
  static const ZeroShotMethod MASKED_MARGINALS = _$MASKED_MARGINALS;
  @BuiltValueEnumConst(wireName: r'PSEUDOPERPLEXITY')
  static const ZeroShotMethod PSEUDOPERPLEXITY = _$PSEUDOPERPLEXITY;
  @BuiltValueEnumConst(wireName: r'PERPLEXITY')
  static const ZeroShotMethod PERPLEXITY = _$PERPLEXITY;

  static Serializer<ZeroShotMethod> get serializer => _$zeroShotMethodSerializer;

  const ZeroShotMethod._(String name): super(name);

  static BuiltSet<ZeroShotMethod> get values => _$values;
  static ZeroShotMethod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ZeroShotMethodMixin = Object with _$ZeroShotMethodMixin;

