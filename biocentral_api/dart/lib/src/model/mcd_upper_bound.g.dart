// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcd_upper_bound.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$McdUpperBound extends McdUpperBound {
  @override
  final AnyOf anyOf;

  factory _$McdUpperBound([void Function(McdUpperBoundBuilder)? updates]) =>
      (McdUpperBoundBuilder()..update(updates))._build();

  _$McdUpperBound._({required this.anyOf}) : super._();
  @override
  McdUpperBound rebuild(void Function(McdUpperBoundBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  McdUpperBoundBuilder toBuilder() => McdUpperBoundBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is McdUpperBound && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'McdUpperBound')..add('anyOf', anyOf))
        .toString();
  }
}

class McdUpperBoundBuilder
    implements Builder<McdUpperBound, McdUpperBoundBuilder> {
  _$McdUpperBound? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  McdUpperBoundBuilder() {
    McdUpperBound._defaults(this);
  }

  McdUpperBoundBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(McdUpperBound other) {
    _$v = other as _$McdUpperBound;
  }

  @override
  void update(void Function(McdUpperBoundBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  McdUpperBound build() => _build();

  _$McdUpperBound _build() {
    final _$result = _$v ??
        _$McdUpperBound._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'McdUpperBound', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
