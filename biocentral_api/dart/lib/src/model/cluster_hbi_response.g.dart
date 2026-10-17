// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cluster_hbi_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClusterHBIResponse extends ClusterHBIResponse {
  @override
  final BuiltList<BootstrappedMetric> metrics;
  @override
  final BuiltMap<String, BuiltList<String>> clusters;

  factory _$ClusterHBIResponse(
          [void Function(ClusterHBIResponseBuilder)? updates]) =>
      (ClusterHBIResponseBuilder()..update(updates))._build();

  _$ClusterHBIResponse._({required this.metrics, required this.clusters})
      : super._();
  @override
  ClusterHBIResponse rebuild(
          void Function(ClusterHBIResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClusterHBIResponseBuilder toBuilder() =>
      ClusterHBIResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClusterHBIResponse &&
        metrics == other.metrics &&
        clusters == other.clusters;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, metrics.hashCode);
    _$hash = $jc(_$hash, clusters.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClusterHBIResponse')
          ..add('metrics', metrics)
          ..add('clusters', clusters))
        .toString();
  }
}

class ClusterHBIResponseBuilder
    implements Builder<ClusterHBIResponse, ClusterHBIResponseBuilder> {
  _$ClusterHBIResponse? _$v;

  ListBuilder<BootstrappedMetric>? _metrics;
  ListBuilder<BootstrappedMetric> get metrics =>
      _$this._metrics ??= ListBuilder<BootstrappedMetric>();
  set metrics(ListBuilder<BootstrappedMetric>? metrics) =>
      _$this._metrics = metrics;

  MapBuilder<String, BuiltList<String>>? _clusters;
  MapBuilder<String, BuiltList<String>> get clusters =>
      _$this._clusters ??= MapBuilder<String, BuiltList<String>>();
  set clusters(MapBuilder<String, BuiltList<String>>? clusters) =>
      _$this._clusters = clusters;

  ClusterHBIResponseBuilder() {
    ClusterHBIResponse._defaults(this);
  }

  ClusterHBIResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _metrics = $v.metrics.toBuilder();
      _clusters = $v.clusters.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClusterHBIResponse other) {
    _$v = other as _$ClusterHBIResponse;
  }

  @override
  void update(void Function(ClusterHBIResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClusterHBIResponse build() => _build();

  _$ClusterHBIResponse _build() {
    _$ClusterHBIResponse _$result;
    try {
      _$result = _$v ??
          _$ClusterHBIResponse._(
            metrics: metrics.build(),
            clusters: clusters.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metrics';
        metrics.build();
        _$failedField = 'clusters';
        clusters.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClusterHBIResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
