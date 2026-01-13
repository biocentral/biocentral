//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'protocol.g.dart';

class Protocol extends EnumClass {

  @BuiltValueEnumConst(wireName: r'[0]')
  static const Protocol leftSquareBracket0RightSquareBracket = _$leftSquareBracket0RightSquareBracket;
  @BuiltValueEnumConst(wireName: r'[1]')
  static const Protocol leftSquareBracket1RightSquareBracket = _$leftSquareBracket1RightSquareBracket;
  @BuiltValueEnumConst(wireName: r'[2]')
  static const Protocol leftSquareBracket2RightSquareBracket = _$leftSquareBracket2RightSquareBracket;
  @BuiltValueEnumConst(wireName: r'[3]')
  static const Protocol leftSquareBracket3RightSquareBracket = _$leftSquareBracket3RightSquareBracket;
  @BuiltValueEnumConst(wireName: r'[4]')
  static const Protocol leftSquareBracket4RightSquareBracket = _$leftSquareBracket4RightSquareBracket;
  @BuiltValueEnumConst(wireName: r'5')
  static const Protocol n5 = _$n5;

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

