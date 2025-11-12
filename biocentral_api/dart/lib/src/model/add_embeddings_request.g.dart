// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_embeddings_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddEmbeddingsRequest extends AddEmbeddingsRequest {
  @override
  final String h5Bytes;
  @override
  final String sequences;
  @override
  final String embedderName;
  @override
  final bool reduced;

  factory _$AddEmbeddingsRequest(
          [void Function(AddEmbeddingsRequestBuilder)? updates]) =>
      (AddEmbeddingsRequestBuilder()..update(updates))._build();

  _$AddEmbeddingsRequest._(
      {required this.h5Bytes,
      required this.sequences,
      required this.embedderName,
      required this.reduced})
      : super._();
  @override
  AddEmbeddingsRequest rebuild(
          void Function(AddEmbeddingsRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddEmbeddingsRequestBuilder toBuilder() =>
      AddEmbeddingsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddEmbeddingsRequest &&
        h5Bytes == other.h5Bytes &&
        sequences == other.sequences &&
        embedderName == other.embedderName &&
        reduced == other.reduced;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, h5Bytes.hashCode);
    _$hash = $jc(_$hash, sequences.hashCode);
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, reduced.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AddEmbeddingsRequest')
          ..add('h5Bytes', h5Bytes)
          ..add('sequences', sequences)
          ..add('embedderName', embedderName)
          ..add('reduced', reduced))
        .toString();
  }
}

class AddEmbeddingsRequestBuilder
    implements Builder<AddEmbeddingsRequest, AddEmbeddingsRequestBuilder> {
  _$AddEmbeddingsRequest? _$v;

  String? _h5Bytes;
  String? get h5Bytes => _$this._h5Bytes;
  set h5Bytes(String? h5Bytes) => _$this._h5Bytes = h5Bytes;

  String? _sequences;
  String? get sequences => _$this._sequences;
  set sequences(String? sequences) => _$this._sequences = sequences;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  bool? _reduced;
  bool? get reduced => _$this._reduced;
  set reduced(bool? reduced) => _$this._reduced = reduced;

  AddEmbeddingsRequestBuilder() {
    AddEmbeddingsRequest._defaults(this);
  }

  AddEmbeddingsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _h5Bytes = $v.h5Bytes;
      _sequences = $v.sequences;
      _embedderName = $v.embedderName;
      _reduced = $v.reduced;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddEmbeddingsRequest other) {
    _$v = other as _$AddEmbeddingsRequest;
  }

  @override
  void update(void Function(AddEmbeddingsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddEmbeddingsRequest build() => _build();

  _$AddEmbeddingsRequest _build() {
    final _$result = _$v ??
        _$AddEmbeddingsRequest._(
          h5Bytes: BuiltValueNullFieldError.checkNotNull(
              h5Bytes, r'AddEmbeddingsRequest', 'h5Bytes'),
          sequences: BuiltValueNullFieldError.checkNotNull(
              sequences, r'AddEmbeddingsRequest', 'sequences'),
          embedderName: BuiltValueNullFieldError.checkNotNull(
              embedderName, r'AddEmbeddingsRequest', 'embedderName'),
          reduced: BuiltValueNullFieldError.checkNotNull(
              reduced, r'AddEmbeddingsRequest', 'reduced'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
