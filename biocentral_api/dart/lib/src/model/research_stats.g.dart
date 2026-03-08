// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResearchStats extends ResearchStats {
  @override
  final int totalSequences24h;
  @override
  final int totalSequences7d;
  @override
  final int totalSequencesAllTime;
  @override
  final num avgSequenceLength;
  @override
  final BuiltList<BuiltMap<String, num>> topEmbedders;
  @override
  final DateTime updatedAt;

  factory _$ResearchStats([void Function(ResearchStatsBuilder)? updates]) =>
      (ResearchStatsBuilder()..update(updates))._build();

  _$ResearchStats._(
      {required this.totalSequences24h,
      required this.totalSequences7d,
      required this.totalSequencesAllTime,
      required this.avgSequenceLength,
      required this.topEmbedders,
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
        totalSequences24h == other.totalSequences24h &&
        totalSequences7d == other.totalSequences7d &&
        totalSequencesAllTime == other.totalSequencesAllTime &&
        avgSequenceLength == other.avgSequenceLength &&
        topEmbedders == other.topEmbedders &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalSequences24h.hashCode);
    _$hash = $jc(_$hash, totalSequences7d.hashCode);
    _$hash = $jc(_$hash, totalSequencesAllTime.hashCode);
    _$hash = $jc(_$hash, avgSequenceLength.hashCode);
    _$hash = $jc(_$hash, topEmbedders.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResearchStats')
          ..add('totalSequences24h', totalSequences24h)
          ..add('totalSequences7d', totalSequences7d)
          ..add('totalSequencesAllTime', totalSequencesAllTime)
          ..add('avgSequenceLength', avgSequenceLength)
          ..add('topEmbedders', topEmbedders)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ResearchStatsBuilder
    implements Builder<ResearchStats, ResearchStatsBuilder> {
  _$ResearchStats? _$v;

  int? _totalSequences24h;
  int? get totalSequences24h => _$this._totalSequences24h;
  set totalSequences24h(int? totalSequences24h) =>
      _$this._totalSequences24h = totalSequences24h;

  int? _totalSequences7d;
  int? get totalSequences7d => _$this._totalSequences7d;
  set totalSequences7d(int? totalSequences7d) =>
      _$this._totalSequences7d = totalSequences7d;

  int? _totalSequencesAllTime;
  int? get totalSequencesAllTime => _$this._totalSequencesAllTime;
  set totalSequencesAllTime(int? totalSequencesAllTime) =>
      _$this._totalSequencesAllTime = totalSequencesAllTime;

  num? _avgSequenceLength;
  num? get avgSequenceLength => _$this._avgSequenceLength;
  set avgSequenceLength(num? avgSequenceLength) =>
      _$this._avgSequenceLength = avgSequenceLength;

  ListBuilder<BuiltMap<String, num>>? _topEmbedders;
  ListBuilder<BuiltMap<String, num>> get topEmbedders =>
      _$this._topEmbedders ??= ListBuilder<BuiltMap<String, num>>();
  set topEmbedders(ListBuilder<BuiltMap<String, num>>? topEmbedders) =>
      _$this._topEmbedders = topEmbedders;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ResearchStatsBuilder() {
    ResearchStats._defaults(this);
  }

  ResearchStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalSequences24h = $v.totalSequences24h;
      _totalSequences7d = $v.totalSequences7d;
      _totalSequencesAllTime = $v.totalSequencesAllTime;
      _avgSequenceLength = $v.avgSequenceLength;
      _topEmbedders = $v.topEmbedders.toBuilder();
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
            totalSequences24h: BuiltValueNullFieldError.checkNotNull(
                totalSequences24h, r'ResearchStats', 'totalSequences24h'),
            totalSequences7d: BuiltValueNullFieldError.checkNotNull(
                totalSequences7d, r'ResearchStats', 'totalSequences7d'),
            totalSequencesAllTime: BuiltValueNullFieldError.checkNotNull(
                totalSequencesAllTime,
                r'ResearchStats',
                'totalSequencesAllTime'),
            avgSequenceLength: BuiltValueNullFieldError.checkNotNull(
                avgSequenceLength, r'ResearchStats', 'avgSequenceLength'),
            topEmbedders: topEmbedders.build(),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'ResearchStats', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'topEmbedders';
        topEmbedders.build();
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
