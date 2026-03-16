// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zero_shot_framework_report.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ZeroShotFrameworkReport extends ZeroShotFrameworkReport {
  @override
  final ZeroShotMethod method;
  @override
  final BuiltMap<String, RankingResult> aggregatedResults;
  @override
  final BuiltMap<String, RankingResult> individualResults;

  factory _$ZeroShotFrameworkReport(
          [void Function(ZeroShotFrameworkReportBuilder)? updates]) =>
      (ZeroShotFrameworkReportBuilder()..update(updates))._build();

  _$ZeroShotFrameworkReport._(
      {required this.method,
      required this.aggregatedResults,
      required this.individualResults})
      : super._();
  @override
  ZeroShotFrameworkReport rebuild(
          void Function(ZeroShotFrameworkReportBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ZeroShotFrameworkReportBuilder toBuilder() =>
      ZeroShotFrameworkReportBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ZeroShotFrameworkReport &&
        method == other.method &&
        aggregatedResults == other.aggregatedResults &&
        individualResults == other.individualResults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, aggregatedResults.hashCode);
    _$hash = $jc(_$hash, individualResults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ZeroShotFrameworkReport')
          ..add('method', method)
          ..add('aggregatedResults', aggregatedResults)
          ..add('individualResults', individualResults))
        .toString();
  }
}

class ZeroShotFrameworkReportBuilder
    implements
        Builder<ZeroShotFrameworkReport, ZeroShotFrameworkReportBuilder> {
  _$ZeroShotFrameworkReport? _$v;

  ZeroShotMethod? _method;
  ZeroShotMethod? get method => _$this._method;
  set method(ZeroShotMethod? method) => _$this._method = method;

  MapBuilder<String, RankingResult>? _aggregatedResults;
  MapBuilder<String, RankingResult> get aggregatedResults =>
      _$this._aggregatedResults ??= MapBuilder<String, RankingResult>();
  set aggregatedResults(MapBuilder<String, RankingResult>? aggregatedResults) =>
      _$this._aggregatedResults = aggregatedResults;

  MapBuilder<String, RankingResult>? _individualResults;
  MapBuilder<String, RankingResult> get individualResults =>
      _$this._individualResults ??= MapBuilder<String, RankingResult>();
  set individualResults(MapBuilder<String, RankingResult>? individualResults) =>
      _$this._individualResults = individualResults;

  ZeroShotFrameworkReportBuilder() {
    ZeroShotFrameworkReport._defaults(this);
  }

  ZeroShotFrameworkReportBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _method = $v.method;
      _aggregatedResults = $v.aggregatedResults.toBuilder();
      _individualResults = $v.individualResults.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ZeroShotFrameworkReport other) {
    _$v = other as _$ZeroShotFrameworkReport;
  }

  @override
  void update(void Function(ZeroShotFrameworkReportBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ZeroShotFrameworkReport build() => _build();

  _$ZeroShotFrameworkReport _build() {
    _$ZeroShotFrameworkReport _$result;
    try {
      _$result = _$v ??
          _$ZeroShotFrameworkReport._(
            method: BuiltValueNullFieldError.checkNotNull(
                method, r'ZeroShotFrameworkReport', 'method'),
            aggregatedResults: aggregatedResults.build(),
            individualResults: individualResults.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'aggregatedResults';
        aggregatedResults.build();
        _$failedField = 'individualResults';
        individualResults.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ZeroShotFrameworkReport', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
