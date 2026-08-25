// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedding_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmbeddingStats extends EmbeddingStats {
  @override
  final String embedderName;
  @override
  final int dims;
  @override
  final int nTracked;
  @override
  final num min;
  @override
  final num max;

  factory _$EmbeddingStats([void Function(EmbeddingStatsBuilder)? updates]) =>
      (EmbeddingStatsBuilder()..update(updates))._build();

  _$EmbeddingStats._(
      {required this.embedderName,
      required this.dims,
      required this.nTracked,
      required this.min,
      required this.max})
      : super._();
  @override
  EmbeddingStats rebuild(void Function(EmbeddingStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmbeddingStatsBuilder toBuilder() => EmbeddingStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmbeddingStats &&
        embedderName == other.embedderName &&
        dims == other.dims &&
        nTracked == other.nTracked &&
        min == other.min &&
        max == other.max;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, dims.hashCode);
    _$hash = $jc(_$hash, nTracked.hashCode);
    _$hash = $jc(_$hash, min.hashCode);
    _$hash = $jc(_$hash, max.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmbeddingStats')
          ..add('embedderName', embedderName)
          ..add('dims', dims)
          ..add('nTracked', nTracked)
          ..add('min', min)
          ..add('max', max))
        .toString();
  }
}

class EmbeddingStatsBuilder
    implements Builder<EmbeddingStats, EmbeddingStatsBuilder> {
  _$EmbeddingStats? _$v;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  int? _dims;
  int? get dims => _$this._dims;
  set dims(int? dims) => _$this._dims = dims;

  int? _nTracked;
  int? get nTracked => _$this._nTracked;
  set nTracked(int? nTracked) => _$this._nTracked = nTracked;

  num? _min;
  num? get min => _$this._min;
  set min(num? min) => _$this._min = min;

  num? _max;
  num? get max => _$this._max;
  set max(num? max) => _$this._max = max;

  EmbeddingStatsBuilder() {
    EmbeddingStats._defaults(this);
  }

  EmbeddingStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _embedderName = $v.embedderName;
      _dims = $v.dims;
      _nTracked = $v.nTracked;
      _min = $v.min;
      _max = $v.max;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmbeddingStats other) {
    _$v = other as _$EmbeddingStats;
  }

  @override
  void update(void Function(EmbeddingStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmbeddingStats build() => _build();

  _$EmbeddingStats _build() {
    final _$result = _$v ??
        _$EmbeddingStats._(
          embedderName: BuiltValueNullFieldError.checkNotNull(
              embedderName, r'EmbeddingStats', 'embedderName'),
          dims: BuiltValueNullFieldError.checkNotNull(
              dims, r'EmbeddingStats', 'dims'),
          nTracked: BuiltValueNullFieldError.checkNotNull(
              nTracked, r'EmbeddingStats', 'nTracked'),
          min: BuiltValueNullFieldError.checkNotNull(
              min, r'EmbeddingStats', 'min'),
          max: BuiltValueNullFieldError.checkNotNull(
              max, r'EmbeddingStats', 'max'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
