// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biocentral_service_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiocentralServiceStats extends BiocentralServiceStats {
  @override
  final int usableCpuCount;
  @override
  final String embeddingsDatabaseSize;
  @override
  final int totalTasks;
  @override
  final int queueLength;
  @override
  final bool cudaAvailable;
  @override
  final BuiltList<String> cudaDeviceNames;
  @override
  final int cudaDeviceCount;

  factory _$BiocentralServiceStats(
          [void Function(BiocentralServiceStatsBuilder)? updates]) =>
      (BiocentralServiceStatsBuilder()..update(updates))._build();

  _$BiocentralServiceStats._(
      {required this.usableCpuCount,
      required this.embeddingsDatabaseSize,
      required this.totalTasks,
      required this.queueLength,
      required this.cudaAvailable,
      required this.cudaDeviceNames,
      required this.cudaDeviceCount})
      : super._();
  @override
  BiocentralServiceStats rebuild(
          void Function(BiocentralServiceStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiocentralServiceStatsBuilder toBuilder() =>
      BiocentralServiceStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiocentralServiceStats &&
        usableCpuCount == other.usableCpuCount &&
        embeddingsDatabaseSize == other.embeddingsDatabaseSize &&
        totalTasks == other.totalTasks &&
        queueLength == other.queueLength &&
        cudaAvailable == other.cudaAvailable &&
        cudaDeviceNames == other.cudaDeviceNames &&
        cudaDeviceCount == other.cudaDeviceCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, usableCpuCount.hashCode);
    _$hash = $jc(_$hash, embeddingsDatabaseSize.hashCode);
    _$hash = $jc(_$hash, totalTasks.hashCode);
    _$hash = $jc(_$hash, queueLength.hashCode);
    _$hash = $jc(_$hash, cudaAvailable.hashCode);
    _$hash = $jc(_$hash, cudaDeviceNames.hashCode);
    _$hash = $jc(_$hash, cudaDeviceCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiocentralServiceStats')
          ..add('usableCpuCount', usableCpuCount)
          ..add('embeddingsDatabaseSize', embeddingsDatabaseSize)
          ..add('totalTasks', totalTasks)
          ..add('queueLength', queueLength)
          ..add('cudaAvailable', cudaAvailable)
          ..add('cudaDeviceNames', cudaDeviceNames)
          ..add('cudaDeviceCount', cudaDeviceCount))
        .toString();
  }
}

class BiocentralServiceStatsBuilder
    implements Builder<BiocentralServiceStats, BiocentralServiceStatsBuilder> {
  _$BiocentralServiceStats? _$v;

  int? _usableCpuCount;
  int? get usableCpuCount => _$this._usableCpuCount;
  set usableCpuCount(int? usableCpuCount) =>
      _$this._usableCpuCount = usableCpuCount;

  String? _embeddingsDatabaseSize;
  String? get embeddingsDatabaseSize => _$this._embeddingsDatabaseSize;
  set embeddingsDatabaseSize(String? embeddingsDatabaseSize) =>
      _$this._embeddingsDatabaseSize = embeddingsDatabaseSize;

  int? _totalTasks;
  int? get totalTasks => _$this._totalTasks;
  set totalTasks(int? totalTasks) => _$this._totalTasks = totalTasks;

  int? _queueLength;
  int? get queueLength => _$this._queueLength;
  set queueLength(int? queueLength) => _$this._queueLength = queueLength;

  bool? _cudaAvailable;
  bool? get cudaAvailable => _$this._cudaAvailable;
  set cudaAvailable(bool? cudaAvailable) =>
      _$this._cudaAvailable = cudaAvailable;

  ListBuilder<String>? _cudaDeviceNames;
  ListBuilder<String> get cudaDeviceNames =>
      _$this._cudaDeviceNames ??= ListBuilder<String>();
  set cudaDeviceNames(ListBuilder<String>? cudaDeviceNames) =>
      _$this._cudaDeviceNames = cudaDeviceNames;

  int? _cudaDeviceCount;
  int? get cudaDeviceCount => _$this._cudaDeviceCount;
  set cudaDeviceCount(int? cudaDeviceCount) =>
      _$this._cudaDeviceCount = cudaDeviceCount;

  BiocentralServiceStatsBuilder() {
    BiocentralServiceStats._defaults(this);
  }

  BiocentralServiceStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _usableCpuCount = $v.usableCpuCount;
      _embeddingsDatabaseSize = $v.embeddingsDatabaseSize;
      _totalTasks = $v.totalTasks;
      _queueLength = $v.queueLength;
      _cudaAvailable = $v.cudaAvailable;
      _cudaDeviceNames = $v.cudaDeviceNames.toBuilder();
      _cudaDeviceCount = $v.cudaDeviceCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiocentralServiceStats other) {
    _$v = other as _$BiocentralServiceStats;
  }

  @override
  void update(void Function(BiocentralServiceStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiocentralServiceStats build() => _build();

  _$BiocentralServiceStats _build() {
    _$BiocentralServiceStats _$result;
    try {
      _$result = _$v ??
          _$BiocentralServiceStats._(
            usableCpuCount: BuiltValueNullFieldError.checkNotNull(
                usableCpuCount, r'BiocentralServiceStats', 'usableCpuCount'),
            embeddingsDatabaseSize: BuiltValueNullFieldError.checkNotNull(
                embeddingsDatabaseSize,
                r'BiocentralServiceStats',
                'embeddingsDatabaseSize'),
            totalTasks: BuiltValueNullFieldError.checkNotNull(
                totalTasks, r'BiocentralServiceStats', 'totalTasks'),
            queueLength: BuiltValueNullFieldError.checkNotNull(
                queueLength, r'BiocentralServiceStats', 'queueLength'),
            cudaAvailable: BuiltValueNullFieldError.checkNotNull(
                cudaAvailable, r'BiocentralServiceStats', 'cudaAvailable'),
            cudaDeviceNames: cudaDeviceNames.build(),
            cudaDeviceCount: BuiltValueNullFieldError.checkNotNull(
                cudaDeviceCount, r'BiocentralServiceStats', 'cudaDeviceCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cudaDeviceNames';
        cudaDeviceNames.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BiocentralServiceStats', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
