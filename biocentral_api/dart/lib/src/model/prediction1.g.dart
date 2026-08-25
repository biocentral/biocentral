// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Prediction1 extends Prediction1 {
  @override
  final AnyOf anyOf;

  factory _$Prediction1([void Function(Prediction1Builder)? updates]) =>
      (Prediction1Builder()..update(updates))._build();

  _$Prediction1._({required this.anyOf}) : super._();
  @override
  Prediction1 rebuild(void Function(Prediction1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Prediction1Builder toBuilder() => Prediction1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Prediction1 && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'Prediction1')..add('anyOf', anyOf))
        .toString();
  }
}

class Prediction1Builder implements Builder<Prediction1, Prediction1Builder> {
  _$Prediction1? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  Prediction1Builder() {
    Prediction1._defaults(this);
  }

  Prediction1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Prediction1 other) {
    _$v = other as _$Prediction1;
  }

  @override
  void update(void Function(Prediction1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Prediction1 build() => _build();

  _$Prediction1 _build() {
    final _$result = _$v ??
        _$Prediction1._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'Prediction1', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
