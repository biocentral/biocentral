// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcd_lower_bound.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$McdLowerBound extends McdLowerBound {
  @override
  final AnyOf anyOf;

  factory _$McdLowerBound([void Function(McdLowerBoundBuilder)? updates]) =>
      (McdLowerBoundBuilder()..update(updates))._build();

  _$McdLowerBound._({required this.anyOf}) : super._();
  @override
  McdLowerBound rebuild(void Function(McdLowerBoundBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  McdLowerBoundBuilder toBuilder() => McdLowerBoundBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is McdLowerBound && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'McdLowerBound')..add('anyOf', anyOf))
        .toString();
  }
}

class McdLowerBoundBuilder
    implements Builder<McdLowerBound, McdLowerBoundBuilder> {
  _$McdLowerBound? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  McdLowerBoundBuilder() {
    McdLowerBound._defaults(this);
  }

  McdLowerBoundBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(McdLowerBound other) {
    _$v = other as _$McdLowerBound;
  }

  @override
  void update(void Function(McdLowerBoundBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  McdLowerBound build() => _build();

  _$McdLowerBound _build() {
    final _$result = _$v ??
        _$McdLowerBound._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'McdLowerBound', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
