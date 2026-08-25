// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_embeddings_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddEmbeddingsResponse extends AddEmbeddingsResponse {
  @override
  final bool success;

  factory _$AddEmbeddingsResponse(
          [void Function(AddEmbeddingsResponseBuilder)? updates]) =>
      (AddEmbeddingsResponseBuilder()..update(updates))._build();

  _$AddEmbeddingsResponse._({required this.success}) : super._();
  @override
  AddEmbeddingsResponse rebuild(
          void Function(AddEmbeddingsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddEmbeddingsResponseBuilder toBuilder() =>
      AddEmbeddingsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddEmbeddingsResponse && success == other.success;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AddEmbeddingsResponse')
          ..add('success', success))
        .toString();
  }
}

class AddEmbeddingsResponseBuilder
    implements Builder<AddEmbeddingsResponse, AddEmbeddingsResponseBuilder> {
  _$AddEmbeddingsResponse? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  AddEmbeddingsResponseBuilder() {
    AddEmbeddingsResponse._defaults(this);
  }

  AddEmbeddingsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddEmbeddingsResponse other) {
    _$v = other as _$AddEmbeddingsResponse;
  }

  @override
  void update(void Function(AddEmbeddingsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddEmbeddingsResponse build() => _build();

  _$AddEmbeddingsResponse _build() {
    final _$result = _$v ??
        _$AddEmbeddingsResponse._(
          success: BuiltValueNullFieldError.checkNotNull(
              success, r'AddEmbeddingsResponse', 'success'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
