// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcd_std.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$McdStd extends McdStd {
  @override
  final AnyOf anyOf;

  factory _$McdStd([void Function(McdStdBuilder)? updates]) =>
      (McdStdBuilder()..update(updates))._build();

  _$McdStd._({required this.anyOf}) : super._();
  @override
  McdStd rebuild(void Function(McdStdBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  McdStdBuilder toBuilder() => McdStdBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is McdStd && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'McdStd')..add('anyOf', anyOf))
        .toString();
  }
}

class McdStdBuilder implements Builder<McdStd, McdStdBuilder> {
  _$McdStd? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  McdStdBuilder() {
    McdStd._defaults(this);
  }

  McdStdBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(McdStd other) {
    _$v = other as _$McdStd;
  }

  @override
  void update(void Function(McdStdBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  McdStd build() => _build();

  _$McdStd _build() {
    final _$result = _$v ??
        _$McdStd._(
          anyOf:
              BuiltValueNullFieldError.checkNotNull(anyOf, r'McdStd', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
