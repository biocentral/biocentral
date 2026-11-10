// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mutation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Mutation extends Mutation {
  @override
  final String wt;
  @override
  final int position;
  @override
  final String mt;
  @override
  final bool? oneIndexed;

  factory _$Mutation([void Function(MutationBuilder)? updates]) =>
      (MutationBuilder()..update(updates))._build();

  _$Mutation._(
      {required this.wt,
      required this.position,
      required this.mt,
      this.oneIndexed})
      : super._();
  @override
  Mutation rebuild(void Function(MutationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MutationBuilder toBuilder() => MutationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Mutation &&
        wt == other.wt &&
        position == other.position &&
        mt == other.mt &&
        oneIndexed == other.oneIndexed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, wt.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, mt.hashCode);
    _$hash = $jc(_$hash, oneIndexed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Mutation')
          ..add('wt', wt)
          ..add('position', position)
          ..add('mt', mt)
          ..add('oneIndexed', oneIndexed))
        .toString();
  }
}

class MutationBuilder implements Builder<Mutation, MutationBuilder> {
  _$Mutation? _$v;

  String? _wt;
  String? get wt => _$this._wt;
  set wt(String? wt) => _$this._wt = wt;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  String? _mt;
  String? get mt => _$this._mt;
  set mt(String? mt) => _$this._mt = mt;

  bool? _oneIndexed;
  bool? get oneIndexed => _$this._oneIndexed;
  set oneIndexed(bool? oneIndexed) => _$this._oneIndexed = oneIndexed;

  MutationBuilder() {
    Mutation._defaults(this);
  }

  MutationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _wt = $v.wt;
      _position = $v.position;
      _mt = $v.mt;
      _oneIndexed = $v.oneIndexed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Mutation other) {
    _$v = other as _$Mutation;
  }

  @override
  void update(void Function(MutationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Mutation build() => _build();

  _$Mutation _build() {
    final _$result = _$v ??
        _$Mutation._(
          wt: BuiltValueNullFieldError.checkNotNull(wt, r'Mutation', 'wt'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'Mutation', 'position'),
          mt: BuiltValueNullFieldError.checkNotNull(mt, r'Mutation', 'mt'),
          oneIndexed: oneIndexed,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
