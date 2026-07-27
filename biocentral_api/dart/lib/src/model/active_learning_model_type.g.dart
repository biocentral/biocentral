// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_model_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ActiveLearningModelType _$GAUSSIAN_PROCESS =
    const ActiveLearningModelType._('GAUSSIAN_PROCESS');
const ActiveLearningModelType _$FNN_MCD =
    const ActiveLearningModelType._('FNN_MCD');
const ActiveLearningModelType _$RANDOM =
    const ActiveLearningModelType._('RANDOM');

ActiveLearningModelType _$valueOf(String name) {
  switch (name) {
    case 'GAUSSIAN_PROCESS':
      return _$GAUSSIAN_PROCESS;
    case 'FNN_MCD':
      return _$FNN_MCD;
    case 'RANDOM':
      return _$RANDOM;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ActiveLearningModelType> _$values =
    BuiltSet<ActiveLearningModelType>(const <ActiveLearningModelType>[
  _$GAUSSIAN_PROCESS,
  _$FNN_MCD,
  _$RANDOM,
]);

class _$ActiveLearningModelTypeMeta {
  const _$ActiveLearningModelTypeMeta();
  ActiveLearningModelType get GAUSSIAN_PROCESS => _$GAUSSIAN_PROCESS;
  ActiveLearningModelType get FNN_MCD => _$FNN_MCD;
  ActiveLearningModelType get RANDOM => _$RANDOM;
  ActiveLearningModelType valueOf(String name) => _$valueOf(name);
  BuiltSet<ActiveLearningModelType> get values => _$values;
}

mixin _$ActiveLearningModelTypeMixin {
  // ignore: non_constant_identifier_names
  _$ActiveLearningModelTypeMeta get ActiveLearningModelType =>
      const _$ActiveLearningModelTypeMeta();
}

Serializer<ActiveLearningModelType> _$activeLearningModelTypeSerializer =
    _$ActiveLearningModelTypeSerializer();

class _$ActiveLearningModelTypeSerializer
    implements PrimitiveSerializer<ActiveLearningModelType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'GAUSSIAN_PROCESS': 'GAUSSIAN_PROCESS',
    'FNN_MCD': 'FNN_MCD',
    'RANDOM': 'RANDOM',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'GAUSSIAN_PROCESS': 'GAUSSIAN_PROCESS',
    'FNN_MCD': 'FNN_MCD',
    'RANDOM': 'RANDOM',
  };

  @override
  final Iterable<Type> types = const <Type>[ActiveLearningModelType];
  @override
  final String wireName = 'ActiveLearningModelType';

  @override
  Object serialize(Serializers serializers, ActiveLearningModelType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ActiveLearningModelType deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ActiveLearningModelType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
