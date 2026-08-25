// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clustering_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClusteringRequest extends ClusteringRequest {
  @override
  final BuiltMap<String, String> sequenceData;
  @override
  final num? sequenceIdentityThreshold;

  factory _$ClusteringRequest(
          [void Function(ClusteringRequestBuilder)? updates]) =>
      (ClusteringRequestBuilder()..update(updates))._build();

  _$ClusteringRequest._(
      {required this.sequenceData, this.sequenceIdentityThreshold})
      : super._();
  @override
  ClusteringRequest rebuild(void Function(ClusteringRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClusteringRequestBuilder toBuilder() =>
      ClusteringRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClusteringRequest &&
        sequenceData == other.sequenceData &&
        sequenceIdentityThreshold == other.sequenceIdentityThreshold;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sequenceData.hashCode);
    _$hash = $jc(_$hash, sequenceIdentityThreshold.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClusteringRequest')
          ..add('sequenceData', sequenceData)
          ..add('sequenceIdentityThreshold', sequenceIdentityThreshold))
        .toString();
  }
}

class ClusteringRequestBuilder
    implements Builder<ClusteringRequest, ClusteringRequestBuilder> {
  _$ClusteringRequest? _$v;

  MapBuilder<String, String>? _sequenceData;
  MapBuilder<String, String> get sequenceData =>
      _$this._sequenceData ??= MapBuilder<String, String>();
  set sequenceData(MapBuilder<String, String>? sequenceData) =>
      _$this._sequenceData = sequenceData;

  num? _sequenceIdentityThreshold;
  num? get sequenceIdentityThreshold => _$this._sequenceIdentityThreshold;
  set sequenceIdentityThreshold(num? sequenceIdentityThreshold) =>
      _$this._sequenceIdentityThreshold = sequenceIdentityThreshold;

  ClusteringRequestBuilder() {
    ClusteringRequest._defaults(this);
  }

  ClusteringRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sequenceData = $v.sequenceData.toBuilder();
      _sequenceIdentityThreshold = $v.sequenceIdentityThreshold;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClusteringRequest other) {
    _$v = other as _$ClusteringRequest;
  }

  @override
  void update(void Function(ClusteringRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClusteringRequest build() => _build();

  _$ClusteringRequest _build() {
    _$ClusteringRequest _$result;
    try {
      _$result = _$v ??
          _$ClusteringRequest._(
            sequenceData: sequenceData.build(),
            sequenceIdentityThreshold: sequenceIdentityThreshold,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sequenceData';
        sequenceData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClusteringRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
