// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaxonomyItem extends TaxonomyItem {
  @override
  final int taxonomyId;
  @override
  final String name;
  @override
  final String family;

  factory _$TaxonomyItem([void Function(TaxonomyItemBuilder)? updates]) =>
      (TaxonomyItemBuilder()..update(updates))._build();

  _$TaxonomyItem._(
      {required this.taxonomyId, required this.name, required this.family})
      : super._();
  @override
  TaxonomyItem rebuild(void Function(TaxonomyItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaxonomyItemBuilder toBuilder() => TaxonomyItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaxonomyItem &&
        taxonomyId == other.taxonomyId &&
        name == other.name &&
        family == other.family;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taxonomyId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, family.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaxonomyItem')
          ..add('taxonomyId', taxonomyId)
          ..add('name', name)
          ..add('family', family))
        .toString();
  }
}

class TaxonomyItemBuilder
    implements Builder<TaxonomyItem, TaxonomyItemBuilder> {
  _$TaxonomyItem? _$v;

  int? _taxonomyId;
  int? get taxonomyId => _$this._taxonomyId;
  set taxonomyId(int? taxonomyId) => _$this._taxonomyId = taxonomyId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _family;
  String? get family => _$this._family;
  set family(String? family) => _$this._family = family;

  TaxonomyItemBuilder() {
    TaxonomyItem._defaults(this);
  }

  TaxonomyItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taxonomyId = $v.taxonomyId;
      _name = $v.name;
      _family = $v.family;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaxonomyItem other) {
    _$v = other as _$TaxonomyItem;
  }

  @override
  void update(void Function(TaxonomyItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaxonomyItem build() => _build();

  _$TaxonomyItem _build() {
    final _$result = _$v ??
        _$TaxonomyItem._(
          taxonomyId: BuiltValueNullFieldError.checkNotNull(
              taxonomyId, r'TaxonomyItem', 'taxonomyId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TaxonomyItem', 'name'),
          family: BuiltValueNullFieldError.checkNotNull(
              family, r'TaxonomyItem', 'family'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
