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
  final BuiltMap<String, SupervisedFrameworkReport> supervisedResults;
  @override
  final BuiltMap<String, ZeroShotFrameworkReport> zeroshotResults;

  factory _$AutoEvalReport([void Function(AutoEvalReportBuilder)? updates]) =>
      (AutoEvalReportBuilder()..update(updates))._build();

  _$AutoEvalReport._(
      {required this.embedderName,
      required this.trainingDate,
      required this.supervisedResults,
      required this.zeroshotResults})
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
        supervisedResults == other.supervisedResults &&
        zeroshotResults == other.zeroshotResults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, trainingDate.hashCode);
    _$hash = $jc(_$hash, supervisedResults.hashCode);
    _$hash = $jc(_$hash, zeroshotResults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoEvalReport')
          ..add('embedderName', embedderName)
          ..add('trainingDate', trainingDate)
          ..add('supervisedResults', supervisedResults)
          ..add('zeroshotResults', zeroshotResults))
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

  MapBuilder<String, SupervisedFrameworkReport>? _supervisedResults;
  MapBuilder<String, SupervisedFrameworkReport> get supervisedResults =>
      _$this._supervisedResults ??=
          MapBuilder<String, SupervisedFrameworkReport>();
  set supervisedResults(
          MapBuilder<String, SupervisedFrameworkReport>? supervisedResults) =>
      _$this._supervisedResults = supervisedResults;

  MapBuilder<String, ZeroShotFrameworkReport>? _zeroshotResults;
  MapBuilder<String, ZeroShotFrameworkReport> get zeroshotResults =>
      _$this._zeroshotResults ??= MapBuilder<String, ZeroShotFrameworkReport>();
  set zeroshotResults(
          MapBuilder<String, ZeroShotFrameworkReport>? zeroshotResults) =>
      _$this._zeroshotResults = zeroshotResults;

  AutoEvalReportBuilder() {
    AutoEvalReport._defaults(this);
  }

  AutoEvalReportBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _embedderName = $v.embedderName;
      _trainingDate = $v.trainingDate;
      _supervisedResults = $v.supervisedResults.toBuilder();
      _zeroshotResults = $v.zeroshotResults.toBuilder();
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
            supervisedResults: supervisedResults.build(),
            zeroshotResults: zeroshotResults.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'supervisedResults';
        supervisedResults.build();
        _$failedField = 'zeroshotResults';
        zeroshotResults.build();
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
