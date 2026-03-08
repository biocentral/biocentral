// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biocentral_service_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiocentralServiceStats extends BiocentralServiceStats {
  @override
  final int usableCpuCount;
  @override
  final String diskUsage;
  @override
  final int numberRequestsSinceStart;
  @override
  final int nProcesses;
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
      required this.diskUsage,
      required this.numberRequestsSinceStart,
      required this.nProcesses,
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
        diskUsage == other.diskUsage &&
        numberRequestsSinceStart == other.numberRequestsSinceStart &&
        nProcesses == other.nProcesses &&
        cudaAvailable == other.cudaAvailable &&
        cudaDeviceNames == other.cudaDeviceNames &&
        cudaDeviceCount == other.cudaDeviceCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, usableCpuCount.hashCode);
    _$hash = $jc(_$hash, diskUsage.hashCode);
    _$hash = $jc(_$hash, numberRequestsSinceStart.hashCode);
    _$hash = $jc(_$hash, nProcesses.hashCode);
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
          ..add('diskUsage', diskUsage)
          ..add('numberRequestsSinceStart', numberRequestsSinceStart)
          ..add('nProcesses', nProcesses)
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

  String? _diskUsage;
  String? get diskUsage => _$this._diskUsage;
  set diskUsage(String? diskUsage) => _$this._diskUsage = diskUsage;

  int? _numberRequestsSinceStart;
  int? get numberRequestsSinceStart => _$this._numberRequestsSinceStart;
  set numberRequestsSinceStart(int? numberRequestsSinceStart) =>
      _$this._numberRequestsSinceStart = numberRequestsSinceStart;

  int? _nProcesses;
  int? get nProcesses => _$this._nProcesses;
  set nProcesses(int? nProcesses) => _$this._nProcesses = nProcesses;

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
      _diskUsage = $v.diskUsage;
      _numberRequestsSinceStart = $v.numberRequestsSinceStart;
      _nProcesses = $v.nProcesses;
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
            diskUsage: BuiltValueNullFieldError.checkNotNull(
                diskUsage, r'BiocentralServiceStats', 'diskUsage'),
            numberRequestsSinceStart: BuiltValueNullFieldError.checkNotNull(
                numberRequestsSinceStart,
                r'BiocentralServiceStats',
                'numberRequestsSinceStart'),
            nProcesses: BuiltValueNullFieldError.checkNotNull(
                nProcesses, r'BiocentralServiceStats', 'nProcesses'),
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
