// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_hbi_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SplitHBIRequest extends SplitHBIRequest {
  @override
  final BuiltMap<String, String> trainSeqs;
  @override
  final BuiltMap<String, String> querySeqs;
  @override
  final BuiltMap<String, JsonObject?> trainLabels;
  @override
  final BuiltMap<String, JsonObject?> queryLabels;
  @override
  final num? evalueCutoff;
  @override
  final num? minSeqId;
  @override
  final bool? isNumeric;
  @override
  final int? iterations;

  factory _$SplitHBIRequest([void Function(SplitHBIRequestBuilder)? updates]) =>
      (SplitHBIRequestBuilder()..update(updates))._build();

  _$SplitHBIRequest._(
      {required this.trainSeqs,
      required this.querySeqs,
      required this.trainLabels,
      required this.queryLabels,
      this.evalueCutoff,
      this.minSeqId,
      this.isNumeric,
      this.iterations})
      : super._();
  @override
  SplitHBIRequest rebuild(void Function(SplitHBIRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SplitHBIRequestBuilder toBuilder() => SplitHBIRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SplitHBIRequest &&
        trainSeqs == other.trainSeqs &&
        querySeqs == other.querySeqs &&
        trainLabels == other.trainLabels &&
        queryLabels == other.queryLabels &&
        evalueCutoff == other.evalueCutoff &&
        minSeqId == other.minSeqId &&
        isNumeric == other.isNumeric &&
        iterations == other.iterations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trainSeqs.hashCode);
    _$hash = $jc(_$hash, querySeqs.hashCode);
    _$hash = $jc(_$hash, trainLabels.hashCode);
    _$hash = $jc(_$hash, queryLabels.hashCode);
    _$hash = $jc(_$hash, evalueCutoff.hashCode);
    _$hash = $jc(_$hash, minSeqId.hashCode);
    _$hash = $jc(_$hash, isNumeric.hashCode);
    _$hash = $jc(_$hash, iterations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SplitHBIRequest')
          ..add('trainSeqs', trainSeqs)
          ..add('querySeqs', querySeqs)
          ..add('trainLabels', trainLabels)
          ..add('queryLabels', queryLabels)
          ..add('evalueCutoff', evalueCutoff)
          ..add('minSeqId', minSeqId)
          ..add('isNumeric', isNumeric)
          ..add('iterations', iterations))
        .toString();
  }
}

class SplitHBIRequestBuilder
    implements Builder<SplitHBIRequest, SplitHBIRequestBuilder> {
  _$SplitHBIRequest? _$v;

  MapBuilder<String, String>? _trainSeqs;
  MapBuilder<String, String> get trainSeqs =>
      _$this._trainSeqs ??= MapBuilder<String, String>();
  set trainSeqs(MapBuilder<String, String>? trainSeqs) =>
      _$this._trainSeqs = trainSeqs;

  MapBuilder<String, String>? _querySeqs;
  MapBuilder<String, String> get querySeqs =>
      _$this._querySeqs ??= MapBuilder<String, String>();
  set querySeqs(MapBuilder<String, String>? querySeqs) =>
      _$this._querySeqs = querySeqs;

  MapBuilder<String, JsonObject?>? _trainLabels;
  MapBuilder<String, JsonObject?> get trainLabels =>
      _$this._trainLabels ??= MapBuilder<String, JsonObject?>();
  set trainLabels(MapBuilder<String, JsonObject?>? trainLabels) =>
      _$this._trainLabels = trainLabels;

  MapBuilder<String, JsonObject?>? _queryLabels;
  MapBuilder<String, JsonObject?> get queryLabels =>
      _$this._queryLabels ??= MapBuilder<String, JsonObject?>();
  set queryLabels(MapBuilder<String, JsonObject?>? queryLabels) =>
      _$this._queryLabels = queryLabels;

  num? _evalueCutoff;
  num? get evalueCutoff => _$this._evalueCutoff;
  set evalueCutoff(num? evalueCutoff) => _$this._evalueCutoff = evalueCutoff;

  num? _minSeqId;
  num? get minSeqId => _$this._minSeqId;
  set minSeqId(num? minSeqId) => _$this._minSeqId = minSeqId;

  bool? _isNumeric;
  bool? get isNumeric => _$this._isNumeric;
  set isNumeric(bool? isNumeric) => _$this._isNumeric = isNumeric;

  int? _iterations;
  int? get iterations => _$this._iterations;
  set iterations(int? iterations) => _$this._iterations = iterations;

  SplitHBIRequestBuilder() {
    SplitHBIRequest._defaults(this);
  }

  SplitHBIRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trainSeqs = $v.trainSeqs.toBuilder();
      _querySeqs = $v.querySeqs.toBuilder();
      _trainLabels = $v.trainLabels.toBuilder();
      _queryLabels = $v.queryLabels.toBuilder();
      _evalueCutoff = $v.evalueCutoff;
      _minSeqId = $v.minSeqId;
      _isNumeric = $v.isNumeric;
      _iterations = $v.iterations;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SplitHBIRequest other) {
    _$v = other as _$SplitHBIRequest;
  }

  @override
  void update(void Function(SplitHBIRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SplitHBIRequest build() => _build();

  _$SplitHBIRequest _build() {
    _$SplitHBIRequest _$result;
    try {
      _$result = _$v ??
          _$SplitHBIRequest._(
            trainSeqs: trainSeqs.build(),
            querySeqs: querySeqs.build(),
            trainLabels: trainLabels.build(),
            queryLabels: queryLabels.build(),
            evalueCutoff: evalueCutoff,
            minSeqId: minSeqId,
            isNumeric: isNumeric,
            iterations: iterations,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'trainSeqs';
        trainSeqs.build();
        _$failedField = 'querySeqs';
        querySeqs.build();
        _$failedField = 'trainLabels';
        trainLabels.build();
        _$failedField = 'queryLabels';
        queryLabels.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SplitHBIRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
