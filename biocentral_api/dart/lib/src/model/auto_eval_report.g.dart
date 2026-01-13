// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_eval_report.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoEvalReport extends AutoEvalReport {
  @override
  final String embedderName;
  @override
  final String trainingDate;
  @override
  final int minSeqLen;
  @override
  final int maxSeqLen;
  @override
  final BuiltMap<String, BuiltMap<String, JsonObject?>> results;

  factory _$AutoEvalReport([void Function(AutoEvalReportBuilder)? updates]) =>
      (AutoEvalReportBuilder()..update(updates))._build();

  _$AutoEvalReport._(
      {required this.embedderName,
      required this.trainingDate,
      required this.minSeqLen,
      required this.maxSeqLen,
      required this.results})
      : super._();
  @override
  AutoEvalReport rebuild(void Function(AutoEvalReportBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoEvalReportBuilder toBuilder() => AutoEvalReportBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoEvalReport &&
        embedderName == other.embedderName &&
        trainingDate == other.trainingDate &&
        minSeqLen == other.minSeqLen &&
        maxSeqLen == other.maxSeqLen &&
        results == other.results;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, trainingDate.hashCode);
    _$hash = $jc(_$hash, minSeqLen.hashCode);
    _$hash = $jc(_$hash, maxSeqLen.hashCode);
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoEvalReport')
          ..add('embedderName', embedderName)
          ..add('trainingDate', trainingDate)
          ..add('minSeqLen', minSeqLen)
          ..add('maxSeqLen', maxSeqLen)
          ..add('results', results))
        .toString();
  }
}

class AutoEvalReportBuilder
    implements Builder<AutoEvalReport, AutoEvalReportBuilder> {
  _$AutoEvalReport? _$v;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  String? _trainingDate;
  String? get trainingDate => _$this._trainingDate;
  set trainingDate(String? trainingDate) => _$this._trainingDate = trainingDate;

  int? _minSeqLen;
  int? get minSeqLen => _$this._minSeqLen;
  set minSeqLen(int? minSeqLen) => _$this._minSeqLen = minSeqLen;

  int? _maxSeqLen;
  int? get maxSeqLen => _$this._maxSeqLen;
  set maxSeqLen(int? maxSeqLen) => _$this._maxSeqLen = maxSeqLen;

  MapBuilder<String, BuiltMap<String, JsonObject?>>? _results;
  MapBuilder<String, BuiltMap<String, JsonObject?>> get results =>
      _$this._results ??= MapBuilder<String, BuiltMap<String, JsonObject?>>();
  set results(MapBuilder<String, BuiltMap<String, JsonObject?>>? results) =>
      _$this._results = results;

  AutoEvalReportBuilder() {
    AutoEvalReport._defaults(this);
  }

  AutoEvalReportBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _embedderName = $v.embedderName;
      _trainingDate = $v.trainingDate;
      _minSeqLen = $v.minSeqLen;
      _maxSeqLen = $v.maxSeqLen;
      _results = $v.results.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoEvalReport other) {
    _$v = other as _$AutoEvalReport;
  }

  @override
  void update(void Function(AutoEvalReportBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoEvalReport build() => _build();

  _$AutoEvalReport _build() {
    _$AutoEvalReport _$result;
    try {
      _$result = _$v ??
          _$AutoEvalReport._(
            embedderName: BuiltValueNullFieldError.checkNotNull(
                embedderName, r'AutoEvalReport', 'embedderName'),
            trainingDate: BuiltValueNullFieldError.checkNotNull(
                trainingDate, r'AutoEvalReport', 'trainingDate'),
            minSeqLen: BuiltValueNullFieldError.checkNotNull(
                minSeqLen, r'AutoEvalReport', 'minSeqLen'),
            maxSeqLen: BuiltValueNullFieldError.checkNotNull(
                maxSeqLen, r'AutoEvalReport', 'maxSeqLen'),
            results: results.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AutoEvalReport', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
