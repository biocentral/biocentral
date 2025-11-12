// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_missing_embeddings_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetMissingEmbeddingsRequest extends GetMissingEmbeddingsRequest {
  @override
  final String sequences;
  @override
  final String embedderName;
  @override
  final bool reduced;

  factory _$GetMissingEmbeddingsRequest(
          [void Function(GetMissingEmbeddingsRequestBuilder)? updates]) =>
      (GetMissingEmbeddingsRequestBuilder()..update(updates))._build();

  _$GetMissingEmbeddingsRequest._(
      {required this.sequences,
      required this.embedderName,
      required this.reduced})
      : super._();
  @override
  GetMissingEmbeddingsRequest rebuild(
          void Function(GetMissingEmbeddingsRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetMissingEmbeddingsRequestBuilder toBuilder() =>
      GetMissingEmbeddingsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetMissingEmbeddingsRequest &&
        sequences == other.sequences &&
        embedderName == other.embedderName &&
        reduced == other.reduced;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sequences.hashCode);
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, reduced.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetMissingEmbeddingsRequest')
          ..add('sequences', sequences)
          ..add('embedderName', embedderName)
          ..add('reduced', reduced))
        .toString();
  }
}

class GetMissingEmbeddingsRequestBuilder
    implements
        Builder<GetMissingEmbeddingsRequest,
            GetMissingEmbeddingsRequestBuilder> {
  _$GetMissingEmbeddingsRequest? _$v;

  String? _sequences;
  String? get sequences => _$this._sequences;
  set sequences(String? sequences) => _$this._sequences = sequences;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  bool? _reduced;
  bool? get reduced => _$this._reduced;
  set reduced(bool? reduced) => _$this._reduced = reduced;

  GetMissingEmbeddingsRequestBuilder() {
    GetMissingEmbeddingsRequest._defaults(this);
  }

  GetMissingEmbeddingsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sequences = $v.sequences;
      _embedderName = $v.embedderName;
      _reduced = $v.reduced;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetMissingEmbeddingsRequest other) {
    _$v = other as _$GetMissingEmbeddingsRequest;
  }

  @override
  void update(void Function(GetMissingEmbeddingsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetMissingEmbeddingsRequest build() => _build();

  _$GetMissingEmbeddingsRequest _build() {
    final _$result = _$v ??
        _$GetMissingEmbeddingsRequest._(
          sequences: BuiltValueNullFieldError.checkNotNull(
              sequences, r'GetMissingEmbeddingsRequest', 'sequences'),
          embedderName: BuiltValueNullFieldError.checkNotNull(
              embedderName, r'GetMissingEmbeddingsRequest', 'embedderName'),
          reduced: BuiltValueNullFieldError.checkNotNull(
              reduced, r'GetMissingEmbeddingsRequest', 'reduced'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
