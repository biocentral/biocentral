// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrapped_metric.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BootstrappedMetric extends BootstrappedMetric {
  @override
  final String name;
  @override
  final num mean;
  @override
  final num lower;
  @override
  final num upper;
  @override
  final int iterations;
  @override
  final int sampleSize;
  @override
  final num confidenceLevel;

  factory _$BootstrappedMetric(
          [void Function(BootstrappedMetricBuilder)? updates]) =>
      (BootstrappedMetricBuilder()..update(updates))._build();

  _$BootstrappedMetric._(
      {required this.name,
      required this.mean,
      required this.lower,
      required this.upper,
      required this.iterations,
      required this.sampleSize,
      required this.confidenceLevel})
      : super._();
  @override
  BootstrappedMetric rebuild(
          void Function(BootstrappedMetricBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrappedMetricBuilder toBuilder() =>
      BootstrappedMetricBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrappedMetric &&
        name == other.name &&
        mean == other.mean &&
        lower == other.lower &&
        upper == other.upper &&
        iterations == other.iterations &&
        sampleSize == other.sampleSize &&
        confidenceLevel == other.confidenceLevel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, mean.hashCode);
    _$hash = $jc(_$hash, lower.hashCode);
    _$hash = $jc(_$hash, upper.hashCode);
    _$hash = $jc(_$hash, iterations.hashCode);
    _$hash = $jc(_$hash, sampleSize.hashCode);
    _$hash = $jc(_$hash, confidenceLevel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BootstrappedMetric')
          ..add('name', name)
          ..add('mean', mean)
          ..add('lower', lower)
          ..add('upper', upper)
          ..add('iterations', iterations)
          ..add('sampleSize', sampleSize)
          ..add('confidenceLevel', confidenceLevel))
        .toString();
  }
}

class BootstrappedMetricBuilder
    implements Builder<BootstrappedMetric, BootstrappedMetricBuilder> {
  _$BootstrappedMetric? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _mean;
  num? get mean => _$this._mean;
  set mean(num? mean) => _$this._mean = mean;

  num? _lower;
  num? get lower => _$this._lower;
  set lower(num? lower) => _$this._lower = lower;

  num? _upper;
  num? get upper => _$this._upper;
  set upper(num? upper) => _$this._upper = upper;

  int? _iterations;
  int? get iterations => _$this._iterations;
  set iterations(int? iterations) => _$this._iterations = iterations;

  int? _sampleSize;
  int? get sampleSize => _$this._sampleSize;
  set sampleSize(int? sampleSize) => _$this._sampleSize = sampleSize;

  num? _confidenceLevel;
  num? get confidenceLevel => _$this._confidenceLevel;
  set confidenceLevel(num? confidenceLevel) =>
      _$this._confidenceLevel = confidenceLevel;

  BootstrappedMetricBuilder() {
    BootstrappedMetric._defaults(this);
  }

  BootstrappedMetricBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _mean = $v.mean;
      _lower = $v.lower;
      _upper = $v.upper;
      _iterations = $v.iterations;
      _sampleSize = $v.sampleSize;
      _confidenceLevel = $v.confidenceLevel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BootstrappedMetric other) {
    _$v = other as _$BootstrappedMetric;
  }

  @override
  void update(void Function(BootstrappedMetricBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrappedMetric build() => _build();

  _$BootstrappedMetric _build() {
    final _$result = _$v ??
        _$BootstrappedMetric._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BootstrappedMetric', 'name'),
          mean: BuiltValueNullFieldError.checkNotNull(
              mean, r'BootstrappedMetric', 'mean'),
          lower: BuiltValueNullFieldError.checkNotNull(
              lower, r'BootstrappedMetric', 'lower'),
          upper: BuiltValueNullFieldError.checkNotNull(
              upper, r'BootstrappedMetric', 'upper'),
          iterations: BuiltValueNullFieldError.checkNotNull(
              iterations, r'BootstrappedMetric', 'iterations'),
          sampleSize: BuiltValueNullFieldError.checkNotNull(
              sampleSize, r'BootstrappedMetric', 'sampleSize'),
          confidenceLevel: BuiltValueNullFieldError.checkNotNull(
              confidenceLevel, r'BootstrappedMetric', 'confidenceLevel'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
