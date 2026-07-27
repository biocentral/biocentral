// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LocationInner extends LocationInner {
  @override
  final AnyOf anyOf;

  factory _$LocationInner([void Function(LocationInnerBuilder)? updates]) =>
      (LocationInnerBuilder()..update(updates))._build();

  _$LocationInner._({required this.anyOf}) : super._();
  @override
  LocationInner rebuild(void Function(LocationInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LocationInnerBuilder toBuilder() => LocationInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LocationInner && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'LocationInner')..add('anyOf', anyOf))
        .toString();
  }
}

class LocationInnerBuilder
    implements Builder<LocationInner, LocationInnerBuilder> {
  _$LocationInner? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  LocationInnerBuilder() {
    LocationInner._defaults(this);
  }

  LocationInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LocationInner other) {
    _$v = other as _$LocationInner;
  }

  @override
  void update(void Function(LocationInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LocationInner build() => _build();

  _$LocationInner _build() {
    final _$result = _$v ??
        _$LocationInner._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'LocationInner', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
