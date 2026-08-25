// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResearchStatsResponse extends ResearchStatsResponse {
  @override
  final ResearchStats researchStats;

  factory _$ResearchStatsResponse(
          [void Function(ResearchStatsResponseBuilder)? updates]) =>
      (ResearchStatsResponseBuilder()..update(updates))._build();

  _$ResearchStatsResponse._({required this.researchStats}) : super._();
  @override
  ResearchStatsResponse rebuild(
          void Function(ResearchStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResearchStatsResponseBuilder toBuilder() =>
      ResearchStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResearchStatsResponse &&
        researchStats == other.researchStats;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, researchStats.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResearchStatsResponse')
          ..add('researchStats', researchStats))
        .toString();
  }
}

class ResearchStatsResponseBuilder
    implements Builder<ResearchStatsResponse, ResearchStatsResponseBuilder> {
  _$ResearchStatsResponse? _$v;

  ResearchStatsBuilder? _researchStats;
  ResearchStatsBuilder get researchStats =>
      _$this._researchStats ??= ResearchStatsBuilder();
  set researchStats(ResearchStatsBuilder? researchStats) =>
      _$this._researchStats = researchStats;

  ResearchStatsResponseBuilder() {
    ResearchStatsResponse._defaults(this);
  }

  ResearchStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _researchStats = $v.researchStats.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResearchStatsResponse other) {
    _$v = other as _$ResearchStatsResponse;
  }

  @override
  void update(void Function(ResearchStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResearchStatsResponse build() => _build();

  _$ResearchStatsResponse _build() {
    _$ResearchStatsResponse _$result;
    try {
      _$result = _$v ??
          _$ResearchStatsResponse._(
            researchStats: researchStats.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'researchStats';
        researchStats.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResearchStatsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
