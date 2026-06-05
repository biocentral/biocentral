// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_prediction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RawPrediction extends RawPrediction {
  @override
  final AnyOf anyOf;

  factory _$RawPrediction([void Function(RawPredictionBuilder)? updates]) =>
      (RawPredictionBuilder()..update(updates))._build();

  _$RawPrediction._({required this.anyOf}) : super._();
  @override
  RawPrediction rebuild(void Function(RawPredictionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RawPredictionBuilder toBuilder() => RawPredictionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RawPrediction && anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RawPrediction')..add('anyOf', anyOf))
        .toString();
  }
}

class RawPredictionBuilder
    implements Builder<RawPrediction, RawPredictionBuilder> {
  _$RawPrediction? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  RawPredictionBuilder() {
    RawPrediction._defaults(this);
  }

  RawPredictionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RawPrediction other) {
    _$v = other as _$RawPrediction;
  }

  @override
  void update(void Function(RawPredictionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RawPrediction build() => _build();

  _$RawPrediction _build() {
    final _$result = _$v ??
        _$RawPrediction._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'RawPrediction', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
