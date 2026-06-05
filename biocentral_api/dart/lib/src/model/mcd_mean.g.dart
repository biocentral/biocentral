// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcd_mean.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$McdMean extends McdMean {
  @override
  final AnyOf anyOf;

  factory _$McdMean([void Function(McdMeanBuilder)? updates]) =>
      (McdMeanBuilder()..update(updates))._build();

  _$McdMean._({required this.anyOf}) : super._();
  @override
  McdMean rebuild(void Function(McdMeanBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  McdMeanBuilder toBuilder() => McdMeanBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is McdMean && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'McdMean')..add('anyOf', anyOf))
        .toString();
  }
}

class McdMeanBuilder implements Builder<McdMean, McdMeanBuilder> {
  _$McdMean? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  McdMeanBuilder() {
    McdMean._defaults(this);
  }

  McdMeanBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(McdMean other) {
    _$v = other as _$McdMean;
  }

  @override
  void update(void Function(McdMeanBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  McdMean build() => _build();

  _$McdMean _build() {
    final _$result = _$v ??
        _$McdMean._(
          anyOf:
              BuiltValueNullFieldError.checkNotNull(anyOf, r'McdMean', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
