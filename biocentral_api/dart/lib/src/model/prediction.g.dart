// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Prediction extends Prediction {
  @override
  final String modelName;
  @override
  final String predictionName;
  @override
  final String protocol;
  @override
  final JsonObject? value;
  @override
  final num? valueLower;
  @override
  final num? valueUpper;

  factory _$Prediction([void Function(PredictionBuilder)? updates]) =>
      (PredictionBuilder()..update(updates))._build();

  _$Prediction._(
      {required this.modelName,
      required this.predictionName,
      required this.protocol,
      this.value,
      this.valueLower,
      this.valueUpper})
      : super._();
  @override
  Prediction rebuild(void Function(PredictionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PredictionBuilder toBuilder() => PredictionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Prediction &&
        modelName == other.modelName &&
        predictionName == other.predictionName &&
        protocol == other.protocol &&
        value == other.value &&
        valueLower == other.valueLower &&
        valueUpper == other.valueUpper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, modelName.hashCode);
    _$hash = $jc(_$hash, predictionName.hashCode);
    _$hash = $jc(_$hash, protocol.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, valueLower.hashCode);
    _$hash = $jc(_$hash, valueUpper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Prediction')
          ..add('modelName', modelName)
          ..add('predictionName', predictionName)
          ..add('protocol', protocol)
          ..add('value', value)
          ..add('valueLower', valueLower)
          ..add('valueUpper', valueUpper))
        .toString();
  }
}

class PredictionBuilder implements Builder<Prediction, PredictionBuilder> {
  _$Prediction? _$v;

  String? _modelName;
  String? get modelName => _$this._modelName;
  set modelName(String? modelName) => _$this._modelName = modelName;

  String? _predictionName;
  String? get predictionName => _$this._predictionName;
  set predictionName(String? predictionName) =>
      _$this._predictionName = predictionName;

  String? _protocol;
  String? get protocol => _$this._protocol;
  set protocol(String? protocol) => _$this._protocol = protocol;

  JsonObject? _value;
  JsonObject? get value => _$this._value;
  set value(JsonObject? value) => _$this._value = value;

  num? _valueLower;
  num? get valueLower => _$this._valueLower;
  set valueLower(num? valueLower) => _$this._valueLower = valueLower;

  num? _valueUpper;
  num? get valueUpper => _$this._valueUpper;
  set valueUpper(num? valueUpper) => _$this._valueUpper = valueUpper;

  PredictionBuilder() {
    Prediction._defaults(this);
  }

  PredictionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _modelName = $v.modelName;
      _predictionName = $v.predictionName;
      _protocol = $v.protocol;
      _value = $v.value;
      _valueLower = $v.valueLower;
      _valueUpper = $v.valueUpper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Prediction other) {
    _$v = other as _$Prediction;
  }

  @override
  void update(void Function(PredictionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Prediction build() => _build();

  _$Prediction _build() {
    final _$result = _$v ??
        _$Prediction._(
          modelName: BuiltValueNullFieldError.checkNotNull(
              modelName, r'Prediction', 'modelName'),
          predictionName: BuiltValueNullFieldError.checkNotNull(
              predictionName, r'Prediction', 'predictionName'),
          protocol: BuiltValueNullFieldError.checkNotNull(
              protocol, r'Prediction', 'protocol'),
          value: value,
          valueLower: valueLower,
          valueUpper: valueUpper,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
