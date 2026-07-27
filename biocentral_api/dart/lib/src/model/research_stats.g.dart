// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResearchStats extends ResearchStats {
  @override
  final int totalSequencesToday;
  @override
  final int totalSequencesAllTime;
  @override
  final num avgSequenceLength;
  @override
  final BuiltMap<String, int> aaDistribution;
  @override
  final BuiltMap<String, num> topEmbedders;
  @override
  final BuiltMap<String, num> topPredictors;
  @override
  final DateTime updatedAt;

  factory _$ResearchStats([void Function(ResearchStatsBuilder)? updates]) =>
      (ResearchStatsBuilder()..update(updates))._build();

  _$ResearchStats._(
      {required this.totalSequencesToday,
      required this.totalSequencesAllTime,
      required this.avgSequenceLength,
      required this.aaDistribution,
      required this.topEmbedders,
      required this.topPredictors,
      required this.updatedAt})
      : super._();
  @override
  ResearchStats rebuild(void Function(ResearchStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResearchStatsBuilder toBuilder() => ResearchStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResearchStats &&
        totalSequencesToday == other.totalSequencesToday &&
        totalSequencesAllTime == other.totalSequencesAllTime &&
        avgSequenceLength == other.avgSequenceLength &&
        aaDistribution == other.aaDistribution &&
        topEmbedders == other.topEmbedders &&
        topPredictors == other.topPredictors &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalSequencesToday.hashCode);
    _$hash = $jc(_$hash, totalSequencesAllTime.hashCode);
    _$hash = $jc(_$hash, avgSequenceLength.hashCode);
    _$hash = $jc(_$hash, aaDistribution.hashCode);
    _$hash = $jc(_$hash, topEmbedders.hashCode);
    _$hash = $jc(_$hash, topPredictors.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResearchStats')
          ..add('totalSequencesToday', totalSequencesToday)
          ..add('totalSequencesAllTime', totalSequencesAllTime)
          ..add('avgSequenceLength', avgSequenceLength)
          ..add('aaDistribution', aaDistribution)
          ..add('topEmbedders', topEmbedders)
          ..add('topPredictors', topPredictors)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ResearchStatsBuilder
    implements Builder<ResearchStats, ResearchStatsBuilder> {
  _$ResearchStats? _$v;

  int? _totalSequencesToday;
  int? get totalSequencesToday => _$this._totalSequencesToday;
  set totalSequencesToday(int? totalSequencesToday) =>
      _$this._totalSequencesToday = totalSequencesToday;

  int? _totalSequencesAllTime;
  int? get totalSequencesAllTime => _$this._totalSequencesAllTime;
  set totalSequencesAllTime(int? totalSequencesAllTime) =>
      _$this._totalSequencesAllTime = totalSequencesAllTime;

  num? _avgSequenceLength;
  num? get avgSequenceLength => _$this._avgSequenceLength;
  set avgSequenceLength(num? avgSequenceLength) =>
      _$this._avgSequenceLength = avgSequenceLength;

  MapBuilder<String, int>? _aaDistribution;
  MapBuilder<String, int> get aaDistribution =>
      _$this._aaDistribution ??= MapBuilder<String, int>();
  set aaDistribution(MapBuilder<String, int>? aaDistribution) =>
      _$this._aaDistribution = aaDistribution;

  MapBuilder<String, num>? _topEmbedders;
  MapBuilder<String, num> get topEmbedders =>
      _$this._topEmbedders ??= MapBuilder<String, num>();
  set topEmbedders(MapBuilder<String, num>? topEmbedders) =>
      _$this._topEmbedders = topEmbedders;

  MapBuilder<String, num>? _topPredictors;
  MapBuilder<String, num> get topPredictors =>
      _$this._topPredictors ??= MapBuilder<String, num>();
  set topPredictors(MapBuilder<String, num>? topPredictors) =>
      _$this._topPredictors = topPredictors;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ResearchStatsBuilder() {
    ResearchStats._defaults(this);
  }

  ResearchStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalSequencesToday = $v.totalSequencesToday;
      _totalSequencesAllTime = $v.totalSequencesAllTime;
      _avgSequenceLength = $v.avgSequenceLength;
      _aaDistribution = $v.aaDistribution.toBuilder();
      _topEmbedders = $v.topEmbedders.toBuilder();
      _topPredictors = $v.topPredictors.toBuilder();
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResearchStats other) {
    _$v = other as _$ResearchStats;
  }

  @override
  void update(void Function(ResearchStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResearchStats build() => _build();

  _$ResearchStats _build() {
    _$ResearchStats _$result;
    try {
      _$result = _$v ??
          _$ResearchStats._(
            totalSequencesToday: BuiltValueNullFieldError.checkNotNull(
                totalSequencesToday, r'ResearchStats', 'totalSequencesToday'),
            totalSequencesAllTime: BuiltValueNullFieldError.checkNotNull(
                totalSequencesAllTime,
                r'ResearchStats',
                'totalSequencesAllTime'),
            avgSequenceLength: BuiltValueNullFieldError.checkNotNull(
                avgSequenceLength, r'ResearchStats', 'avgSequenceLength'),
            aaDistribution: aaDistribution.build(),
            topEmbedders: topEmbedders.build(),
            topPredictors: topPredictors.build(),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'ResearchStats', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'aaDistribution';
        aaDistribution.build();
        _$failedField = 'topEmbedders';
        topEmbedders.build();
        _$failedField = 'topPredictors';
        topPredictors.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResearchStats', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
