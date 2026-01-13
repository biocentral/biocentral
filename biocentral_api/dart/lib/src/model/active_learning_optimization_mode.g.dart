// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_optimization_mode.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ActiveLearningOptimizationMode _$INTERVAL =
    const ActiveLearningOptimizationMode._('INTERVAL');
const ActiveLearningOptimizationMode _$VALUE =
    const ActiveLearningOptimizationMode._('VALUE');
const ActiveLearningOptimizationMode _$MAXIMIZE =
    const ActiveLearningOptimizationMode._('MAXIMIZE');
const ActiveLearningOptimizationMode _$MINIMIZE =
    const ActiveLearningOptimizationMode._('MINIMIZE');
const ActiveLearningOptimizationMode _$DISCRETE =
    const ActiveLearningOptimizationMode._('DISCRETE');

ActiveLearningOptimizationMode _$valueOf(String name) {
  switch (name) {
    case 'INTERVAL':
      return _$INTERVAL;
    case 'VALUE':
      return _$VALUE;
    case 'MAXIMIZE':
      return _$MAXIMIZE;
    case 'MINIMIZE':
      return _$MINIMIZE;
    case 'DISCRETE':
      return _$DISCRETE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ActiveLearningOptimizationMode> _$values = BuiltSet<
    ActiveLearningOptimizationMode>(const <ActiveLearningOptimizationMode>[
  _$INTERVAL,
  _$VALUE,
  _$MAXIMIZE,
  _$MINIMIZE,
  _$DISCRETE,
]);

class _$ActiveLearningOptimizationModeMeta {
  const _$ActiveLearningOptimizationModeMeta();
  ActiveLearningOptimizationMode get INTERVAL => _$INTERVAL;
  ActiveLearningOptimizationMode get VALUE => _$VALUE;
  ActiveLearningOptimizationMode get MAXIMIZE => _$MAXIMIZE;
  ActiveLearningOptimizationMode get MINIMIZE => _$MINIMIZE;
  ActiveLearningOptimizationMode get DISCRETE => _$DISCRETE;
  ActiveLearningOptimizationMode valueOf(String name) => _$valueOf(name);
  BuiltSet<ActiveLearningOptimizationMode> get values => _$values;
}

mixin _$ActiveLearningOptimizationModeMixin {
  // ignore: non_constant_identifier_names
  _$ActiveLearningOptimizationModeMeta get ActiveLearningOptimizationMode =>
      const _$ActiveLearningOptimizationModeMeta();
}

Serializer<ActiveLearningOptimizationMode>
    _$activeLearningOptimizationModeSerializer =
    _$ActiveLearningOptimizationModeSerializer();

class _$ActiveLearningOptimizationModeSerializer
    implements PrimitiveSerializer<ActiveLearningOptimizationMode> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INTERVAL': 'INTERVAL',
    'VALUE': 'VALUE',
    'MAXIMIZE': 'MAXIMIZE',
    'MINIMIZE': 'MINIMIZE',
    'DISCRETE': 'DISCRETE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INTERVAL': 'INTERVAL',
    'VALUE': 'VALUE',
    'MAXIMIZE': 'MAXIMIZE',
    'MINIMIZE': 'MINIMIZE',
    'DISCRETE': 'DISCRETE',
  };

  @override
  final Iterable<Type> types = const <Type>[ActiveLearningOptimizationMode];
  @override
  final String wireName = 'ActiveLearningOptimizationMode';

  @override
  Object serialize(
          Serializers serializers, ActiveLearningOptimizationMode object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ActiveLearningOptimizationMode deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ActiveLearningOptimizationMode.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
