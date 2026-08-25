// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaxonomyResponse extends TaxonomyResponse {
  @override
  final BuiltList<TaxonomyItem> taxonomy;

  factory _$TaxonomyResponse(
          [void Function(TaxonomyResponseBuilder)? updates]) =>
      (TaxonomyResponseBuilder()..update(updates))._build();

  _$TaxonomyResponse._({required this.taxonomy}) : super._();
  @override
  TaxonomyResponse rebuild(void Function(TaxonomyResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaxonomyResponseBuilder toBuilder() =>
      TaxonomyResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaxonomyResponse && taxonomy == other.taxonomy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taxonomy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaxonomyResponse')
          ..add('taxonomy', taxonomy))
        .toString();
  }
}

class TaxonomyResponseBuilder
    implements Builder<TaxonomyResponse, TaxonomyResponseBuilder> {
  _$TaxonomyResponse? _$v;

  ListBuilder<TaxonomyItem>? _taxonomy;
  ListBuilder<TaxonomyItem> get taxonomy =>
      _$this._taxonomy ??= ListBuilder<TaxonomyItem>();
  set taxonomy(ListBuilder<TaxonomyItem>? taxonomy) =>
      _$this._taxonomy = taxonomy;

  TaxonomyResponseBuilder() {
    TaxonomyResponse._defaults(this);
  }

  TaxonomyResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taxonomy = $v.taxonomy.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaxonomyResponse other) {
    _$v = other as _$TaxonomyResponse;
  }

  @override
  void update(void Function(TaxonomyResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaxonomyResponse build() => _build();

  _$TaxonomyResponse _build() {
    _$TaxonomyResponse _$result;
    try {
      _$result = _$v ??
          _$TaxonomyResponse._(
            taxonomy: taxonomy.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taxonomy';
        taxonomy.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TaxonomyResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
