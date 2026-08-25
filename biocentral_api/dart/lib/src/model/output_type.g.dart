// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OutputType _$perResidue = const OutputType._('perResidue');
const OutputType _$perSequence = const OutputType._('perSequence');
const OutputType _$mutation = const OutputType._('mutation');

OutputType _$valueOf(String name) {
  switch (name) {
    case 'perResidue':
      return _$perResidue;
    case 'perSequence':
      return _$perSequence;
    case 'mutation':
      return _$mutation;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OutputType> _$values = BuiltSet<OutputType>(const <OutputType>[
  _$perResidue,
  _$perSequence,
  _$mutation,
]);

class _$OutputTypeMeta {
  const _$OutputTypeMeta();
  OutputType get perResidue => _$perResidue;
  OutputType get perSequence => _$perSequence;
  OutputType get mutation => _$mutation;
  OutputType valueOf(String name) => _$valueOf(name);
  BuiltSet<OutputType> get values => _$values;
}

mixin _$OutputTypeMixin {
  // ignore: non_constant_identifier_names
  _$OutputTypeMeta get OutputType => const _$OutputTypeMeta();
}

Serializer<OutputType> _$outputTypeSerializer = _$OutputTypeSerializer();

class _$OutputTypeSerializer implements PrimitiveSerializer<OutputType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'perResidue': 'per_residue',
    'perSequence': 'per_sequence',
    'mutation': 'mutation',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'per_residue': 'perResidue',
    'per_sequence': 'perSequence',
    'mutation': 'mutation',
  };

  @override
  final Iterable<Type> types = const <Type>[OutputType];
  @override
  final String wireName = 'OutputType';

  @override
  Object serialize(Serializers serializers, OutputType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OutputType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OutputType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
