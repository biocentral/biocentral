// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_eval_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoEvalProgress extends AutoEvalProgress {
  @override
  final int completedTasks;
  @override
  final int totalTasks;
  @override
  final String currentFrameworkName;
  @override
  final String currentTaskName;
  @override
  final AutoEvalReport? finalReport;

  factory _$AutoEvalProgress(
          [void Function(AutoEvalProgressBuilder)? updates]) =>
      (AutoEvalProgressBuilder()..update(updates))._build();

  _$AutoEvalProgress._(
      {required this.completedTasks,
      required this.totalTasks,
      required this.currentFrameworkName,
      required this.currentTaskName,
      this.finalReport})
      : super._();
  @override
  AutoEvalProgress rebuild(void Function(AutoEvalProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoEvalProgressBuilder toBuilder() =>
      AutoEvalProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoEvalProgress &&
        completedTasks == other.completedTasks &&
        totalTasks == other.totalTasks &&
        currentFrameworkName == other.currentFrameworkName &&
        currentTaskName == other.currentTaskName &&
        finalReport == other.finalReport;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, completedTasks.hashCode);
    _$hash = $jc(_$hash, totalTasks.hashCode);
    _$hash = $jc(_$hash, currentFrameworkName.hashCode);
    _$hash = $jc(_$hash, currentTaskName.hashCode);
    _$hash = $jc(_$hash, finalReport.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoEvalProgress')
          ..add('completedTasks', completedTasks)
          ..add('totalTasks', totalTasks)
          ..add('currentFrameworkName', currentFrameworkName)
          ..add('currentTaskName', currentTaskName)
          ..add('finalReport', finalReport))
        .toString();
  }
}

class AutoEvalProgressBuilder
    implements Builder<AutoEvalProgress, AutoEvalProgressBuilder> {
  _$AutoEvalProgress? _$v;

  int? _completedTasks;
  int? get completedTasks => _$this._completedTasks;
  set completedTasks(int? completedTasks) =>
      _$this._completedTasks = completedTasks;

  int? _totalTasks;
  int? get totalTasks => _$this._totalTasks;
  set totalTasks(int? totalTasks) => _$this._totalTasks = totalTasks;

  String? _currentFrameworkName;
  String? get currentFrameworkName => _$this._currentFrameworkName;
  set currentFrameworkName(String? currentFrameworkName) =>
      _$this._currentFrameworkName = currentFrameworkName;

  String? _currentTaskName;
  String? get currentTaskName => _$this._currentTaskName;
  set currentTaskName(String? currentTaskName) =>
      _$this._currentTaskName = currentTaskName;

  AutoEvalReportBuilder? _finalReport;
  AutoEvalReportBuilder get finalReport =>
      _$this._finalReport ??= AutoEvalReportBuilder();
  set finalReport(AutoEvalReportBuilder? finalReport) =>
      _$this._finalReport = finalReport;

  AutoEvalProgressBuilder() {
    AutoEvalProgress._defaults(this);
  }

  AutoEvalProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _completedTasks = $v.completedTasks;
      _totalTasks = $v.totalTasks;
      _currentFrameworkName = $v.currentFrameworkName;
      _currentTaskName = $v.currentTaskName;
      _finalReport = $v.finalReport?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoEvalProgress other) {
    _$v = other as _$AutoEvalProgress;
  }

  @override
  void update(void Function(AutoEvalProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoEvalProgress build() => _build();

  _$AutoEvalProgress _build() {
    _$AutoEvalProgress _$result;
    try {
      _$result = _$v ??
          _$AutoEvalProgress._(
            completedTasks: BuiltValueNullFieldError.checkNotNull(
                completedTasks, r'AutoEvalProgress', 'completedTasks'),
            totalTasks: BuiltValueNullFieldError.checkNotNull(
                totalTasks, r'AutoEvalProgress', 'totalTasks'),
            currentFrameworkName: BuiltValueNullFieldError.checkNotNull(
                currentFrameworkName,
                r'AutoEvalProgress',
                'currentFrameworkName'),
            currentTaskName: BuiltValueNullFieldError.checkNotNull(
                currentTaskName, r'AutoEvalProgress', 'currentTaskName'),
            finalReport: _finalReport?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'finalReport';
        _finalReport?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AutoEvalProgress', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
