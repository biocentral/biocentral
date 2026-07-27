// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaxonomyRequest extends TaxonomyRequest {
  @override
  final BuiltList<int> taxonomyIds;

  factory _$TaxonomyRequest([void Function(TaxonomyRequestBuilder)? updates]) =>
      (TaxonomyRequestBuilder()..update(updates))._build();

  _$TaxonomyRequest._({required this.taxonomyIds}) : super._();
  @override
  TaxonomyRequest rebuild(void Function(TaxonomyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaxonomyRequestBuilder toBuilder() => TaxonomyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaxonomyRequest && taxonomyIds == other.taxonomyIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taxonomyIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaxonomyRequest')
          ..add('taxonomyIds', taxonomyIds))
        .toString();
  }
}

class TaxonomyRequestBuilder
    implements Builder<TaxonomyRequest, TaxonomyRequestBuilder> {
  _$TaxonomyRequest? _$v;

  ListBuilder<int>? _taxonomyIds;
  ListBuilder<int> get taxonomyIds =>
      _$this._taxonomyIds ??= ListBuilder<int>();
  set taxonomyIds(ListBuilder<int>? taxonomyIds) =>
      _$this._taxonomyIds = taxonomyIds;

  TaxonomyRequestBuilder() {
    TaxonomyRequest._defaults(this);
  }

  TaxonomyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taxonomyIds = $v.taxonomyIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaxonomyRequest other) {
    _$v = other as _$TaxonomyRequest;
  }

  @override
  void update(void Function(TaxonomyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaxonomyRequest build() => _build();

  _$TaxonomyRequest _build() {
    _$TaxonomyRequest _$result;
    try {
      _$result = _$v ??
          _$TaxonomyRequest._(
            taxonomyIds: taxonomyIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taxonomyIds';
        taxonomyIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TaxonomyRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
