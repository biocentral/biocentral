// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Protocol _$residueToValue = const Protocol._('residueToValue');
const Protocol _$residueToClass = const Protocol._('residueToClass');
const Protocol _$residuesToClass = const Protocol._('residuesToClass');
const Protocol _$residuesToValue = const Protocol._('residuesToValue');
const Protocol _$sequenceToClass = const Protocol._('sequenceToClass');
const Protocol _$sequenceToValue = const Protocol._('sequenceToValue');

Protocol _$valueOf(String name) {
  switch (name) {
    case 'residueToValue':
      return _$residueToValue;
    case 'residueToClass':
      return _$residueToClass;
    case 'residuesToClass':
      return _$residuesToClass;
    case 'residuesToValue':
      return _$residuesToValue;
    case 'sequenceToClass':
      return _$sequenceToClass;
    case 'sequenceToValue':
      return _$sequenceToValue;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<Protocol> _$values = BuiltSet<Protocol>(const <Protocol>[
  _$residueToValue,
  _$residueToClass,
  _$residuesToClass,
  _$residuesToValue,
  _$sequenceToClass,
  _$sequenceToValue,
]);

class _$ProtocolMeta {
  const _$ProtocolMeta();
  Protocol get residueToValue => _$residueToValue;
  Protocol get residueToClass => _$residueToClass;
  Protocol get residuesToClass => _$residuesToClass;
  Protocol get residuesToValue => _$residuesToValue;
  Protocol get sequenceToClass => _$sequenceToClass;
  Protocol get sequenceToValue => _$sequenceToValue;
  Protocol valueOf(String name) => _$valueOf(name);
  BuiltSet<Protocol> get values => _$values;
}

mixin _$ProtocolMixin {
  // ignore: non_constant_identifier_names
  _$ProtocolMeta get Protocol => const _$ProtocolMeta();
}

Serializer<Protocol> _$protocolSerializer = _$ProtocolSerializer();

class _$ProtocolSerializer implements PrimitiveSerializer<Protocol> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'residueToValue': 'residue_to_value',
    'residueToClass': 'residue_to_class',
    'residuesToClass': 'residues_to_class',
    'residuesToValue': 'residues_to_value',
    'sequenceToClass': 'sequence_to_class',
    'sequenceToValue': 'sequence_to_value',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'residue_to_value': 'residueToValue',
    'residue_to_class': 'residueToClass',
    'residues_to_class': 'residuesToClass',
    'residues_to_value': 'residuesToValue',
    'sequence_to_class': 'sequenceToClass',
    'sequence_to_value': 'sequenceToValue',
  };

  @override
  final Iterable<Type> types = const <Type>[Protocol];
  @override
  final String wireName = 'Protocol';

  @override
  Object serialize(Serializers serializers, Protocol object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  Protocol deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Protocol.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
