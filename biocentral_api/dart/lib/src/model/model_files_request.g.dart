// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_files_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModelFilesRequest extends ModelFilesRequest {
  @override
  final String modelHash;

  factory _$ModelFilesRequest(
          [void Function(ModelFilesRequestBuilder)? updates]) =>
      (ModelFilesRequestBuilder()..update(updates))._build();

  _$ModelFilesRequest._({required this.modelHash}) : super._();
  @override
  ModelFilesRequest rebuild(void Function(ModelFilesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModelFilesRequestBuilder toBuilder() =>
      ModelFilesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModelFilesRequest && modelHash == other.modelHash;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, modelHash.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModelFilesRequest')
          ..add('modelHash', modelHash))
        .toString();
  }
}

class ModelFilesRequestBuilder
    implements Builder<ModelFilesRequest, ModelFilesRequestBuilder> {
  _$ModelFilesRequest? _$v;

  String? _modelHash;
  String? get modelHash => _$this._modelHash;
  set modelHash(String? modelHash) => _$this._modelHash = modelHash;

  ModelFilesRequestBuilder() {
    ModelFilesRequest._defaults(this);
  }

  ModelFilesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _modelHash = $v.modelHash;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModelFilesRequest other) {
    _$v = other as _$ModelFilesRequest;
  }

  @override
  void update(void Function(ModelFilesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModelFilesRequest build() => _build();

  _$ModelFilesRequest _build() {
    final _$result = _$v ??
        _$ModelFilesRequest._(
          modelHash: BuiltValueNullFieldError.checkNotNull(
              modelHash, r'ModelFilesRequest', 'modelHash'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
