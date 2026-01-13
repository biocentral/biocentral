// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_simulation_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningSimulationResult extends ActiveLearningSimulationResult {
  @override
  final String campaignName;
  @override
  final BuiltList<num>? iterationMetricsTotal;
  @override
  final BuiltList<num>? iterationMetricsSuggestions;
  @override
  final BuiltList<int>? iterationTargetSuccesses;
  @override
  final BuiltList<int>? iterationConsecutiveFailures;
  @override
  final BuiltList<String>? stopReasons;
  @override
  final BuiltList<ActiveLearningIterationResult>? iterationResults;

  factory _$ActiveLearningSimulationResult(
          [void Function(ActiveLearningSimulationResultBuilder)? updates]) =>
      (ActiveLearningSimulationResultBuilder()..update(updates))._build();

  _$ActiveLearningSimulationResult._(
      {required this.campaignName,
      this.iterationMetricsTotal,
      this.iterationMetricsSuggestions,
      this.iterationTargetSuccesses,
      this.iterationConsecutiveFailures,
      this.stopReasons,
      this.iterationResults})
      : super._();
  @override
  ActiveLearningSimulationResult rebuild(
          void Function(ActiveLearningSimulationResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningSimulationResultBuilder toBuilder() =>
      ActiveLearningSimulationResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningSimulationResult &&
        campaignName == other.campaignName &&
        iterationMetricsTotal == other.iterationMetricsTotal &&
        iterationMetricsSuggestions == other.iterationMetricsSuggestions &&
        iterationTargetSuccesses == other.iterationTargetSuccesses &&
        iterationConsecutiveFailures == other.iterationConsecutiveFailures &&
        stopReasons == other.stopReasons &&
        iterationResults == other.iterationResults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campaignName.hashCode);
    _$hash = $jc(_$hash, iterationMetricsTotal.hashCode);
    _$hash = $jc(_$hash, iterationMetricsSuggestions.hashCode);
    _$hash = $jc(_$hash, iterationTargetSuccesses.hashCode);
    _$hash = $jc(_$hash, iterationConsecutiveFailures.hashCode);
    _$hash = $jc(_$hash, stopReasons.hashCode);
    _$hash = $jc(_$hash, iterationResults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningSimulationResult')
          ..add('campaignName', campaignName)
          ..add('iterationMetricsTotal', iterationMetricsTotal)
          ..add('iterationMetricsSuggestions', iterationMetricsSuggestions)
          ..add('iterationTargetSuccesses', iterationTargetSuccesses)
          ..add('iterationConsecutiveFailures', iterationConsecutiveFailures)
          ..add('stopReasons', stopReasons)
          ..add('iterationResults', iterationResults))
        .toString();
  }
}

class ActiveLearningSimulationResultBuilder
    implements
        Builder<ActiveLearningSimulationResult,
            ActiveLearningSimulationResultBuilder> {
  _$ActiveLearningSimulationResult? _$v;

  String? _campaignName;
  String? get campaignName => _$this._campaignName;
  set campaignName(String? campaignName) => _$this._campaignName = campaignName;

  ListBuilder<num>? _iterationMetricsTotal;
  ListBuilder<num> get iterationMetricsTotal =>
      _$this._iterationMetricsTotal ??= ListBuilder<num>();
  set iterationMetricsTotal(ListBuilder<num>? iterationMetricsTotal) =>
      _$this._iterationMetricsTotal = iterationMetricsTotal;

  ListBuilder<num>? _iterationMetricsSuggestions;
  ListBuilder<num> get iterationMetricsSuggestions =>
      _$this._iterationMetricsSuggestions ??= ListBuilder<num>();
  set iterationMetricsSuggestions(
          ListBuilder<num>? iterationMetricsSuggestions) =>
      _$this._iterationMetricsSuggestions = iterationMetricsSuggestions;

  ListBuilder<int>? _iterationTargetSuccesses;
  ListBuilder<int> get iterationTargetSuccesses =>
      _$this._iterationTargetSuccesses ??= ListBuilder<int>();
  set iterationTargetSuccesses(ListBuilder<int>? iterationTargetSuccesses) =>
      _$this._iterationTargetSuccesses = iterationTargetSuccesses;

  ListBuilder<int>? _iterationConsecutiveFailures;
  ListBuilder<int> get iterationConsecutiveFailures =>
      _$this._iterationConsecutiveFailures ??= ListBuilder<int>();
  set iterationConsecutiveFailures(
          ListBuilder<int>? iterationConsecutiveFailures) =>
      _$this._iterationConsecutiveFailures = iterationConsecutiveFailures;

  ListBuilder<String>? _stopReasons;
  ListBuilder<String> get stopReasons =>
      _$this._stopReasons ??= ListBuilder<String>();
  set stopReasons(ListBuilder<String>? stopReasons) =>
      _$this._stopReasons = stopReasons;

  ListBuilder<ActiveLearningIterationResult>? _iterationResults;
  ListBuilder<ActiveLearningIterationResult> get iterationResults =>
      _$this._iterationResults ??= ListBuilder<ActiveLearningIterationResult>();
  set iterationResults(
          ListBuilder<ActiveLearningIterationResult>? iterationResults) =>
      _$this._iterationResults = iterationResults;

  ActiveLearningSimulationResultBuilder() {
    ActiveLearningSimulationResult._defaults(this);
  }

  ActiveLearningSimulationResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignName = $v.campaignName;
      _iterationMetricsTotal = $v.iterationMetricsTotal?.toBuilder();
      _iterationMetricsSuggestions =
          $v.iterationMetricsSuggestions?.toBuilder();
      _iterationTargetSuccesses = $v.iterationTargetSuccesses?.toBuilder();
      _iterationConsecutiveFailures =
          $v.iterationConsecutiveFailures?.toBuilder();
      _stopReasons = $v.stopReasons?.toBuilder();
      _iterationResults = $v.iterationResults?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningSimulationResult other) {
    _$v = other as _$ActiveLearningSimulationResult;
  }

  @override
  void update(void Function(ActiveLearningSimulationResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningSimulationResult build() => _build();

  _$ActiveLearningSimulationResult _build() {
    _$ActiveLearningSimulationResult _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningSimulationResult._(
            campaignName: BuiltValueNullFieldError.checkNotNull(campaignName,
                r'ActiveLearningSimulationResult', 'campaignName'),
            iterationMetricsTotal: _iterationMetricsTotal?.build(),
            iterationMetricsSuggestions: _iterationMetricsSuggestions?.build(),
            iterationTargetSuccesses: _iterationTargetSuccesses?.build(),
            iterationConsecutiveFailures:
                _iterationConsecutiveFailures?.build(),
            stopReasons: _stopReasons?.build(),
            iterationResults: _iterationResults?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'iterationMetricsTotal';
        _iterationMetricsTotal?.build();
        _$failedField = 'iterationMetricsSuggestions';
        _iterationMetricsSuggestions?.build();
        _$failedField = 'iterationTargetSuccesses';
        _iterationTargetSuccesses?.build();
        _$failedField = 'iterationConsecutiveFailures';
        _iterationConsecutiveFailures?.build();
        _$failedField = 'stopReasons';
        _stopReasons?.build();
        _$failedField = 'iterationResults';
        _iterationResults?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningSimulationResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
