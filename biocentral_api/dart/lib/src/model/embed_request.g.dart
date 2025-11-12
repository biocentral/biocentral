// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmbedRequest extends EmbedRequest {
  @override
  final String embedderName;
  @override
  final bool? reduce;
  @override
  final BuiltMap<String, String> sequenceData;
  @override
  final bool? useHalfPrecision;

  factory _$EmbedRequest([void Function(EmbedRequestBuilder)? updates]) =>
      (EmbedRequestBuilder()..update(updates))._build();

  _$EmbedRequest._(
      {required this.embedderName,
      this.reduce,
      required this.sequenceData,
      this.useHalfPrecision})
      : super._();
  @override
  EmbedRequest rebuild(void Function(EmbedRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmbedRequestBuilder toBuilder() => EmbedRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmbedRequest &&
        embedderName == other.embedderName &&
        reduce == other.reduce &&
        sequenceData == other.sequenceData &&
        useHalfPrecision == other.useHalfPrecision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, reduce.hashCode);
    _$hash = $jc(_$hash, sequenceData.hashCode);
    _$hash = $jc(_$hash, useHalfPrecision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmbedRequest')
          ..add('embedderName', embedderName)
          ..add('reduce', reduce)
          ..add('sequenceData', sequenceData)
          ..add('useHalfPrecision', useHalfPrecision))
        .toString();
  }
}

class EmbedRequestBuilder
    implements Builder<EmbedRequest, EmbedRequestBuilder> {
  _$EmbedRequest? _$v;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  bool? _reduce;
  bool? get reduce => _$this._reduce;
  set reduce(bool? reduce) => _$this._reduce = reduce;

  MapBuilder<String, String>? _sequenceData;
  MapBuilder<String, String> get sequenceData =>
      _$this._sequenceData ??= MapBuilder<String, String>();
  set sequenceData(MapBuilder<String, String>? sequenceData) =>
      _$this._sequenceData = sequenceData;

  bool? _useHalfPrecision;
  bool? get useHalfPrecision => _$this._useHalfPrecision;
  set useHalfPrecision(bool? useHalfPrecision) =>
      _$this._useHalfPrecision = useHalfPrecision;

  EmbedRequestBuilder() {
    EmbedRequest._defaults(this);
  }

  EmbedRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _embedderName = $v.embedderName;
      _reduce = $v.reduce;
      _sequenceData = $v.sequenceData.toBuilder();
      _useHalfPrecision = $v.useHalfPrecision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmbedRequest other) {
    _$v = other as _$EmbedRequest;
  }

  @override
  void update(void Function(EmbedRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmbedRequest build() => _build();

  _$EmbedRequest _build() {
    _$EmbedRequest _$result;
    try {
      _$result = _$v ??
          _$EmbedRequest._(
            embedderName: BuiltValueNullFieldError.checkNotNull(
                embedderName, r'EmbedRequest', 'embedderName'),
            reduce: reduce,
            sequenceData: sequenceData.build(),
            useHalfPrecision: useHalfPrecision,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sequenceData';
        sequenceData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EmbedRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
