//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'protocol.g.dart';

class Protocol extends EnumClass {

  @BuiltValueEnumConst(wireName: r'residue_to_value')
  static const Protocol residueToValue = _$residueToValue;
  @BuiltValueEnumConst(wireName: r'residue_to_class')
  static const Protocol residueToClass = _$residueToClass;
  @BuiltValueEnumConst(wireName: r'residues_to_class')
  static const Protocol residuesToClass = _$residuesToClass;
  @BuiltValueEnumConst(wireName: r'residues_to_value')
  static const Protocol residuesToValue = _$residuesToValue;
  @BuiltValueEnumConst(wireName: r'sequence_to_class')
  static const Protocol sequenceToClass = _$sequenceToClass;
  @BuiltValueEnumConst(wireName: r'sequence_to_value')
  static const Protocol sequenceToValue = _$sequenceToValue;

  static Serializer<Protocol> get serializer => _$protocolSerializer;

  const Protocol._(String name): super(name);

  static BuiltSet<Protocol> get values => _$values;
  static Protocol valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ProtocolMixin = Object with _$ProtocolMixin;

