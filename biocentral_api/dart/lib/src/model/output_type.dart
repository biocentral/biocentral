//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'output_type.g.dart';

class OutputType extends EnumClass {

  @BuiltValueEnumConst(wireName: r'per_residue')
  static const OutputType perResidue = _$perResidue;
  @BuiltValueEnumConst(wireName: r'per_sequence')
  static const OutputType perSequence = _$perSequence;
  @BuiltValueEnumConst(wireName: r'mutation')
  static const OutputType mutation = _$mutation;

  static Serializer<OutputType> get serializer => _$outputTypeSerializer;

  const OutputType._(String name): super(name);

  static BuiltSet<OutputType> get values => _$values;
  static OutputType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class OutputTypeMixin = Object with _$OutputTypeMixin;

