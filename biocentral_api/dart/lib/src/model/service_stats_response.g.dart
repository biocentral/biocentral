// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ServiceStatsResponse extends ServiceStatsResponse {
  @override
  final BiocentralServiceStats serviceStats;

  factory _$ServiceStatsResponse(
          [void Function(ServiceStatsResponseBuilder)? updates]) =>
      (ServiceStatsResponseBuilder()..update(updates))._build();

  _$ServiceStatsResponse._({required this.serviceStats}) : super._();
  @override
  ServiceStatsResponse rebuild(
          void Function(ServiceStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServiceStatsResponseBuilder toBuilder() =>
      ServiceStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServiceStatsResponse && serviceStats == other.serviceStats;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, serviceStats.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ServiceStatsResponse')
          ..add('serviceStats', serviceStats))
        .toString();
  }
}

class ServiceStatsResponseBuilder
    implements Builder<ServiceStatsResponse, ServiceStatsResponseBuilder> {
  _$ServiceStatsResponse? _$v;

  BiocentralServiceStatsBuilder? _serviceStats;
  BiocentralServiceStatsBuilder get serviceStats =>
      _$this._serviceStats ??= BiocentralServiceStatsBuilder();
  set serviceStats(BiocentralServiceStatsBuilder? serviceStats) =>
      _$this._serviceStats = serviceStats;

  ServiceStatsResponseBuilder() {
    ServiceStatsResponse._defaults(this);
  }

  ServiceStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _serviceStats = $v.serviceStats.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServiceStatsResponse other) {
    _$v = other as _$ServiceStatsResponse;
  }

  @override
  void update(void Function(ServiceStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServiceStatsResponse build() => _build();

  _$ServiceStatsResponse _build() {
    _$ServiceStatsResponse _$result;
    try {
      _$result = _$v ??
          _$ServiceStatsResponse._(
            serviceStats: serviceStats.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'serviceStats';
        serviceStats.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ServiceStatsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
