// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_metadata_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModelMetadataResponse extends ModelMetadataResponse {
  @override
  final BuiltList<ModelMetadata> metadata;

  factory _$ModelMetadataResponse(
          [void Function(ModelMetadataResponseBuilder)? updates]) =>
      (ModelMetadataResponseBuilder()..update(updates))._build();

  _$ModelMetadataResponse._({required this.metadata}) : super._();
  @override
  ModelMetadataResponse rebuild(
          void Function(ModelMetadataResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModelMetadataResponseBuilder toBuilder() =>
      ModelMetadataResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModelMetadataResponse && metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModelMetadataResponse')
          ..add('metadata', metadata))
        .toString();
  }
}

class ModelMetadataResponseBuilder
    implements Builder<ModelMetadataResponse, ModelMetadataResponseBuilder> {
  _$ModelMetadataResponse? _$v;

  ListBuilder<ModelMetadata>? _metadata;
  ListBuilder<ModelMetadata> get metadata =>
      _$this._metadata ??= ListBuilder<ModelMetadata>();
  set metadata(ListBuilder<ModelMetadata>? metadata) =>
      _$this._metadata = metadata;

  ModelMetadataResponseBuilder() {
    ModelMetadataResponse._defaults(this);
  }

  ModelMetadataResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _metadata = $v.metadata.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModelMetadataResponse other) {
    _$v = other as _$ModelMetadataResponse;
  }

  @override
  void update(void Function(ModelMetadataResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModelMetadataResponse build() => _build();

  _$ModelMetadataResponse _build() {
    _$ModelMetadataResponse _$result;
    try {
      _$result = _$v ??
          _$ModelMetadataResponse._(
            metadata: metadata.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        metadata.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ModelMetadataResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
