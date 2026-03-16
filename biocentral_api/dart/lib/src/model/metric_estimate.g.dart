// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_estimate.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MetricEstimate extends MetricEstimate {
  @override
  final String name;
  @override
  final num mean;
  @override
  final num lower;
  @override
  final num upper;

  factory _$MetricEstimate([void Function(MetricEstimateBuilder)? updates]) =>
      (MetricEstimateBuilder()..update(updates))._build();

  _$MetricEstimate._(
      {required this.name,
      required this.mean,
      required this.lower,
      required this.upper})
      : super._();
  @override
  MetricEstimate rebuild(void Function(MetricEstimateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MetricEstimateBuilder toBuilder() => MetricEstimateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MetricEstimate &&
        name == other.name &&
        mean == other.mean &&
        lower == other.lower &&
        upper == other.upper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, mean.hashCode);
    _$hash = $jc(_$hash, lower.hashCode);
    _$hash = $jc(_$hash, upper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MetricEstimate')
          ..add('name', name)
          ..add('mean', mean)
          ..add('lower', lower)
          ..add('upper', upper))
        .toString();
  }
}

class MetricEstimateBuilder
    implements Builder<MetricEstimate, MetricEstimateBuilder> {
  _$MetricEstimate? _$v;

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

  MetricEstimateBuilder() {
    MetricEstimate._defaults(this);
  }

  MetricEstimateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _mean = $v.mean;
      _lower = $v.lower;
      _upper = $v.upper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MetricEstimate other) {
    _$v = other as _$MetricEstimate;
  }

  @override
  void update(void Function(MetricEstimateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MetricEstimate build() => _build();

  _$MetricEstimate _build() {
    final _$result = _$v ??
        _$MetricEstimate._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MetricEstimate', 'name'),
          mean: BuiltValueNullFieldError.checkNotNull(
              mean, r'MetricEstimate', 'mean'),
          lower: BuiltValueNullFieldError.checkNotNull(
              lower, r'MetricEstimate', 'lower'),
          upper: BuiltValueNullFieldError.checkNotNull(
              upper, r'MetricEstimate', 'upper'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
