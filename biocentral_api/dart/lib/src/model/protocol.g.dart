// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Protocol _$leftSquareBracket0RightSquareBracket =
    const Protocol._('leftSquareBracket0RightSquareBracket');
const Protocol _$leftSquareBracket1RightSquareBracket =
    const Protocol._('leftSquareBracket1RightSquareBracket');
const Protocol _$leftSquareBracket2RightSquareBracket =
    const Protocol._('leftSquareBracket2RightSquareBracket');
const Protocol _$leftSquareBracket3RightSquareBracket =
    const Protocol._('leftSquareBracket3RightSquareBracket');
const Protocol _$leftSquareBracket4RightSquareBracket =
    const Protocol._('leftSquareBracket4RightSquareBracket');
const Protocol _$n5 = const Protocol._('n5');

Protocol _$valueOf(String name) {
  switch (name) {
    case 'leftSquareBracket0RightSquareBracket':
      return _$leftSquareBracket0RightSquareBracket;
    case 'leftSquareBracket1RightSquareBracket':
      return _$leftSquareBracket1RightSquareBracket;
    case 'leftSquareBracket2RightSquareBracket':
      return _$leftSquareBracket2RightSquareBracket;
    case 'leftSquareBracket3RightSquareBracket':
      return _$leftSquareBracket3RightSquareBracket;
    case 'leftSquareBracket4RightSquareBracket':
      return _$leftSquareBracket4RightSquareBracket;
    case 'n5':
      return _$n5;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<Protocol> _$values = BuiltSet<Protocol>(const <Protocol>[
  _$leftSquareBracket0RightSquareBracket,
  _$leftSquareBracket1RightSquareBracket,
  _$leftSquareBracket2RightSquareBracket,
  _$leftSquareBracket3RightSquareBracket,
  _$leftSquareBracket4RightSquareBracket,
  _$n5,
]);

class _$ProtocolMeta {
  const _$ProtocolMeta();
  Protocol get leftSquareBracket0RightSquareBracket =>
      _$leftSquareBracket0RightSquareBracket;
  Protocol get leftSquareBracket1RightSquareBracket =>
      _$leftSquareBracket1RightSquareBracket;
  Protocol get leftSquareBracket2RightSquareBracket =>
      _$leftSquareBracket2RightSquareBracket;
  Protocol get leftSquareBracket3RightSquareBracket =>
      _$leftSquareBracket3RightSquareBracket;
  Protocol get leftSquareBracket4RightSquareBracket =>
      _$leftSquareBracket4RightSquareBracket;
  Protocol get n5 => _$n5;
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
    'leftSquareBracket0RightSquareBracket': '[0]',
    'leftSquareBracket1RightSquareBracket': '[1]',
    'leftSquareBracket2RightSquareBracket': '[2]',
    'leftSquareBracket3RightSquareBracket': '[3]',
    'leftSquareBracket4RightSquareBracket': '[4]',
    'n5': '5',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '[0]': 'leftSquareBracket0RightSquareBracket',
    '[1]': 'leftSquareBracket1RightSquareBracket',
    '[2]': 'leftSquareBracket2RightSquareBracket',
    '[3]': 'leftSquareBracket3RightSquareBracket',
    '[4]': 'leftSquareBracket4RightSquareBracket',
    '5': 'n5',
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
