// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_missing_embeddings_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetMissingEmbeddingsResponse extends GetMissingEmbeddingsResponse {
  @override
  final BuiltList<String> missing;

  factory _$GetMissingEmbeddingsResponse(
          [void Function(GetMissingEmbeddingsResponseBuilder)? updates]) =>
      (GetMissingEmbeddingsResponseBuilder()..update(updates))._build();

  _$GetMissingEmbeddingsResponse._({required this.missing}) : super._();
  @override
  GetMissingEmbeddingsResponse rebuild(
          void Function(GetMissingEmbeddingsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetMissingEmbeddingsResponseBuilder toBuilder() =>
      GetMissingEmbeddingsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetMissingEmbeddingsResponse && missing == other.missing;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, missing.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetMissingEmbeddingsResponse')
          ..add('missing', missing))
        .toString();
  }
}

class GetMissingEmbeddingsResponseBuilder
    implements
        Builder<GetMissingEmbeddingsResponse,
            GetMissingEmbeddingsResponseBuilder> {
  _$GetMissingEmbeddingsResponse? _$v;

  ListBuilder<String>? _missing;
  ListBuilder<String> get missing => _$this._missing ??= ListBuilder<String>();
  set missing(ListBuilder<String>? missing) => _$this._missing = missing;

  GetMissingEmbeddingsResponseBuilder() {
    GetMissingEmbeddingsResponse._defaults(this);
  }

  GetMissingEmbeddingsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _missing = $v.missing.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetMissingEmbeddingsResponse other) {
    _$v = other as _$GetMissingEmbeddingsResponse;
  }

  @override
  void update(void Function(GetMissingEmbeddingsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetMissingEmbeddingsResponse build() => _build();

  _$GetMissingEmbeddingsResponse _build() {
    _$GetMissingEmbeddingsResponse _$result;
    try {
      _$result = _$v ??
          _$GetMissingEmbeddingsResponse._(
            missing: missing.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'missing';
        missing.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetMissingEmbeddingsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
