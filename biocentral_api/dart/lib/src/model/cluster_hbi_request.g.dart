// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cluster_hbi_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClusterHBIRequest extends ClusterHBIRequest {
  @override
  final String datasetHash;
  @override
  final num? sequenceIdentityThreshold;
  @override
  final BuiltMap<String, String>? sequenceData;
  @override
  final BuiltMap<String, JsonObject?> targetData;
  @override
  final bool? isNumeric;
  @override
  final int? iterations;

  factory _$ClusterHBIRequest(
          [void Function(ClusterHBIRequestBuilder)? updates]) =>
      (ClusterHBIRequestBuilder()..update(updates))._build();

  _$ClusterHBIRequest._(
      {required this.datasetHash,
      this.sequenceIdentityThreshold,
      this.sequenceData,
      required this.targetData,
      this.isNumeric,
      this.iterations})
      : super._();
  @override
  ClusterHBIRequest rebuild(void Function(ClusterHBIRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClusterHBIRequestBuilder toBuilder() =>
      ClusterHBIRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClusterHBIRequest &&
        datasetHash == other.datasetHash &&
        sequenceIdentityThreshold == other.sequenceIdentityThreshold &&
        sequenceData == other.sequenceData &&
        targetData == other.targetData &&
        isNumeric == other.isNumeric &&
        iterations == other.iterations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, datasetHash.hashCode);
    _$hash = $jc(_$hash, sequenceIdentityThreshold.hashCode);
    _$hash = $jc(_$hash, sequenceData.hashCode);
    _$hash = $jc(_$hash, targetData.hashCode);
    _$hash = $jc(_$hash, isNumeric.hashCode);
    _$hash = $jc(_$hash, iterations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClusterHBIRequest')
          ..add('datasetHash', datasetHash)
          ..add('sequenceIdentityThreshold', sequenceIdentityThreshold)
          ..add('sequenceData', sequenceData)
          ..add('targetData', targetData)
          ..add('isNumeric', isNumeric)
          ..add('iterations', iterations))
        .toString();
  }
}

class ClusterHBIRequestBuilder
    implements Builder<ClusterHBIRequest, ClusterHBIRequestBuilder> {
  _$ClusterHBIRequest? _$v;

  String? _datasetHash;
  String? get datasetHash => _$this._datasetHash;
  set datasetHash(String? datasetHash) => _$this._datasetHash = datasetHash;

  num? _sequenceIdentityThreshold;
  num? get sequenceIdentityThreshold => _$this._sequenceIdentityThreshold;
  set sequenceIdentityThreshold(num? sequenceIdentityThreshold) =>
      _$this._sequenceIdentityThreshold = sequenceIdentityThreshold;

  MapBuilder<String, String>? _sequenceData;
  MapBuilder<String, String> get sequenceData =>
      _$this._sequenceData ??= MapBuilder<String, String>();
  set sequenceData(MapBuilder<String, String>? sequenceData) =>
      _$this._sequenceData = sequenceData;

  MapBuilder<String, JsonObject?>? _targetData;
  MapBuilder<String, JsonObject?> get targetData =>
      _$this._targetData ??= MapBuilder<String, JsonObject?>();
  set targetData(MapBuilder<String, JsonObject?>? targetData) =>
      _$this._targetData = targetData;

  bool? _isNumeric;
  bool? get isNumeric => _$this._isNumeric;
  set isNumeric(bool? isNumeric) => _$this._isNumeric = isNumeric;

  int? _iterations;
  int? get iterations => _$this._iterations;
  set iterations(int? iterations) => _$this._iterations = iterations;

  ClusterHBIRequestBuilder() {
    ClusterHBIRequest._defaults(this);
  }

  ClusterHBIRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _datasetHash = $v.datasetHash;
      _sequenceIdentityThreshold = $v.sequenceIdentityThreshold;
      _sequenceData = $v.sequenceData?.toBuilder();
      _targetData = $v.targetData.toBuilder();
      _isNumeric = $v.isNumeric;
      _iterations = $v.iterations;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClusterHBIRequest other) {
    _$v = other as _$ClusterHBIRequest;
  }

  @override
  void update(void Function(ClusterHBIRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClusterHBIRequest build() => _build();

  _$ClusterHBIRequest _build() {
    _$ClusterHBIRequest _$result;
    try {
      _$result = _$v ??
          _$ClusterHBIRequest._(
            datasetHash: BuiltValueNullFieldError.checkNotNull(
                datasetHash, r'ClusterHBIRequest', 'datasetHash'),
            sequenceIdentityThreshold: sequenceIdentityThreshold,
            sequenceData: _sequenceData?.build(),
            targetData: targetData.build(),
            isNumeric: isNumeric,
            iterations: iterations,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sequenceData';
        _sequenceData?.build();
        _$failedField = 'targetData';
        targetData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClusterHBIRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
